import 'package:flutter/material.dart';
import '../../../../../core/constant/app_colors.dart';
import '../../controller/task_controller.dart';

class EmptyTaskWidget extends StatelessWidget {
  final TaskFilter filter;

  const EmptyTaskWidget({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final config = _config(filter);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                config.$1,
                size: 44,
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              config.$2,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              config.$3,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  (IconData, String, String) _config(TaskFilter f) => switch (f) {
        TaskFilter.all => (
            Icons.checklist_rounded,
            'No tasks yet',
            'Tap the + button to add your first task and get things done.',
          ),
        TaskFilter.active => (
            Icons.task_alt_rounded,
            'All caught up!',
            'No active tasks — everything is either done or not added yet.',
          ),
        TaskFilter.done => (
            Icons.emoji_events_rounded,
            'Nothing completed yet',
            'Start completing tasks and they\'ll show up here.',
          ),
      };
}
