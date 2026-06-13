// lib/features/student_class/presentation/screens/student_class_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../data/student_class_repository.dart';

part 'student_class_list_screen.g.dart';

@riverpod
StudentClassRepository studentClassRepository(Ref ref) =>
    StudentClassRepository(ref.read(dioClientProvider));

@riverpod
Future<List<dynamic>> myClasses(Ref ref) =>
    ref.read(studentClassRepositoryProvider).getMyClasses();

class StudentClassListScreen extends ConsumerWidget {
  const StudentClassListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(myClassesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Kelas Saya'),
      ),
      body: classes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school_outlined, color: AppColors.textMuted, size: 48),
              const SizedBox(height: 12),
              Text('$e', style: const TextStyle(color: AppColors.textMuted), textAlign: TextAlign.center),
              TextButton(onPressed: () => ref.invalidate(myClassesProvider), child: const Text('Coba Lagi')),
            ],
          ),
        ),
        data: (list) => list.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined, color: AppColors.textMuted, size: 64),
                    SizedBox(height: 16),
                    Text('Belum terdaftar di kelas manapun', style: TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(myClassesProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _ClassCard(cls: list[i]),
                ),
              ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.cls});
  final dynamic cls;

  @override
  Widget build(BuildContext context) {
    final pending = cls['pending_tasks'] as int? ?? 0;
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: pending > 0 ? AppColors.warning.withValues(alpha: 0.4) : AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/student/classes/${cls['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.roleStudent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_rounded, color: AppColors.roleStudent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cls['course_name'] ?? '',
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('${cls['course_code']} • Sem ${cls['semester']}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text('Dosen: ${cls['lecturer_name'] ?? '-'}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              if (pending > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Text('$pending tugas',
                      style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold)),
                )
              else
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
