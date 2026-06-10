import '../business/add_task_business.dart';
import '../business/delete_task_business.dart';
import '../business/get_tasks_business.dart';
import '../business/reinsert_task_business.dart';
import '../business/seed_tasks_business.dart';
import '../business/toggle_task_business.dart';

// Bundles all business classes so the controller takes one dependency instead of six
class TaskUseCases {
  final GetTasksBusiness getTasksBusiness;
  final SeedTasksBusiness seedTasksBusiness;
  final AddTaskBusiness addTaskBusiness;
  final ToggleTaskBusiness toggleTaskBusiness;
  final DeleteTaskBusiness deleteTaskBusiness;
  final ReinsertTaskBusiness reinsertTaskBusiness;

  const TaskUseCases({
    required this.getTasksBusiness,
    required this.seedTasksBusiness,
    required this.addTaskBusiness,
    required this.toggleTaskBusiness,
    required this.deleteTaskBusiness,
    required this.reinsertTaskBusiness,
  });
}
