import 'package:flutter/material.dart';
import 'app_colors.dart';

/// IBM Plex Sans (UI) + IBM Plex Mono (números), igual que el diseño.
/// Las fuentes van empaquetadas en assets/fonts (ver pubspec.yaml).
class AppText {
  AppText._();

  static const sansFamily = 'IBMPlexSans';
  static const monoFamily = 'IBMPlexMono';

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: sansFamily,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle mono({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: monoFamily,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  /// Etiquetas en mayúsculas (text-[11px] font-semibold uppercase tracking-[0.08em]).
  /// `tracking` en em, igual que Tailwind.
  static TextStyle overline({
    double size = 11,
    Color color = AppColors.inkMuted,
    double tracking = 0.08,
    double? height,
  }) => sans(
    size: size,
    weight: FontWeight.w600,
    color: color,
    height: height,
    letterSpacing: size * tracking,
  );
}
