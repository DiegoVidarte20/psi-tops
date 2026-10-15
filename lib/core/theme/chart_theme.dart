import 'package:flutter/material.dart';
import 'app_text.dart';

/// Equivalente a utils/chartTheme.ts.
class ChartTheme {
  ChartTheme._();
  static const gridStroke = Color(0xFFEDF0F4);
  static const tickColor = Color(0xFF6B7280);
  static const stopFill = Color(0xFFFBE3E3);
  static const feed = Color(0xFFD97706);
  static const series = [
    Color(0xFF1F5FC4),
    Color(0xFFD97706),
    Color(0xFF0F766E),
    Color(0xFF7C3AED),
    Color(0xFFBE185D),
  ];

  static TextStyle get tick => AppText.mono(size: 11, color: tickColor);
}
