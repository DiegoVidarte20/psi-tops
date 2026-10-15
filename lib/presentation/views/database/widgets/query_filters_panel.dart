import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/format.dart';
import '../../../../data/mock/database_data.dart';
import '../../../../data/mock/history_data.dart';
import '../../../../data/mock/lines_data.dart';
import '../../../../data/mock/machines_data.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_toast.dart';
import '../../../widgets/date_time_field.dart';
import '../../../widgets/select_field.dart';
import '../logic/database_controller.dart';

/// "Filtros de consulta" (components/database/QueryFiltersPanel.tsx).
class QueryFiltersPanel extends StatelessWidget {
  const QueryFiltersPanel({super.key, required this.ctrl});

  final DatabaseController ctrl;

  @override
  Widget build(BuildContext context) {
    final f = ctrl.draft;
    final minDate = DateTime(dataNow.year - 5, dataNow.month, dataNow.day);
    final maxDate = DateTime.now().add(const Duration(days: 1));

    Widget gap([double h = 12]) => SizedBox(height: h);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filtros de consulta',
            style: AppText.sans(size: 14, weight: FontWeight.w700),
          ),
          gap(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DateTimeField(
                  label: 'Fecha desde',
                  compact: true,
                  value: f.from,
                  firstDate: minDate,
                  lastDate: f.to,
                  onChanged: (v) => ctrl.updateDraft((d) {
                    d.from = v;
                    d.range = null;
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DateTimeField(
                  label: 'Fecha hasta',
                  compact: true,
                  value: f.to,
                  firstDate: f.from,
                  lastDate: maxDate,
                  onChanged: (v) => ctrl.updateDraft((d) {
                    d.to = v;
                    d.range = null;
                  }),
                ),
              ),
            ],
          ),
          gap(10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final r in quickRanges)
                _RangeChip(
                  label: r,
                  active: f.range == r,
                  onTap: () => ctrl.setQuickRange(r),
                ),
            ],
          ),
          gap(),
          SelectField<String>(
            label: 'Línea',
            value: f.line,
            options: {
              'todas': 'Todas las líneas',
              for (final l in productionLines) '${l.id}': l.name,
            },
            onChanged: (v) => ctrl.updateDraft((d) => d.line = v),
          ),
          gap(),
          SelectField<String>(
            label: 'Máquina',
            value: f.machine,
            options: {
              'todas': 'Todas las máquinas',
              for (final m in machines) m.id: m.name,
            },
            onChanged: (v) => ctrl.updateDraft((d) => d.machine = v),
          ),
          gap(),
          SelectField<String>(
            label: 'Variable',
            value: f.variable,
            options: {
              'todas': 'Todas las variables',
              for (final v in historyVariables) v.key: v.label,
            },
            onChanged: (v) => ctrl.updateDraft((d) => d.variable = v),
          ),
          gap(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectField<String>(
                  label: 'Turno',
                  value: f.shift,
                  options: const {
                    'todos': 'Todos',
                    'T1': 'T1',
                    'T2': 'T2',
                    'T3': 'T3',
                  },
                  onChanged: (v) => ctrl.updateDraft((d) => d.shift = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SelectField<String>(
                  label: 'Estado',
                  value: f.state,
                  options: const {
                    'cualquiera': 'Cualquiera',
                    'marcha': 'En marcha',
                    'detenida': 'Detenida',
                  },
                  onChanged: (v) => ctrl.updateDraft((d) => d.state = v),
                ),
              ),
            ],
          ),
          gap(16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Aplicar filtros',
                  expand: true,
                  onPressed: () {
                    final n = ctrl.applyFilters();
                    AppToast.success(
                      context,
                      'Filtros aplicados',
                      description: '${formatNumber(n)} registros encontrados.',
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              AppButton(
                label: 'Limpiar',
                variant: AppButtonVariant.outline,
                onPressed: ctrl.clearFilters,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatefulWidget {
  const _RangeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_RangeChip> createState() => _RangeChipState();
}

class _RangeChipState extends State<_RangeChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        button: true,
        selected: a,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: a
                  ? AppColors.primarySoft
                  : _hover
                  ? AppColors.surface
                  : AppColors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: a ? AppColors.primary : AppColors.lineStrong,
              ),
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                widget.label,
                style: AppText.sans(
                  size: 11.5,
                  weight: FontWeight.w600,
                  color: a ? AppColors.primaryStrong : AppColors.inkMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
