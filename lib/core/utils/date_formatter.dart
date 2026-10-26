// core/utils/date_formatter.dart

class DateFormatter {
  /// Mengonversi [DateTime] menjadi string teks waktu relatif (e.g., "10 mnt lalu", "Kemarin")
  static String getRelativeTimeText(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mnt lalu';
    } else if (difference.inHours < 24 && dateTime.day == now.day) {
      return '${difference.inHours} jam lalu';
    } else if (dateTime.day == now.subtract(const Duration(days: 1)).day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      final minuteStr = dateTime.minute.toString().padLeft(2, '0');
      return 'Kemarin, ${dateTime.hour}:$minuteStr';
    } else {
      return '${difference.inDays} hari lalu';
    }
  }
}
