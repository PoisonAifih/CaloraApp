import 'l10n.dart';

String formatWhen(String iso) {
  final date = DateTime.tryParse(iso)?.toLocal();
  if (date == null) return iso;
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${shortMonth(date.month)} $hour:$minute';
}

String roundNum(num value) => value.round().toString();
