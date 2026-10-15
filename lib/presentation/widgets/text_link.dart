import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

/// Texto clicable (subrayado al pasar el mouse).
class TextLink extends StatefulWidget {
  const TextLink({
    super.key,
    required this.label,
    required this.onTap,
    this.size = 13,
    this.bold = false,
    this.color = AppColors.primary,
    this.hoverColor,
    this.underline = true,
  });

  final String label;
  final VoidCallback onTap;
  final double size;
  final bool bold;
  final Color color;
  final Color? hoverColor;
  final bool underline;

  @override
  State<TextLink> createState() => _TextLinkState();
}

class _TextLinkState extends State<TextLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = _hover ? (widget.hoverColor ?? widget.color) : widget.color;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style:
              AppText.sans(
                size: widget.size,
                weight: widget.bold ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ).copyWith(
                decoration: _hover && widget.underline
                    ? TextDecoration.underline
                    : null,
                decorationColor: color,
              ),
        ),
      ),
    );
  }
}
