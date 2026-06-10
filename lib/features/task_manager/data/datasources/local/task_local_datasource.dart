import 'package:sqflite/sqflite.dart';
import '../../../../../core/util/database_helper.dart';
import '../../../domain/model/data_model/task_data_model.dart';

class TaskLocalDatasource {
  final DatabaseHelper _dbHelper;

  TaskLocalDatasource(this._dbHelper);

  Future<List<TaskDataModel>> getAllTasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.taskTable,
      orderBy: 'created_at DESC',
    );
    return maps.map(TaskDataModel.fromMap).toList();
  }

  Future<void> insertTask(TaskDataModel task) async {
    final db = await _dbHelper.database;
    await db.insert(DatabaseHelper.taskTable, task.toMap());
  }

  Future<void> updateTask(TaskDataModel task) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.taskTable,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.taskTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isSeeded() async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        DatabaseHelper.metaTable,
        where: 'key = ?',
        whereArgs: ['seeded'],
      );
      return rows.isNotEmpty;
    } on DatabaseException {
      return false;
    }
  }

  Future<void> markSeeded() async {
    final db = await _dbHelper.database;
    await db.insert(DatabaseHelper.metaTable, {'key': 'seeded', 'value': '1'});
  }
}
