import '../../../../core/util/resource.dart';
import '../model/data_model/task_data_model.dart';
import '../model/request_model/add_task_req_model.dart';

abstract class TaskRepository {
  Stream<Resource<List<TaskDataModel>>> getTasks();

  Stream<Resource<bool>> seedFromRemoteIfNeeded(
    Map<String, String> headers,
  );

  Stream<Resource<TaskDataModel>> addTask(
    AddTaskReqModel reqBody,
  );

  Stream<Resource<bool>> toggleTask(
    TaskDataModel task,
  );

  Stream<Resource<bool>> deleteTask(
    String id,
  );

  Stream<Resource<bool>> reinsertTask(
    TaskDataModel task,
  );
}
