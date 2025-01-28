export 'database_service.dart';
import 'dart:async';

import 'package:exam_flutter/models/Subject.dart';
import 'package:exam_flutter/models/Task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();
  final StreamController<List<Task>> _tasksStreamController =
      StreamController.broadcast();

  final String _subjectsTableName = "subjects";

  final String _tasksTableName = "tasks";
  final String _subjectsColumnId = "id";
  final String _subjectsColumnName = "name";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirpath = await getDatabasesPath();
    final databasePath = join(databaseDirpath, 'master_db.db');
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $_subjectsTableName (
            $_subjectsColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_subjectsColumnName TEXT NOT NULL
          )
        ''');
        db.execute('''
          CREATE TABLE $_tasksTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT NOT NULL,
            date TEXT NOT NULL,
            type TEXT NOT NULL,
            examType TEXT,
            description TEXT
          )
        ''');
      },
    );
    return database;
  }

  void addSubject(String subjectName) async {
    final db = await database;
    await db.insert(_subjectsTableName, {_subjectsColumnName: subjectName});
  }

  void deleteSubject(int subjectId) async {
    final db = await database;
    await db.delete(_subjectsTableName,
        where: '$_subjectsColumnId = ?', whereArgs: [subjectId]);
  }

  void deleteTask(int taskId) async {
    final db = await database;
    await db.delete(_tasksTableName, where: 'id = ?', whereArgs: [taskId]);
    fetchTasks();
  }

  Future<List<Subject>> getSubjects() async {
    final db = await database;
    final data = await db.query(_subjectsTableName);
    List<Subject> subjects = data
        .map((e) => Subject(id: e['id'] as int, name: e['name'] as String))
        .toList();
    return subjects;
  }

  Stream<List<Task>> get tasksStream => _tasksStreamController.stream;

  Future<void> fetchTasks() async {
    final db = await database;
    final data = await db.query(_tasksTableName);
    List<Task> tasks = data
        .map((e) => Task(
              id: e['id'] as int,
              subject: e['subject'] as String,
              date: e['date'] as String,
              type: e['type'] as String,
              examType: e['examType'] as String,
              description: e['description'] as String,
            ))
        .toList();

    _tasksStreamController.add(tasks);
  }

  void dispose() {
    _tasksStreamController.close();
  }

  void addTask(Task task) async {
    final db = await database;
    await db.insert(_tasksTableName, {
      'subject': task.subject,
      'date': task.date,
      'type': task.type,
      'examType': task.examType,
      'description': task.description
    });
    fetchTasks();
  }
}
