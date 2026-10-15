import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Ítem clicable del sidebar con estados activo / hover (navy-600 / navy-700).
class NavHoverTile extends StatefulWidget {
  const NavHoverTile({
    super.key,
    required this.active,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  final bool active;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  State<NavHoverTile> createState() => _NavHoverTileState();
}

class _NavHoverTileState extends State<NavHoverTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.active
        ? AppColors.navy600
        : _hover
        ? AppColors.navy700
        : Colors.transparent;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
