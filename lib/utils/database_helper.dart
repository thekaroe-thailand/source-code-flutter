import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertutorial/models/note.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();

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
    String path = directory.path + 'notes.db';
    
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    
    return notesDatabase;
  }
  
  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT,'
    '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    return await db.query(noteTable, orderBy: '$colPriority ASC');
  }

  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    return await db.insert(noteTable, note.toMap());
  }

  Future<int> updateNote(Note note) async {
    Database db = await this.database;
    return await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
  }

  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    return await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT(*) FROM $noteTable');
    return Sqflite.firstIntValue(x);
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();

    int count = noteMapList.length;
    List<Note> noteList = List<Note>();

    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }

}