import 'format.dart';

class ShiftInfo {
  final int id;
  final String label;
  final String range;
  final int startHour;
  const ShiftInfo(this.id, this.label, this.range, this.startHour);
}

String formatDate(DateTime d) => '${pad2(d.day)}/${pad2(d.month)}/${d.year}';

String formatClock(DateTime d, {bool withSeconds = true}) {
  final base = '${pad2(d.hour)}:${pad2(d.minute)}';
  return withSeconds ? '$base:${pad2(d.second)}' : base;
}

ShiftInfo getShift(DateTime d) {
  final h = d.hour;
  if (h >= 6 && h < 14) return const ShiftInfo(1, 'Turno 1', '06:00–14:00', 6);
  if (h >= 14 && h < 22) {
    return const ShiftInfo(2, 'Turno 2', '14:00–22:00', 14);
  }
  return const ShiftInfo(3, 'Turno 3', '22:00–06:00', 22);
}

/// Minutos desde el inicio del turno actual (mínimo 30, como en el diseño).
int minutesSinceShiftStart(DateTime d) {
  final start = getShift(d).startHour;
  var minutes = (d.hour - start) * 60 + d.minute;
  if (minutes < 0) minutes += 1440;
  return minutes < 30 ? 30 : minutes;
}
