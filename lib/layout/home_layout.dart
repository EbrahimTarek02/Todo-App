import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../shared/components/components.dart';

class HomeLayout extends StatelessWidget
{

  var scaffoldKey = GlobalKey<ScaffoldState>();

  var formKey = GlobalKey<FormState>();

  TimeOfDay time = TimeOfDay.now();

  DateTime date = DateTime.now();

  var titleController = TextEditingController();

  var timeController = TextEditingController();

  var dateController = TextEditingController();

  BottomSheet x = BottomSheet(onClosing: (){}, builder: (context)=> Container());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state)
        {
          if(state is OnCloseFloatingButtonState)
            Navigator.pop(context);
          if(state is InsertIntoDatabaseState) {
            titleController.text = '';
            timeController.text = '';
            dateController.text = '';
          }


        },
        builder: (BuildContext context, AppStates state)
        {
          AppCubit cubit = AppCubit.get(context);

          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                  cubit.appBarTitles[cubit.currentIndex]
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: ()
              {
                if(cubit.buttonISActivated)
                {
                  cubit.changeBottomSheetState(
                    isActivated: false,
                    icon: Icons.add,
                  );

                  // setState(() {
                  //   Navigator.pop(context);
                  //   buttonISActivated = false;
                  //   buttonIcon = Icons.add;
                  //   titleController.text = '';
                  //   timeController.text = '';
                  //   dateController.text = '';
                  // });

                  /////////////////////////////////////
                  // if(formKey.currentState!.validate())
                  // {
                  //   insertToDatabase(
                  //     title: '${titleController.text}',
                  //     time: '${timeController.text}',
                  //     date: '${dateController.text}'
                  //   ).then((value)
                  //   {
                  //     Navigator.pop(context);
                  //     buttonISActivated = false;
                  //     setState(() {
                  //       buttonIcon = Icons.add;
                  //     });
                  //   }).catchError((error)
                  //   {
                  //     return 'Error on inserting into database ${error.toString()}';
                  //   });
                  // }
                }
                else
                {
                  scaffoldKey.currentState?.showBottomSheet(
                        (context) => Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:
                          [
                            defaultTextFormField(
                                controller: titleController,
                                type: 'title',
                                inputType: TextInputType.text,
                                icon: Icons.title,
                                label: 'Title',
                                onTap: ()
                                {
                                  return null;
                                }
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            defaultTextFormField(
                                controller: timeController,
                                type: 'time',
                                inputType: TextInputType.none,
                                icon: Icons.watch_later_outlined,
                                label: 'Time',
                                onTap: ()
                                {
                                  showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now()
                                  ).then((value)
                                  {
                                    timeController.text = value!.format(context).toString();
                                  }).catchError((error)
                                  {
                                    print('error on time field => ${error.toString()}');
                                  });
                                }
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            defaultTextFormField(
                                controller: dateController,
                                type: 'date',
                                inputType: TextInputType.none,
                                icon: Icons.date_range_outlined,
                                label: 'Date',
                                onTap: ()
                                {
                                  showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.utc(2025)
                                  ).then((value)
                                  {
                                    dateController.text = DateFormat.yMMMd().format(value!);
                                  }).catchError((error)
                                  {
                                    print('Error on date field => ${error.toString()}');
                                  });
                                }
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            defaultButton(
                                function: ()
                                {
                                  if(formKey.currentState!.validate())
                                  {
                                    cubit.insertToDatabase(
                                        title: '${titleController.text}',
                                        time: '${timeController.text}',
                                        date: '${dateController.text}'
                                    );
                                    cubit.changeBottomSheetState(
                                        isActivated: false,
                                        icon: Icons.add
                                    );
                                  }
                                },
                                text: 'add new task'
                            )
                          ],
                        ),
                      ),
                    ),
                    elevation: 20.0,
                    enableDrag: false,
                  );
                  cubit.changeBottomSheetState(
                      isActivated: true,
                      icon: Icons.arrow_downward_outlined
                  );
                }

              },
              child: Icon(
                  cubit.buttonIcon
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index)
              {
                cubit.changeIndex(index);
              },
              items:
              [
                BottomNavigationBarItem(
                    icon: Icon(Icons.menu),
                    label: 'New Tasks'
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline),
                    label: 'Done Tasks'
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined),
                    label: 'Archived Tasks'
                ),
              ],
            ),
            body: cubit.screens[cubit.currentIndex],
          );
        },
      ),
    );
  }
}
