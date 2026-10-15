import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';

/// `.checkbox` del diseño (16 px, accent primary).
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.checked,
    this.onChanged,
    this.semanticLabel,
  });

  final bool checked;
  final VoidCallback? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: checked ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: checked ? AppColors.primary : AppColors.lineStrong,
        ),
      ),
      child: checked
          ? const Icon(LucideIcons.check, size: 12, color: Colors.white)
          : null,
    );
    if (onChanged == null) return box;
    return Semantics(
      checked: checked,
      label: semanticLabel,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onChanged,
          // área táctil más grande que el cuadrito
          child: Padding(padding: const EdgeInsets.all(4), child: box),
        ),
      ),
    );
  }
}
