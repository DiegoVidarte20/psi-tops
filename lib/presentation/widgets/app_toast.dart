import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

enum ToastType { success, error, info }

/// Toast estilo "sonner" (abajo a la derecha en web, abajo a lo ancho en móvil).
class AppToast {
  AppToast._();

  /// Se asigna a MaterialApp.scaffoldMessengerKey para mostrar toasts sin
  /// BuildContext (p. ej. desde controladores).
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void successGlobal(String title, {String? description}) =>
      _global(title, description, ToastType.success);
  static void errorGlobal(String title, {String? description}) =>
      _global(title, description, ToastType.error);
  static void infoGlobal(String title, {String? description}) =>
      _global(title, description, ToastType.info);

  static void _global(String title, String? description, ToastType type) {
    // Ojo: currentContext es el propio ScaffoldMessenger, así que
    // ScaffoldMessenger.of(ctx) no lo encuentra; usamos currentState.
    final messenger = messengerKey.currentState;
    final ctx = messengerKey.currentContext;
    if (messenger == null || ctx == null) return;
    _show(ctx, title, description, type, messenger: messenger);
  }

  static void success(BuildContext c, String title, {String? description}) =>
      _show(c, title, description, ToastType.success);

  static void error(BuildContext c, String title, {String? description}) =>
      _show(c, title, description, ToastType.error);

  static void info(BuildContext c, String title, {String? description}) =>
      _show(c, title, description, ToastType.info);

  static void _show(
    BuildContext context,
    String title,
    String? description,
    ToastType type, {
    ScaffoldMessengerState? messenger,
  }) {
    final (bg, border, fg, icon) = switch (type) {
      ToastType.success => (
        const Color(0xFFECFDF3),
        const Color(0xFFBFFCD9),
        const Color(0xFF008A2E),
        LucideIcons.circleCheck,
      ),
      ToastType.error => (
        const Color(0xFFFFF0F0),
        const Color(0xFFFFE0E1),
        const Color(0xFFE60000),
        LucideIcons.circleX,
      ),
      ToastType.info => (
        AppColors.white,
        AppColors.line,
        AppColors.ink,
        LucideIcons.info,
      ),
    };
    final w = context.screenWidth;
    const toastW = 356.0;
    final m = messenger ?? ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        backgroundColor: bg,
        duration: const Duration(seconds: 4),
        padding: const EdgeInsets.all(16),
        margin: w > toastW + 32
            ? EdgeInsets.only(left: w - toastW - 24, right: 24, bottom: 24)
            : const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border),
        ),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.sans(
                      size: 13,
                      weight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(description, style: AppText.sans(size: 13, color: fg)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
