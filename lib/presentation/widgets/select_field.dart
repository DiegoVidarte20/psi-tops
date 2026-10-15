import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import 'field_label.dart';

/// Select con el estilo del diseño (components/ui/SelectField.tsx).
class SelectField<T> extends StatelessWidget {
  const SelectField({
    super.key,
    this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.compact = false,
    this.enabled = true,
  });

  final String? label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;
  final bool compact;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final style = AppText.sans(
      size: compact ? 13 : 14,
      color: enabled ? AppColors.ink : AppColors.inkFaint,
    );
    final box = Container(
      height: compact ? 32 : 40,
      padding: const EdgeInsets.only(left: 12, right: 10),
      decoration: BoxDecoration(
        color: enabled ? AppColors.white : AppColors.surface,
        border: Border.all(color: AppColors.lineStrong),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          style: style,
          borderRadius: BorderRadius.circular(6),
          dropdownColor: AppColors.white,
          focusColor: Colors.transparent,
          icon: const Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: AppColors.ink,
          ),
          onChanged: enabled
              ? (v) {
                  if (v != null) onChanged(v);
                }
              : null,
          items: [
            for (final e in options.entries)
              DropdownMenuItem<T>(
                value: e.key,
                child: Text(
                  e.value,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
          ],
        ),
      ),
    );
    if (label == null) return box;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [FieldLabel(label!), box],
    );
  }
}
