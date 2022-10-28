import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../cubit/cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  required Function function,
  required String text,
  bool isUpperCase = true,
}) =>
    Container(
      width: width,
      color: background,
      child: MaterialButton(
        onPressed: () {
          function();
        },
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );

Widget defaultTextFormField(
    {required TextEditingController controller,
      required String type,
      required TextInputType inputType,
      required IconData icon,
      required String label,
      IconData? suffix,
      bool isPassword = false,
      Function? func,
      Function? onTap,
      String? initialVal
    }) =>
    TextFormField(
      initialValue: initialVal,
      validator: (value) {
        if (value!.isEmpty) return "$type must not be empty";
      },
      obscureText: isPassword,
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        suffixIcon: suffix != null
            ? IconButton(
          onPressed: () {
            func!();
          },
          icon: Icon(suffix),
        )
            : null,
        prefixIcon: Icon(icon),
        label: Text(
          '$label',
        ),
        border: OutlineInputBorder(),
      ),
      onTap: () {
        onTap!();
      },
    );

Widget ListBuilder (Map model, context, bool newTask, bool Done) => Slidable(
  child: Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
      children: [
        CircleAvatar(
          radius: 40.0,
          child: Text('${model['TIME']}'),
        ),
        SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: Container(
            height: 80.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${model['TITLE']}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                Text(
                  '${model['DATE']}',
                  style: TextStyle(fontSize: 15.0, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        if(newTask)...[
          IconButton(
            onPressed:() {
              AppCubit.get(context)
                  .updateDatabase(status: 'DONE', id: model['ID']);
            },
            icon: Icon(Icons.check_box),
            color: Colors.green,
          ),
          IconButton(
            onPressed:() {
              AppCubit.get(context)
                  .updateDatabase(status: 'ARCHIVED', id: model['ID']);
            },
            icon: Icon(Icons.archive),
            color: Colors.green,
          ),
        ]else if(Done)...[
          IconButton(
            onPressed:() {
              AppCubit.get(context)
                  .updateDatabase(status: 'ARCHIVED', id: model['ID']);
            },
            icon: Icon(Icons.archive),
            color: Colors.green,
          ),
        ]else...[
          IconButton(
            onPressed:() {
              AppCubit.get(context)
                  .updateDatabase(status: 'DONE', id: model['ID']);
            },
            icon: Icon(Icons.check_box_sharp),
            color: Colors.green,
          ),
        ],
      ],
    ),
  ),
  endActionPane: ActionPane(
    motion: StretchMotion(),
    children:
    [
      SlidableAction(
        onPressed: (BuildContext context)
        {
          AppCubit.get(context).getDataTOUpdate(id: model['ID']);
          Scaffold.of(context).showBottomSheet((context) =>
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(10.0),
                child: Form(
                  key: AppCubit.get(context).formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                    [
                      defaultTextFormField(
                          controller: AppCubit.get(context).titleController,
                          type: 'title',
                          inputType: TextInputType.text,
                          icon: Icons.title,
                          label: 'Title',
                          onTap: ()
                          {
                            return null;
                          },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      defaultTextFormField(
                          controller: AppCubit.get(context).timeController,
                          type: 'time',
                          inputType: TextInputType.none,
                          icon: Icons.watch_later_outlined,
                          label: 'Time',
                          onTap: ()
                          {
                            showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                            ).then((value)
                            {
                              AppCubit.get(context).timeController.text = value!.format(context).toString();
                              // setState(() {
                              //   if(value == null)
                              //     value = time;
                              //   else
                              //   {
                              //     timeController.text = value!.format(context).toString();
                              //     time = value!;
                              //   }
                              // });
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
                          controller: AppCubit.get(context).dateController,
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
                              AppCubit.get(context).dateController.text = DateFormat.yMMMd().format(value!);
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
                            if(AppCubit.get(context).formKey.currentState!.validate())
                            {
                              AppCubit.get(context).updateOnEditDatabase(
                                  title: AppCubit.get(context).titleController.text,
                                  time: AppCubit.get(context).timeController.text,
                                  date: AppCubit.get(context).dateController.text,
                                  id: model['ID']
                              );
                              AppCubit.get(context).changeBottomSheetState(
                                  isActivated: false,
                                  icon: Icons.add
                              );
                              // ).then((value)
                              // {
                              //   cubit.getFromDatabase(cubit.database).then((value) {
                              //     Navigator.pop(context);
                              //     setState(() {
                              //       buttonISActivated = false;
                              //       buttonIcon = Icons.add;
                              //       titleController.text = '';
                              //       timeController.text = '';
                              //       dateController.text = '';
                              //       tasks = value;
                              //     });
                              //   });
                              // }).catchError((error)
                              // {
                              //   return 'Error on inserting into database ${error.toString()}';
                              // });
                            }
                          },
                          text: 'update task'
                      )
                    ],
                  ),
                ),
              ),
              elevation: 20.0,
              enableDrag: false,);
          AppCubit.get(context).changeBottomSheetState(
              isActivated: true,
              icon: Icons.arrow_downward_outlined
          );
          print('hi');
        },
        icon: Icons.edit,
        backgroundColor: Colors.blue,
      ),
      SlidableAction(
        onPressed: (BuildContext context)
        {
          AppCubit.get(context).deleteFromDatabase(id: model['ID']);
          print('hi');
        },
        icon: Icons.delete,
        backgroundColor: Colors.red,
      ),
    ],
  ),
);

