import 'package:intl/intl.dart';

class DateHelper {
  DateHelper._();

  static final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final _timeFormat = DateFormat('HH:mm');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final _dayFormat = DateFormat('EEEE', 'id_ID');

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
  static String formatDay(DateTime date) => _dayFormat.format(date);

  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return formatDate(date);
  }

  /// Countdown to deadline.
  static String countdown(DateTime deadline) {
    final now = DateTime.now();
    final diff = deadline.difference(now);

    if (diff.isNegative) {
      final late = now.difference(deadline);
      if (late.inHours < 1) return 'Terlambat ${late.inMinutes} menit 🔴';
      return 'Terlambat ${late.inHours} jam 🔴';
    }

    if (diff.inMinutes <= 60) return '${diff.inMinutes} menit lagi ⚠️';
    if (diff.inHours < 24) return '${diff.inHours} jam lagi';

    final days = diff.inDays;
    final hours = diff.inHours - (days * 24);
    return '$days hari ${hours > 0 ? '$hours jam ' : ''}lagi';
  }

  /// Convert int day_of_week (0=Sun) to label.
  static String dayLabel(int dayOfWeek) {
    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    return days[dayOfWeek % 7];
  }

  static DateTime startOfWeek([DateTime? from]) {
    final date = from ?? DateTime.now();
    return date.subtract(Duration(days: date.weekday % 7));
  }

  static DateTime endOfWeek([DateTime? from]) =>
      startOfWeek(from).add(const Duration(days: 6));

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
