import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import 'field_label.dart';

/// `.text-input` (h-10, borde line-strong, foco primary).
class TextInputField extends StatelessWidget {
  const TextInputField({
    super.key,
    this.label,
    this.controller,
    this.hint,
    this.mono = false,
    this.prefixIcon,
    this.onChanged,
    this.height = 40,
    this.fontSize = 14,
  });

  final String? label;
  final TextEditingController? controller;
  final String? hint;
  final bool mono;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final double height;
  final double fontSize;

  static OutlineInputBorder _border(Color c, [double w = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: c, width: w),
      );

  @override
  Widget build(BuildContext context) {
    final style = mono
        ? AppText.mono(size: fontSize)
        : AppText.sans(size: fontSize);
    final field = SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: style,
        // expands: el borde ocupa todo el alto (igual que SelectField)
        expands: true,
        maxLines: null,
        minLines: null,
        cursorColor: AppColors.primary,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.white,
          hintText: hint,
          hintStyle: style.copyWith(color: AppColors.inkFaint),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 16, color: AppColors.inkFaint)
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 32),
          enabledBorder: _border(AppColors.lineStrong),
          border: _border(AppColors.lineStrong),
          focusedBorder: _border(AppColors.primary, 1.5),
        ),
      ),
    );
    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [FieldLabel(label!), field],
    );
  }
}
