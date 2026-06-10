import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/util/resource.dart';
import '../../domain/model/data_model/task_data_model.dart';
import '../../domain/model/request_model/add_task_req_model.dart';
import '../../domain/usecase/task_use_cases.dart';

enum TaskFilter { all, active, done }

class TaskController extends GetxController {
  final TaskUseCases _useCases;
  final NotificationService _notificationService;

  TaskController(this._useCases, this._notificationService);

  final RxList<TaskDataModel> tasks = <TaskDataModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<TaskFilter> filter = TaskFilter.all.obs;

  // Store the subscription so we can cancel before reassigning.
  // Without this, every _loadTasks() call adds another listener and events fire twice.
  StreamSubscription<Resource<List<TaskDataModel>>>? _tasksSub;

  int get pendingCount => tasks.where((t) => !t.isCompleted).length;
  int get completedCount => tasks.where((t) => t.isCompleted).length;

  double get progress => tasks.isEmpty ? 0 : completedCount / tasks.length;

  List<TaskDataModel> get filteredTasks {
    return switch (filter.value) {
      TaskFilter.all => tasks,
      TaskFilter.active => tasks.where((t) => !t.isCompleted).toList(),
      TaskFilter.done => tasks.where((t) => t.isCompleted).toList(),
    };
  }

  void setFilter(TaskFilter f) => filter.value = f;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  @override
  void onClose() {
    _tasksSub?.cancel();
    super.onClose();
  }

  Future<void> _init() async {
    await for (final resource in _useCases.seedTasksBusiness({})) {
      if (resource.status == Status.loading) {
        isLoading.value = true;
      } else if (resource.status == Status.error) {
        // Seed failure is non-fatal — user can still create tasks manually
        debugPrint('Seed notice: ${resource.errorMessage}');
        errorMessage.value = resource.errorMessage ?? '';
        break;
      } else {
        break;
      }
    }
    _loadTasks();
  }

  void _loadTasks() {
    _tasksSub?.cancel();
    _tasksSub = _useCases.getTasksBusiness().listen((resource) {
      if (resource.status == Status.loading) {
        isLoading.value = true;
      } else if (resource.status == Status.success) {
        tasks.assignAll(resource.data ?? []);
        isLoading.value = false;
        // Keep daily briefing count in sync with the live pending count
        _notificationService.scheduleDailyBriefing(pendingCount);
      } else {
        errorMessage.value = resource.errorMessage ?? 'Failed to load tasks';
        isLoading.value = false;
      }
    });
  }

  Future<void> addTask(AddTaskReqModel req) async {
    TaskDataModel? createdTask;

    await for (final resource in _useCases.addTaskBusiness(req)) {
      if (resource.status == Status.success) {
        createdTask = resource.data;
      } else if (resource.status == Status.error) {
        errorMessage.value = resource.errorMessage ?? 'Failed to add task';
        return;
      }
    }

    _loadTasks();

    if (createdTask != null && createdTask.dueDate != null) {
      await _notificationService.scheduleTaskReminder(
        id: createdTask.id,
        title: createdTask.title,
        dueDate: createdTask.dueDate!,
      );
    }
  }

  // Optimistic update — flip in-memory immediately, persist async, revert on failure.
  // Avoids the list flicker you'd get from waiting on a DB round-trip before updating UI.
  Future<void> toggleTask(TaskDataModel task) async {
    final idx = tasks.indexWhere((t) => t.id == task.id);
    final willComplete = !task.isCompleted;

    if (idx != -1) {
      tasks[idx] = task.copyWith(isCompleted: willComplete);
    }

    await for (final resource in _useCases.toggleTaskBusiness(task)) {
      if (resource.status == Status.error) {
        if (idx != -1) tasks[idx] = task;
        errorMessage.value = resource.errorMessage ?? 'Failed to update task';
        return;
      }
    }

    if (willComplete) {
      await _notificationService.cancelTaskReminder(task.id);
      if (tasks.every((t) => t.isCompleted)) {
        await _notificationService.showAllDoneNotification();
      }
    } else if (task.dueDate != null) {
      // Uncompleting — restore the scheduled reminder if due date still in the future
      await _notificationService.scheduleTaskReminder(
        id: task.id,
        title: task.title,
        dueDate: task.dueDate!,
      );
    }
  }

  Future<void> deleteTask(String id) async {
    final idx = tasks.indexWhere((t) => t.id == id);
    final backup = idx != -1 ? tasks[idx] : null;
    tasks.removeWhere((t) => t.id == id);

    await for (final resource in _useCases.deleteTaskBusiness(id)) {
      if (resource.status == Status.error) {
        if (backup != null && idx != -1) tasks.insert(idx, backup);
        errorMessage.value = resource.errorMessage ?? 'Failed to delete task';
        return;
      }
    }

    await _notificationService.cancelTaskReminder(id);
  }

  // Re-inserts at the clamped original position so the item reappears where it was
  Future<void> undoDelete(TaskDataModel task, int originalIdx) async {
    final clampedIdx = originalIdx.clamp(0, tasks.length);
    tasks.insert(clampedIdx, task);

    await for (final resource in _useCases.reinsertTaskBusiness(task)) {
      if (resource.status == Status.error) {
        tasks.removeWhere((t) => t.id == task.id);
        errorMessage.value = resource.errorMessage ?? 'Failed to restore task';
        return;
      }
    }

    if (!task.isCompleted && task.dueDate != null) {
      await _notificationService.scheduleTaskReminder(
        id: task.id,
        title: task.title,
        dueDate: task.dueDate!,
      );
    }
  }
}
