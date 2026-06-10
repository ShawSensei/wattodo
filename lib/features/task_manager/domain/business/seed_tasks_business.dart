import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/util/resource.dart';
import '../repository/task_repository.dart';

class SeedTasksBusiness {
  final TaskRepository _repository;

  SeedTasksBusiness(this._repository);

  Stream<Resource<bool>> call(Map<String, String> headers) async* {
    try {
      await for (final response in _repository.seedFromRemoteIfNeeded(headers)) {
        yield response;
      }
    } on DioException catch (e) {
      yield Resource.error('Network error: ${e.message}', null);
    } on SocketException catch (e) {
      yield Resource.error('Network Error: ${e.message}', null);
    } on FormatException catch (e) {
      // Seeding parses external API data — other operations only touch local DB
      yield Resource.error('Data Format Error: ${e.message}', null);
    } catch (e) {
      yield Resource.error('Unexpected Error: ${e.toString()}', null);
    }
  }
}
