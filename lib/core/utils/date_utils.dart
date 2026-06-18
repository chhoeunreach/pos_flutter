import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _displayDate = DateFormat('MMM dd, yyyy');
  static final DateFormat _displayDateTime = DateFormat('MMM dd, yyyy HH:mm');
  static final DateFormat _displayTime = DateFormat('HH:mm');
  static final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _apiDateTime = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return _displayDate.format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return _displayDateTime.format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return _displayTime.format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String toApiDate(DateTime date) {
    return _apiFormat.format(date);
  }

  static String toApiDateTime(DateTime date) {
    return _apiDateTime.format(date);
  }

  static String timeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'just now';
    } catch (_) {
      return '';
    }
  }

  static bool isToday(String? dateStr) {
    if (dateStr == null) return false;
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    } catch (_) {
      return false;
    }
  }
}
