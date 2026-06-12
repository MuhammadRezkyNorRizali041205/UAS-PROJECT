// lib/features/calendar/presentation/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../schedule/domain/entities/schedule.dart';
import '../../../schedule/presentation/providers/schedule_provider.dart';
import '../../../schedule/presentation/widgets/schedule_card.dart';
import '../../../task/domain/entities/task.dart';
import '../../../task/presentation/providers/task_provider.dart';
import '../../../task/presentation/widgets/task_card.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  // Convert DateTime.weekday (Mon=1..Sun=7) → our dayOfWeek (Sun=0..Sat=6)
  int _toDayOfWeek(DateTime d) => d.weekday == 7 ? 0 : d.weekday;

  bool _scheduleOnDay(ScheduleEntity s, DateTime day) {
    if (!s.isActive) return false;
    if (_toDayOfWeek(day) != s.dayOfWeek) return false;

    final start = DateTime(s.startDate.year, s.startDate.month, s.startDate.day);
    final target = DateTime(day.year, day.month, day.day);
    if (target.isBefore(start)) return false;

    if (s.endDate != null) {
      final end = DateTime(s.endDate!.year, s.endDate!.month, s.endDate!.day);
      if (target.isAfter(end)) return false;
    }

    if (s.recurrence == 'once') {
      return isSameDay(s.startDate, day);
    }

    if (s.recurrence == 'biweekly') {
      final weekDiff = target.difference(start).inDays ~/ 7;
      return weekDiff % 2 == 0;
    }

    return true; // weekly
  }

  bool _taskOnDay(TaskEntity t, DateTime day) {
    if (t.deadline == null) return false;
    return isSameDay(t.deadline!, day);
  }

  List<_CalEvent> _eventsForDay(
    DateTime day,
    List<ScheduleEntity> schedules,
    List<TaskEntity> tasks,
  ) {
    final events = <_CalEvent>[];
    for (final s in schedules) {
      if (_scheduleOnDay(s, day)) {
        events.add(_CalEvent(color: AppColors.categoryColor(s.category)));
      }
    }
    for (final t in tasks) {
      if (_taskOnDay(t, day)) {
        events.add(_CalEvent(color: AppColors.priorityColor(t.priority)));
      }
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleListProvider);
    final taskState     = ref.watch(taskListProvider);

    final schedules = scheduleState.asData?.value ?? [];
    final tasks     = taskState.asData?.value ?? [];

    final isLoading = scheduleState.isLoading || taskState.isLoading;

    final selectedSchedules = schedules
        .where((s) => _scheduleOnDay(s, _selectedDay))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final selectedTasks = tasks
        .where((t) => _taskOnDay(t, _selectedDay))
        .toList()
      ..sort((a, b) =>
          (a.deadline ?? DateTime(9999)).compareTo(b.deadline ?? DateTime(9999)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Kalender')),
      body: Column(
        children: [
          // ─── Calendar widget ─────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: TableCalendar<_CalEvent>(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
              calendarFormat: _format,
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Bulan',
                CalendarFormat.twoWeeks: '2 Minggu',
                CalendarFormat.week: 'Minggu',
              },
              eventLoader: (day) => _eventsForDay(day, schedules, tasks),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay  = focused;
                });
              },
              onFormatChanged: (f) => setState(() => _format = f),
              onPageChanged: (focused) =>
                  setState(() => _focusedDay = focused),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textPrimary),
                weekendTextStyle: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.danger),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.primary),
                markerDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 4,
                markerSize: 5,
                markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
                cellMargin: const EdgeInsets.all(4),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.take(4).map((e) => Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      decoration: BoxDecoration(
                        color: e.color,
                        shape: BoxShape.circle,
                      ),
                    )).toList(),
                  );
                },
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTextStyles.labelSmall,
                weekendStyle: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.danger),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                formatButtonTextStyle: AppTextStyles.labelSmall,
                titleTextStyle: AppTextStyles.headingSmall,
                leftChevronIcon: const Icon(Icons.chevron_left_rounded,
                    color: AppColors.textSecondary),
                rightChevronIcon: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
                headerPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),

          // ─── Selected day label ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  _formatSelectedDay(_selectedDay),
                  style: AppTextStyles.headingSmall,
                ),
                const Spacer(),
                if (selectedSchedules.isNotEmpty || selectedTasks.isNotEmpty)
                  Text(
                    '${selectedSchedules.length + selectedTasks.length} item',
                    style: AppTextStyles.labelSmall,
                  ),
              ],
            ),
          ),

          // ─── Selected day events ─────────────────────────────────────
          Expanded(
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SkeletonList(count: 3),
                  )
                : _SelectedDayList(
                    schedules: selectedSchedules,
                    tasks: selectedTasks,
                    selectedDay: _selectedDay,
                    onTaskStatusToggle: (task) => ref
                        .read(taskListProvider.notifier)
                        .updateStatus(
                          task.id,
                          task.isCompleted ? 'pending' : 'completed',
                        ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatSelectedDay(DateTime d) {
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month]} ${d.year}';
  }
}

// ─── Selected day list ────────────────────────────────────────────────────────
class _SelectedDayList extends ConsumerWidget {
  final List<ScheduleEntity> schedules;
  final List<TaskEntity> tasks;
  final DateTime selectedDay;
  final void Function(TaskEntity) onTaskStatusToggle;

  const _SelectedDayList({
    required this.schedules,
    required this.tasks,
    required this.selectedDay,
    required this.onTaskStatusToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (schedules.isEmpty && tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.event_available_rounded,
        title: 'Tidak ada kegiatan',
        subtitle: 'Pilih tanggal lain atau tambahkan jadwal baru.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        if (schedules.isNotEmpty) ...[
          _GroupLabel(
              icon: Icons.schedule_rounded,
              label: 'Jadwal (${schedules.length})'),
          const SizedBox(height: 8),
          ...schedules.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ScheduleCard(
                  schedule: s,
                  onTap: () => context
                      .push(AppRoutes.scheduleDetail(s.id.toString())),
                ),
              )),
        ],
        if (tasks.isNotEmpty) ...[
          if (schedules.isNotEmpty) const SizedBox(height: 8),
          _GroupLabel(
              icon: Icons.assignment_outlined,
              label: 'Tugas (${tasks.length})'),
          const SizedBox(height: 8),
          ...tasks.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TaskCard(
                  task: t,
                  onTap: () =>
                      context.push(AppRoutes.taskDetail(t.id.toString())),
                  onStatusToggle: () => onTaskStatusToggle(t),
                ),
              )),
        ],
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GroupLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      );
}

// ─── Tiny event model ─────────────────────────────────────────────────────────
class _CalEvent {
  final Color color;
  const _CalEvent({required this.color});
}
