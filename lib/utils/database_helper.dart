import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_notekeeper_application/models/note.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper;  //Singleton DBHelper
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();  // constructor to create instance of DBHelper

factory DatabaseHelper() {
  if (_databaseHelper == null) {
    _databaseHelper = DatabaseHelper._createInstance();
  }
  return _databaseHelper;
}
Future<Database> get database async {
  if (_database == null) {
    _database = await initializeDatabase();
  }

  return _database;
}

 Future<Database> initializeDatabase() async {

  Directory directory = await getApplicationDocumentsDirectory();
  String path = directory.path + 'noted.db';

  //create DB at given path

   var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
   return notesDatabase;

 }




void _createDb(Database db, int newVersion) async {

  await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
}


//Fetch

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
  Database db = await this.database;

  var result = await db.query(noteTable, orderBy: '$colPriority ASC');
  return result;
}

//INSERT
  Future<int> insertNote(Note note) async {
  Database db = await this.database;

  var result = await db.insert(noteTable, note.toMap());
  return result;
 }

 //UPDATE
  Future<int> updateNote(Note note) async {
  var db = await this.database;

  var result = await db.update(noteTable, note.toMap(),  where: '$colId = ?', whereArgs: [note.id]);
  return result;
  }

 //DELETE
  Future<int> deleteNote(int id) async {
    var db = await this.database;

    var result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  //Number of record
  Future<int> getCount() async {
    Database db = await this.database;

    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //Get Map List and convert into Note list

 Future<List<Note>> getNoteList() async {

  var noteMapList = await getNoteMapList(); // get MapList from DB
   int count = noteMapList.length;       //count no. of map list entry

   List<Note> noteList = List<Note>();

   for(int i=0;i<count;i++) {
     noteList.add(Note.fromMapObject(noteMapList[i]));
   }

   return noteList;

 }

}