import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

enum AppButtonVariant {
  primary,
  outline,
  outlinePrimary,
  outlineDanger,
  success,
  danger,
  ghost,
}

enum AppButtonSize { sm, md }

/// Equivalente a components/ui/Button.tsx.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.expand = false,
    this.height,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? icon;

  /// true: ocupa todo el ancho que le den, con el contenido centrado.
  final bool expand;

  /// Alto personalizado (por defecto 32 sm / 40 md).
  final double? height;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hover = false;

  ({Color bg, Color hoverBg, Color fg, Color? border}) get _colors =>
      switch (widget.variant) {
        AppButtonVariant.primary => (
          bg: AppColors.primary,
          hoverBg: AppColors.primaryHover,
          fg: Colors.white,
          border: null,
        ),
        AppButtonVariant.outline => (
          bg: AppColors.white,
          hoverBg: AppColors.surface,
          fg: AppColors.ink,
          border: AppColors.lineStrong,
        ),
        AppButtonVariant.outlinePrimary => (
          bg: AppColors.white,
          hoverBg: AppColors.primarySoft,
          fg: AppColors.primary,
          border: AppColors.primary,
        ),
        AppButtonVariant.outlineDanger => (
          bg: AppColors.white,
          hoverBg: AppColors.stopSoft,
          fg: AppColors.stop,
          border: AppColors.stop.withValues(alpha: 0.4),
        ),
        AppButtonVariant.success => (
          bg: AppColors.run,
          hoverBg: AppColors.runStrong,
          fg: Colors.white,
          border: null,
        ),
        AppButtonVariant.danger => (
          bg: AppColors.stop,
          hoverBg: AppColors.stopStrong,
          fg: Colors.white,
          border: null,
        ),
        AppButtonVariant.ghost => (
          bg: Colors.transparent,
          hoverBg: AppColors.surface,
          fg: _hover ? AppColors.ink : AppColors.inkMuted,
          border: null,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final c = _colors;
    final sm = widget.size == AppButtonSize.sm;
    final label = Text(
      widget.label,
      softWrap: false,
      style: AppText.sans(
        size: sm ? 12.5 : 14,
        weight: FontWeight.w600,
        color: c.fg,
      ),
    );
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: MouseRegion(
        cursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Semantics(
          button: true,
          enabled: enabled,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: widget.height ?? (sm ? 32 : 40),
              padding: EdgeInsets.symmetric(
                horizontal: sm || widget.expand ? 12 : 16,
              ),
              decoration: BoxDecoration(
                color: _hover && enabled ? c.hoverBg : c.bg,
                borderRadius: BorderRadius.circular(6),
                border: c.border != null ? Border.all(color: c.border!) : null,
              ),
              child: Row(
                mainAxisSize: widget.expand
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    IconTheme(
                      data: IconThemeData(color: c.fg, size: 16),
                      child: widget.icon!,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (widget.expand)
                    // Ancho fijo: si el texto no entra, se achica en vez de desbordar.
                    Flexible(
                      child: FittedBox(fit: BoxFit.scaleDown, child: label),
                    )
                  else
                    label,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
