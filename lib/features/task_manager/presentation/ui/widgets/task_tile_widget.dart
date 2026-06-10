import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/constant/app_colors.dart';
import '../../../domain/model/data_model/task_data_model.dart';

class TaskTileWidget extends StatelessWidget {
  final TaskDataModel task;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskTileWidget({
    super.key,
    required this.task,
    required this.index,
    required this.onToggle,
    required this.onDelete,
  });

  void _showActions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _TaskActionsSheet(
        task: task,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(task.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) {
          HapticFeedback.mediumImpact();
          onDelete();
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.error,
            size: 22,
          ),
        ),
        child: GestureDetector(
          onLongPress: () => _showActions(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: _AnimatedCheck(
                      isDone: isDone,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onToggle();
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            color: isDone
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: AppColors.textHint,
                            height: 1.4,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            task.description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        _TaskMeta(createdAt: task.createdAt),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskActionsSheet extends StatelessWidget {
  final TaskDataModel task;
  final VoidCallback onDelete;

  const _TaskActionsSheet({required this.task, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          InkWell(
            onTap: () {
              HapticFeedback.heavyImpact();
              Navigator.of(context).pop();
              onDelete();
            },
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Delete task',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCheck extends StatelessWidget {
  final bool isDone;
  final VoidCallback onTap;

  const _AnimatedCheck({required this.isDone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppColors.success : Colors.transparent,
            border: Border.all(
              color: isDone ? AppColors.success : const Color(0xFFCBD5E1),
              width: 2,
            ),
          ),
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
              : null,
        ),
      ),
    );
  }
}

class _TaskMeta extends StatelessWidget {
  final DateTime createdAt;

  const _TaskMeta({required this.createdAt});

  String _elapsed(DateTime now) {
    final diff = now.difference(createdAt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  String _shortDate() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Row(
      children: [
        Text(
          _elapsed(now),
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          _shortDate(),
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
