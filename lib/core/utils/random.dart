import 'dart:math' as math;

/// Ruido determinístico 0..1 (igual que seededNoise del diseño).
double seededNoise(num seed) {
  final x = math.sin(seed * 12.9898 + 78.233) * 43758.5453;
  return x - x.floorToDouble();
}
