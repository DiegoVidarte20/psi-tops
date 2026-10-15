import 'package:flutter/widgets.dart';

/// Breakpoints de Tailwind (sm 640, md 768, lg 1024, xl 1280), medidos
/// sobre el ancho de la ventana, igual que en CSS.
class Breakpoints {
  Breakpoints._();
  static const double sm = 640;
  static const double md = 768;
  static const double lg = 1024;
  static const double xl = 1280;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isSm => screenWidth >= Breakpoints.sm;
  bool get isMd => screenWidth >= Breakpoints.md;
  bool get isLg => screenWidth >= Breakpoints.lg;
  bool get isXl => screenWidth >= Breakpoints.xl;
}
