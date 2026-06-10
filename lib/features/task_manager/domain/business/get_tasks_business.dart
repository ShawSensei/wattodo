import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/util/resource.dart';
import '../model/data_model/task_data_model.dart';
import '../repository/task_repository.dart';

class GetTasksBusiness {
  final TaskRepository _repository;

  GetTasksBusiness(this._repository);

  Stream<Resource<List<TaskDataModel>>> call() async* {
    try {
      await for (final response in _repository.getTasks()) {
        yield response;
      }
    } on DioException catch (e) {
      yield Resource.error('Network error: ${e.message}', null);
    } on SocketException catch (e) {
      // SocketException bypasses Dio entirely (e.g. airplane mode)
      yield Resource.error('Network Error: ${e.message}', null);
    } catch (e) {
      yield Resource.error('Unexpected Error: ${e.toString()}', null);
    }
  }
}
