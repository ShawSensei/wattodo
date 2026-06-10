import 'package:dio/dio.dart';
import 'resource.dart';

class ExceptionUtil {
  static Resource<T> handleDioException<T>(DioException e) {
    String errorMessage;
    int? errorCode;

    const commonErr =
        'App could not connect with server. Please check your internet connection and try again later!';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection Timeout!\n$commonErr';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send Timeout!\n$commonErr';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive Timeout!\n$commonErr';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Bad Certificate!\n$commonErr';
        break;
      case DioExceptionType.badResponse:
        final outMessage = e.response?.data['message'] ?? commonErr;
        errorMessage = 'Bad Response ${e.response?.statusCode}!\n$outMessage';
        errorCode = e.response?.statusCode;
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request Cancelled!\n$commonErr';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Connection Error!\n$commonErr';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Unknown Error!\n$commonErr';
        break;
    }

    return Resource.error(errorMessage, errorCode);
  }
}
