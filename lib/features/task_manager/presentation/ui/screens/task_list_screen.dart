import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../core/constant/app_colors.dart';
import '../../controller/task_controller.dart';
import '../widgets/empty_task_widget.dart';
import '../widgets/task_tile_widget.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaskController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Obx(() {
            if (controller.errorMessage.value.isNotEmpty) {
              // Defer snackbar to avoid calling Get.snackbar during a build phase
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.snackbar(
                  '',
                  controller.errorMessage.value,
                  titleText: const SizedBox.shrink(),
                  messageText: Row(
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF1F2937),
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  borderRadius: 14,
                  duration: const Duration(seconds: 4),
                  onTap: (_) => controller.errorMessage.value = '',
                );
                controller.errorMessage.value = '';
              });
            }

            return CustomScrollView(
              slivers: [
                _buildHeader(controller),
                _buildFilterTabs(controller),
                if (controller.isLoading.value)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                else if (controller.filteredTasks.isEmpty)
                  SliverFillRemaining(
                    child: EmptyTaskWidget(filter: controller.filter.value),
                  )
                else
                  SliverPadding(
                    // Bottom padding so the FAB doesn't cover the last tile
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = controller.filteredTasks[index];
                          return TaskTileWidget(
                            key: ValueKey(task.id),
                            task: task,
                            index: index,
                            onToggle: () => controller.toggleTask(task),
                            onDelete: () {
                              // Capture idx before removal for undo reinsertion
                              final originalIdx = controller.tasks
                                  .indexWhere((t) => t.id == task.id);
                              controller.deleteTask(task.id);
                              Get.showSnackbar(GetSnackBar(
                                messageText: const Text(
                                  'Task deleted',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                mainButton: TextButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Get.closeCurrentSnackbar();
                                    controller.undoDelete(task, originalIdx);
                                  },
                                  child: const Text(
                                    'UNDO',
                                    style: TextStyle(
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                backgroundColor: const Color(0xFF1F2937),
                                borderRadius: 14,
                                margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                duration: const Duration(seconds: 3),
                                snackPosition: SnackPosition.BOTTOM,
                              ));
                            },
                          );
                        },
                        childCount: controller.filteredTasks.length,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
        floatingActionButton: _AddFab(),
      ),
    );
  }

  Widget _buildHeader(TaskController controller) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'My Tasks',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() => _ProgressRing(
                      progress: controller.progress,
                      completed: controller.completedCount,
                      total: controller.tasks.length,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(TaskController controller) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Obx(() => Row(
              children: TaskFilter.values.map((f) {
                final isSelected = controller.filter.value == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.setFilter(f);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                )
                              ],
                      ),
                      child: Text(
                        _filterLabel(f),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }

  String _filterLabel(TaskFilter f) => switch (f) {
        TaskFilter.all => 'All',
        TaskFilter.active => 'Active',
        TaskFilter.done => 'Done',
      };

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _AddFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddTaskSheet(),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final int completed;
  final int total;

  const _ProgressRing({
    required this.progress,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 62,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(62, 62),
            painter: _RingPainter(progress: progress),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$completed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              Text(
                'of $total',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 3.5;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    if (progress > 0) {
      // Start at 12 o'clock (-π/2) and sweep clockwise
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
