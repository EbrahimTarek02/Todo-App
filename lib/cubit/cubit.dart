import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/cubit/states.dart';
import '../modules/archived_tasks/archived_tasks.dart';
import '../modules/done_tasks/done_tasks.dart';
import '../modules/new_tasks/new_tasks.dart';
import '../shared/components/components.dart';

class AppCubit extends Cubit<AppStates>
{
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);


  var currentIndex = 0;
  late Database database ;
  List <Map> newTasks = [];
  List <Map> doneTasks = [];
  List <Map> archivedTasks = [];
  bool buttonISActivated = false;
  IconData buttonIcon = Icons.add;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  List <Widget> screens =
  [
    New_Tasks(),
    Done_Tasks(),
    Archived_Tasks()
  ];

  List <String> appBarTitles =
  [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks'
  ];

  void changeIndex(int index)
  {
    currentIndex = index;
    emit(OnChangeAppNavBarState());
  }

  void createDatabase ()
  {
    openDatabase(
        'todo.db',
        version: 1,
        onCreate: (database, version) async
        {
          print ('database created');
          await database.execute(
              'CREATE TABLE TASKS (ID INTEGER PRIMARY KEY, TITLE TEXT, DATE TEXT, TIME TEXT, STATUS TEXT)'
          ).then((value) {
            print('table created');
          }).catchError((error) {
            print ('error when creating table ${error.toString()}');
          });
        },
        onOpen: (database)
        {
          getFromDatabase(database);
          print ('database opened');
        }
    ).then((value)
    {
      database = value;
      emit(CreateDatabaseState());
    });
  }

  insertToDatabase ({
    required String title,
    required String time,
    required String date,
  }) async
  {
    await database.transaction((txn) async
    {
      await txn.rawInsert(
          'INSERT INTO TASKS (TITLE, DATE, TIME, STATUS) VALUES ("${title}", "${date}", "${time}", "NEW")'
      ).then((value)
      {
        print('${value} raw added');
        emit(InsertIntoDatabaseState());

        getFromDatabase(database);
      }).catchError((error)
      {
        return 'Error on inserting new raw ${error.toString()}';
      });
      return null;
    });
  }

  void getFromDatabase(database) async
  {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    database.rawQuery('SELECT * FROM TASKS').then((value) {

      value.forEach((element)
      {
        if(element['STATUS'] == 'NEW')
          newTasks.add(element);
        else if(element['STATUS'] == 'DONE')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });
      emit(GetFromDatabaseState());
    });
  }

  void updateDatabase({
    required String status,
    required int id
  }) async
  {
    database.rawUpdate(
        'UPDATE TASKS SET STATUS = ? WHERE ID = ?',
        ['${status}', '${id}']
    ).then((value)
    {
      getFromDatabase(database);
      emit(UpdateDatabaseState());
    });
  }

  void deleteFromDatabase({
    required int id
  }) async
  {
    database.rawDelete(
        'DELETE FROM TASKS WHERE ID = ?',
        ['${id}']
    ).then((value)
    {
      getFromDatabase(database);
      emit(DeleteFromDatabaseState());
    });
  }


  void changeBottomSheetState({
    required bool isActivated,
    required IconData icon,
  })
  {
    buttonISActivated = isActivated;
    buttonIcon = icon;
    if(!buttonISActivated)
      emit(OnCloseFloatingButtonState());

    emit(OnChangeFloatingButtonState());
  }

  void getDataTOUpdate({required int id}) async
  {
    database.rawQuery(
        'SELECT * FROM TASKS WHERE ID = ${id}').then((value)
    {
      value.forEach((element)
      {
        titleController.text = element['TITLE'].toString();
        timeController.text = element['TIME'].toString();
        dateController.text = element['DATE'].toString();
      });

      emit(edit());
    });
  }

  void updateOnEditDatabase({
    required String title,
    required String time,
    required String date,
    required int id
  }) async
  {
    database.rawUpdate(
        'UPDATE TASKS SET TITLE = ?, TIME = ?, DATE = ? WHERE ID = ?',
        ['${title}', '${time}', '${date}', '${id}']
    ).then((value)
    {
      getFromDatabase(database);
      emit(UpdateDatabaseState());
    });
  }
}