import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/util/resource.dart';
import '../repository/task_repository.dart';

class DeleteTaskBusiness {
  final TaskRepository _repository;

  DeleteTaskBusiness(this._repository);

  Stream<Resource<bool>> call(String id) async* {
    try {
      await for (final response in _repository.deleteTask(id)) {
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
