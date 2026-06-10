import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../../main.dart';
import '../../../../core/util/exception_util.dart';
import '../../../../core/util/resource.dart';
import '../../domain/model/data_model/task_data_model.dart';
import '../../domain/model/request_model/add_task_req_model.dart';
import '../../domain/repository/task_repository.dart';
import '../datasources/api/task_api.dart';
import '../datasources/local/task_local_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskApi _apiService;
  final TaskLocalDatasource _localDatasource;

  TaskRepositoryImpl(this._apiService, this._localDatasource);

  @override
  Stream<Resource<List<TaskDataModel>>> getTasks() async* {
    try {
      yield Resource.loading();
      final tasks = await _localDatasource.getAllTasks();
      debugPrint('Tasks loaded: ${tasks.length}');
      yield Resource.success(tasks);
    } on DioException catch (e) {
      debugPrint('getTasks error: $e');
      yield ExceptionUtil.handleDioException<List<TaskDataModel>>(e);
    }
  }

  @override
  Stream<Resource<bool>> seedFromRemoteIfNeeded(
    Map<String, String> headers,
  ) async* {
    getIt<Dio>().options.headers = headers;

    try {
      final alreadySeeded = await _localDatasource.isSeeded();
      if (alreadySeeded) {
        yield Resource.success(true);
        return;
      }

      yield Resource.loading();
      final todos = await _apiService.fetchTodos();
      debugPrint('Fetched ${todos.length} todos from remote');

      for (final dto in todos) {
        await _localDatasource.insertTask(dto.toTaskDataModel());
      }

      // Mark seeded after all inserts succeed — so a mid-seed failure retries next launch
      await _localDatasource.markSeeded();
      yield Resource.success(true);
    } on DioException catch (e) {
      debugPrint('Seed error: $e');
      yield ExceptionUtil.handleDioException<bool>(e);
    }
  }

  @override
  Stream<Resource<bool>> addTask(AddTaskReqModel reqBody) async* {
    try {
      yield Resource.loading();
      final task = TaskDataModel(
        id: const Uuid().v4(),
        title: reqBody.title,
        description: reqBody.description,
        createdAt: DateTime.now(),
      );
      await _localDatasource.insertTask(task);
      debugPrint('Task added: ${task.id}');
      yield Resource.success(true);
    } on DioException catch (e) {
      debugPrint('addTask error: $e');
      yield ExceptionUtil.handleDioException<bool>(e);
    }
  }

  @override
  Stream<Resource<bool>> toggleTask(TaskDataModel task) async* {
    try {
      yield Resource.loading();
      await _localDatasource.updateTask(
        task.copyWith(isCompleted: !task.isCompleted),
      );
      debugPrint('Task toggled: ${task.id}');
      yield Resource.success(true);
    } on DioException catch (e) {
      debugPrint('toggleTask error: $e');
      yield ExceptionUtil.handleDioException<bool>(e);
    }
  }

  @override
  Stream<Resource<bool>> deleteTask(String id) async* {
    try {
      yield Resource.loading();
      await _localDatasource.deleteTask(id);
      debugPrint('Task deleted: $id');
      yield Resource.success(true);
    } on DioException catch (e) {
      debugPrint('deleteTask error: $e');
      yield ExceptionUtil.handleDioException<bool>(e);
    }
  }

  @override
  Stream<Resource<bool>> reinsertTask(TaskDataModel task) async* {
    try {
      yield Resource.loading();
      await _localDatasource.insertTask(task);
      debugPrint('Task reinserted: ${task.id}');
      yield Resource.success(true);
    } on DioException catch (e) {
      debugPrint('reinsertTask error: $e');
      yield ExceptionUtil.handleDioException<bool>(e);
    }
  }
}
