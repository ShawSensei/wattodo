import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/util/resource.dart';
import '../model/data_model/task_data_model.dart';
import '../model/request_model/add_task_req_model.dart';
import '../repository/task_repository.dart';

class AddTaskBusiness {
  final TaskRepository _repository;

  AddTaskBusiness(this._repository);

  Stream<Resource<TaskDataModel>> call(AddTaskReqModel req) async* {
    try {
      await for (final response in _repository.addTask(req)) {
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
