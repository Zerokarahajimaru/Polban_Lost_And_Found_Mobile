import 'package:timeago/timeago.dart' as timeago;

class TimeHelper {
  static String formatRelative(DateTime date) {
    return timeago.format(date, locale: 'id');
  }

  static String formatFull(DateTime date) {
    // Simple full format if needed
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }
}
