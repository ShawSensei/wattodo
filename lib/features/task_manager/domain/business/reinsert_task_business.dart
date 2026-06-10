import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/util/resource.dart';
import '../model/data_model/task_data_model.dart';
import '../repository/task_repository.dart';

// Restores the exact deleted record (same id, createdAt) rather than creating a new one
class ReinsertTaskBusiness {
  final TaskRepository _repository;

  ReinsertTaskBusiness(this._repository);

  Stream<Resource<bool>> call(TaskDataModel task) async* {
    try {
      await for (final response in _repository.reinsertTask(task)) {
        yield response;
      }
    } on DioException catch (e) {
      yield Resource.error('Network error: ${e.message}', null);
    } on SocketException catch (e) {
      yield Resource.error('Network Error: ${e.message}', null);
    } catch (e) {
      yield Resource.error('Unexpected Error: ${e.toString()}', null);
    }
  }
}
