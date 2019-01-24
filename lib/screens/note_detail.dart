import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_notekeeper_application/models/note.dart';
import 'package:flutter_notekeeper_application/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  var _formkey = GlobalKey<FormState>();
  static var _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
        onWillPop: () {
          //code when press back button
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                moveToLastScreen();
              },
            ),
          ),
          body: Form(
              key: _formkey,
              child: Padding(
                padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                child: ListView(
                  children: <Widget>[
                    //FirstmElement
                    ListTile(
                      title: DropdownButton(
                          items: _priorities.map((String dropDownStringItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          style: textStyle,
                          value: getPriorityAsString(note.priority),
                          onChanged: (valueSelectedByUser) {
                            setState(() {
                              debugPrint('User selected $valueSelectedByUser');
                              updatePriorityAsInt(valueSelectedByUser);
                            });
                          }),
                    ),

                    //SecondElement

                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextFormField(
                        controller: titleController,
                        style: textStyle,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please Enter Title';
                          } else {
                            debugPrint('Something changed in Title Text Field');
                            updateTitle();
                          }
                        },
                        decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                    ),

                    //thirdElement

                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextFormField(
                        controller: descriptionController,
                        style: textStyle,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please Enter description';
                          } else {
                            debugPrint('Something changed in Title Text Field');
                            updateDescription();
                          }
                        },
                        decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                    ),

                    //FourthElement
                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              color: Theme.of(context).primaryColorDark,
                              textColor: Theme.of(context).primaryColorLight,
                              child: Text(
                                'Save',
                                textScaleFactor: 1.5,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_formkey.currentState.validate()) {
                                    debugPrint("Save button clicked");
                                    _save();
                                  }
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 5.0,
                          ),
                          Expanded(
                            child: RaisedButton(
                              color: Theme.of(context).primaryColorDark,
                              textColor: Theme.of(context).primaryColorLight,
                              child: Text(
                                'Delete',
                                textScaleFactor: 1.5,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_formkey.currentState.validate()) {
                                    debugPrint("Delete button clicked");
                                    _delete();
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // convert string priority into int before saving

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

// convert int priority into String during display

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; //High
        break;

      case 2:
        priority = _priorities[1]; //Low
        break;
    }
    return priority;
  }

  //update title

  void updateTitle() {
    note.title = titleController.text;
  }

  //update Description

  void updateDescription() {
    note.description = descriptionController.text;
  }

  //Save data to DB

  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;

    if (note.id != null) {
      // case 1 : update data

      result = await helper.updateNote(note);
    } else {
      //case 2: Insert data
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      //success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      //not success
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();

    //Case 1: Delete new note
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    //case 2: Delete note having valid ID
    int result = await helper.deleteNote(note.id);

    if (result != 0) {
      //success
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      //not success
      _showAlertDialog('Status', 'Error while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }
}
