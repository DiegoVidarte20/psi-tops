import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import 'field_label.dart';

String formatDateTime(DateTime d) =>
    '${pad2(d.day)}/${pad2(d.month)}/${d.year} ${pad2(d.hour)}:${pad2(d.minute)}';

/// Campo de fecha + hora con el mismo alto/borde que [SelectField].
/// Al tocarlo abre el calendario y luego el reloj (24 h).
class DateTimeField extends StatefulWidget {
  const DateTimeField({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.compact = false,
  });

  final String? label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;

  /// h-9 · px-2 · 12px · sin ícono (columnas angostas).
  final bool compact;

  @override
  State<DateTimeField> createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends State<DateTimeField> {
  bool _hover = false;
  bool _open = false;

  Widget _pickerTheme(BuildContext context, Widget? child) => Theme(
    data: Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.white,
        onSurface: AppColors.ink,
      ),
    ),
    child: MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );

  Future<void> _pick() async {
    setState(() => _open = true);
    final first = widget.firstDate;
    final last = widget.lastDate;
    var initial = widget.value;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(first.year, first.month, first.day),
      lastDate: last,
      helpText: widget.label ?? 'Seleccione fecha',
      cancelText: 'Cancelar',
      confirmText: 'Siguiente',
      builder: _pickerTheme,
    );
    if (!mounted || date == null) {
      setState(() => _open = false);
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.value),
      helpText: 'Seleccione hora',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: _pickerTheme,
    );
    if (!mounted) return;
    setState(() => _open = false);
    if (time == null) return;

    var result = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    // Respeta los límites (p. ej. "Hasta" no puede ser antes que "Desde").
    if (result.isBefore(first)) result = first;
    if (result.isAfter(last)) result = last;
    widget.onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final focused = _open;
    final box = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        button: true,
        label: '${widget.label ?? 'Fecha'}: ${formatDateTime(widget.value)}',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _pick,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: widget.compact ? 36 : 40,
            padding: widget.compact
                ? const EdgeInsets.symmetric(horizontal: 8)
                : const EdgeInsets.only(left: 12, right: 10),
            decoration: BoxDecoration(
              color: _hover && !focused ? AppColors.surface : AppColors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: focused ? AppColors.primary : AppColors.lineStrong,
              ),
              boxShadow: focused
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: widget.compact
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatDateTime(widget.value),
                        style: AppText.mono(size: 12),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatDateTime(widget.value),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.mono(size: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        LucideIcons.calendar,
                        size: 16,
                        color: AppColors.ink,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
    if (widget.label == null) return box;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [FieldLabel(widget.label!), box],
    );
  }
}
