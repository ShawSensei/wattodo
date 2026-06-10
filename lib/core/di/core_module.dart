import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../network/base_url.dart';
import '../util/database_helper.dart';

// Registers app-wide infrastructure that every feature may need
abstract class CoreModule {
  static Future<void> dependencies(GetIt getIt) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: BaseUrls.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Eager singleton — any bad config surfaces at startup
    getIt.registerSingleton<Dio>(dio);

    getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  }
}
