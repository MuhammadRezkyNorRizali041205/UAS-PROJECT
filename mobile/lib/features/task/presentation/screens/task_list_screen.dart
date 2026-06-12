// lib/features/task/presentation/screens/task_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Tugas'),
          bottom: TabBar(
            labelStyle:
                AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
            unselectedLabelStyle: AppTextStyles.labelMedium,
            indicatorColor: AppColors.primary,
            dividerColor: AppColors.border,
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Aktif'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AllTab(),
            _ActiveTab(),
            _CompletedTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.taskCreate),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

// ─── All tab ──────────────────────────────────────────────────────────────────
class _AllTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskListProvider);
    return state.when(
      loading: () => const _TaskSkeleton(),
      error: (e, _) => ErrorState(
        message: e.toString().replaceFirst('Exception: ', ''),
        onRetry: () => ref.invalidate(taskListProvider),
      ),
      data: (tasks) => tasks.isEmpty
          ? EmptyState(
              icon: Icons.task_alt_rounded,
              title: 'Belum ada tugas',
              subtitle: 'Tambahkan tugas kuliah atau kegiatan lainnya.',
              ctaLabel: 'Tambah Tugas',
              onCta: () => context.push(AppRoutes.taskCreate),
            )
          : _DismissibleTaskList(tasks: tasks),
    );
  }
}

// ─── Active tab ───────────────────────────────────────────────────────────────
class _ActiveTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskListProvider);
    return state.when(
      loading: () => const _TaskSkeleton(),
      error: (e, _) => ErrorState(
        message: e.toString().replaceFirst('Exception: ', ''),
        onRetry: () => ref.invalidate(taskListProvider),
      ),
      data: (tasks) {
        final active = tasks
            .where((t) => t.status != 'completed')
            .toList();
        return active.isEmpty
            ? const EmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'Semua tugas selesai!',
                subtitle: 'Tidak ada tugas yang sedang aktif.',
              )
            : _TaskListView(tasks: active);
      },
    );
  }
}

// ─── Completed tab ────────────────────────────────────────────────────────────
class _CompletedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskListProvider);
    return state.when(
      loading: () => const _TaskSkeleton(),
      error: (e, _) => ErrorState(
        message: e.toString().replaceFirst('Exception: ', ''),
        onRetry: () => ref.invalidate(taskListProvider),
      ),
      data: (tasks) {
        final done = tasks.where((t) => t.isCompleted).toList();
        return done.isEmpty
            ? const EmptyState(
                icon: Icons.hourglass_empty_rounded,
                title: 'Belum ada tugas selesai',
                subtitle: 'Selesaikan tugasmu dan lihat di sini.',
              )
            : _TaskListView(tasks: done);
      },
    );
  }
}

// ─── Dismissible list ─────────────────────────────────────────────────────────
class _DismissibleTaskList extends ConsumerWidget {
  final List<TaskEntity> tasks;
  const _DismissibleTaskList({required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final task = tasks[i];
        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(context, task.title),
          onDismissed: (_) async {
            final err = await ref
                .read(taskListProvider.notifier)
                .deleteTask(task.id);
            if (err != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(err),
                    backgroundColor: AppColors.danger),
              );
            }
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_rounded, color: AppColors.danger),
          ),
          child: TaskCard(
            task: task,
            onTap: () =>
                context.push(AppRoutes.taskDetail(task.id.toString())),
            onStatusToggle: () => _toggleStatus(context, ref, task),
          ),
        );
      },
    );
  }

  Future<void> _toggleStatus(
      BuildContext context, WidgetRef ref, TaskEntity task) async {
    final newStatus =
        task.isCompleted ? 'pending' : 'completed';
    final err = await ref
        .read(taskListProvider.notifier)
        .updateStatus(task.id, newStatus);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<bool> _confirmDelete(
      BuildContext context, String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Tugas?'),
            content: Text(
                'Hapus "$title"? Tindakan ini tidak dapat dibatalkan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// ─── Simple list ──────────────────────────────────────────────────────────────
class _TaskListView extends ConsumerWidget {
  final List<TaskEntity> tasks;
  const _TaskListView({required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final task = tasks[i];
        return TaskCard(
          task: task,
          onTap: () =>
              context.push(AppRoutes.taskDetail(task.id.toString())),
          onStatusToggle: () async {
            final newStatus =
                task.isCompleted ? 'pending' : 'completed';
            final err = await ref
                .read(taskListProvider.notifier)
                .updateStatus(task.id, newStatus);
            if (err != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(err),
                    backgroundColor: AppColors.danger),
              );
            }
          },
        );
      },
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────
class _TaskSkeleton extends StatelessWidget {
  const _TaskSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(16),
        child: SkeletonList(count: 5),
      );
}
