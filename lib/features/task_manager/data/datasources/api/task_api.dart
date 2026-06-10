import 'package:dio/dio.dart';
import '../../../../../core/constant/app_constants.dart';
import '../dto/todo_response_dto.dart';

class TaskApi {
  final Dio _dio;

  TaskApi(this._dio);

  Future<List<TodoResponseDto>> fetchTodos() async {
    final response = await _dio.get<List<dynamic>>(
      '/todos',
      queryParameters: {'_limit': AppConstants.seedCount},
    );

    return (response.data ?? [])
        .map((e) => TodoResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
