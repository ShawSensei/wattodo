import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/util/database_helper.dart';
import '../data/datasources/api/task_api.dart';
import '../data/datasources/local/task_local_datasource.dart';
import '../data/repository/task_repository_impl.dart';
import '../domain/business/add_task_business.dart';
import '../domain/business/delete_task_business.dart';
import '../domain/business/get_tasks_business.dart';
import '../domain/business/reinsert_task_business.dart';
import '../domain/business/seed_tasks_business.dart';
import '../domain/business/toggle_task_business.dart';
import '../domain/repository/task_repository.dart';
import '../domain/usecase/task_use_cases.dart';
import '../presentation/controller/task_controller.dart';

class TaskModule {
  static void dependencies(GetIt getIt) {
    getIt.registerLazySingleton<TaskApi>(
      () => TaskApi(getIt()),
    );

    getIt.registerLazySingleton<TaskLocalDatasource>(
      () => TaskLocalDatasource(getIt<DatabaseHelper>()),
    );

    // Registered against the abstract interface so swapping the impl only changes this line
    getIt.registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(
        getIt<TaskApi>(),
        getIt<TaskLocalDatasource>(),
      ),
    );

    getIt.registerLazySingleton<GetTasksBusiness>(
      () => GetTasksBusiness(getIt<TaskRepository>()),
    );
    getIt.registerLazySingleton<SeedTasksBusiness>(
      () => SeedTasksBusiness(getIt<TaskRepository>()),
    );
    getIt.registerLazySingleton<AddTaskBusiness>(
      () => AddTaskBusiness(getIt<TaskRepository>()),
    );
    getIt.registerLazySingleton<ToggleTaskBusiness>(
      () => ToggleTaskBusiness(getIt<TaskRepository>()),
    );
    getIt.registerLazySingleton<DeleteTaskBusiness>(
      () => DeleteTaskBusiness(getIt<TaskRepository>()),
    );
    getIt.registerLazySingleton<ReinsertTaskBusiness>(
      () => ReinsertTaskBusiness(getIt<TaskRepository>()),
    );

    getIt.registerLazySingleton<TaskUseCases>(
      () => TaskUseCases(
        getTasksBusiness: getIt<GetTasksBusiness>(),
        seedTasksBusiness: getIt<SeedTasksBusiness>(),
        addTaskBusiness: getIt<AddTaskBusiness>(),
        toggleTaskBusiness: getIt<ToggleTaskBusiness>(),
        deleteTaskBusiness: getIt<DeleteTaskBusiness>(),
        reinsertTaskBusiness: getIt<ReinsertTaskBusiness>(),
      ),
    );

    // Controller uses Get.lazyPut (not GetIt) so navigation lifecycle manages it.
    // fenix:true lets GetX recreate it if the user navigates away and back.
    Get.lazyPut<TaskController>(
      () => TaskController(getIt<TaskUseCases>(), getIt<NotificationService>()),
      fenix: true,
    );
  }
}
