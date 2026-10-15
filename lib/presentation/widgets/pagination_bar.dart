import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';

/// Botones de paginación: ‹ 1 … 4 5 6 … 27 ›
/// En móvil muestra menos páginas vecinas para no desbordar.
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.pageCount,
    required this.onPage,
  });

  final int page;
  final int pageCount;
  final ValueChanged<int> onPage;

  /// Lista de páginas a mostrar; null = "…".
  static List<int?> pagesFor(int page, int count, {int siblings = 1}) {
    final maxSlots = 5 + siblings * 2;
    if (count <= maxSlots) return [for (var i = 1; i <= count; i++) i];
    final start = (page - siblings).clamp(2, count - 1);
    final end = (page + siblings).clamp(2, count - 1);
    return [
      1,
      if (start > 2) null,
      for (var i = start; i <= end; i++) i,
      if (end < count - 1) null,
      count,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = pagesFor(page, pageCount, siblings: context.isSm ? 1 : 0);
    return Semantics(
      label: 'Paginación',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PageButton(
            label: 'Página anterior',
            enabled: page > 1,
            onTap: () => onPage(page - 1),
            child: const Icon(LucideIcons.chevronLeft, size: 14),
          ),
          for (final p in pages) ...[
            const SizedBox(width: 6),
            if (p == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  '…',
                  style: AppText.mono(size: 12.5, color: AppColors.inkFaint),
                ),
              )
            else
              _PageButton(
                label: 'Página $p',
                active: p == page,
                onTap: () => onPage(p),
                child: Text(formatNumber(p)),
              ),
          ],
          const SizedBox(width: 6),
          _PageButton(
            label: 'Página siguiente',
            enabled: page < pageCount,
            onTap: () => onPage(page + 1),
            child: const Icon(LucideIcons.chevronRight, size: 14),
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatefulWidget {
  const _PageButton({
    required this.label,
    required this.onTap,
    required this.child,
    this.active = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;
  final bool active;
  final bool enabled;

  @override
  State<_PageButton> createState() => _PageButtonState();
}

class _PageButtonState extends State<_PageButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final fg = active ? Colors.white : AppColors.ink;
    return Opacity(
      opacity: widget.enabled ? 1 : 0.4,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Semantics(
          button: true,
          label: widget.label,
          selected: active,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled && !active ? widget.onTap : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 32,
              constraints: const BoxConstraints(minWidth: 32),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary
                    : _hover && widget.enabled
                    ? AppColors.surface
                    : AppColors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: active ? AppColors.primary : AppColors.lineStrong,
                ),
              ),
              child: Center(
                widthFactor: 1,
                child: IconTheme(
                  data: IconThemeData(color: fg),
                  child: DefaultTextStyle(
                    style: AppText.mono(size: 12.5, color: fg),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
