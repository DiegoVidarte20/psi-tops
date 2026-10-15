/// Formato de números del diseño: miles con espacio y decimales con coma.
/// 18432.5 -> "18 432,5"
String formatNumber(num value, [int decimals = 0]) {
  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ' ',
  );
  final sign = value < 0 && double.parse(fixed) != 0 ? '-' : '';
  final dec = parts.length > 1 ? ',${parts[1]}' : '';
  return '$sign$intPart$dec';
}

String pad2(int n) => n.toString().padLeft(2, '0');

String formatDuration(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final s = totalSeconds % 60;
  return '${pad2(h)}:${pad2(m)}:${pad2(s)}';
}
