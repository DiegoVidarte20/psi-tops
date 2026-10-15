import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

/// Chip con checkbox (components/ui/ChipCheckbox.tsx).
class ChipCheckbox extends StatefulWidget {
  const ChipCheckbox({
    super.key,
    required this.label,
    required this.checked,
    required this.onChanged,
    this.color,
  });

  final String label;
  final bool checked;
  final VoidCallback onChanged;
  final Color? color;

  @override
  State<ChipCheckbox> createState() => _ChipCheckboxState();
}

class _ChipCheckboxState extends State<ChipCheckbox> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final checked = widget.checked;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        checked: checked,
        label: widget.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onChanged,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: checked
                  ? AppColors.primarySoft
                  : _hover
                  ? AppColors.surface
                  : AppColors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: checked ? AppColors.primary : AppColors.lineStrong,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
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
                      ? const Icon(
                          LucideIcons.check,
                          size: 12,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                if (widget.color != null) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(
                      size: 13,
                      weight: FontWeight.w600,
                      color: checked
                          ? AppColors.primaryStrong
                          : AppColors.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
