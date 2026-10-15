import 'package:flutter/material.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../data/mock/history_data.dart';
import '../../../../data/mock/lines_data.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_toast.dart';
import '../../../widgets/chip_checkbox.dart';
import '../../../widgets/field_label.dart';
import '../../../widgets/responsive_grid.dart';
import '../../../widgets/select_field.dart';
import '../../../widgets/date_time_field.dart';
import '../logic/history_logic.dart';

/// Panel "Filtros de consulta" (components/history/HistoryFilterPanel.tsx).
class HistoryFilterPanel extends StatelessWidget {
  const HistoryFilterPanel({super.key, required this.ctrl});

  final HistoryController ctrl;

  void _load(BuildContext context) {
    if (!ctrl.load()) {
      AppToast.error(context, 'Seleccione al menos una máquina para graficar');
    }
  }

  @override
  Widget build(BuildContext context) {
    // grid-cols-1 · sm:2 · lg:3 · xl:6
    final cols = context.isXl
        ? 6
        : context.isLg
        ? 3
        : context.isSm
        ? 2
        : 1;

    final fields = ResponsiveGrid(
      columns: cols,
      gap: 12,
      equalHeight: false,
      children: [
        DateTimeField(
          label: 'Desde',
          value: ctrl.from,
          firstDate: HistoryController.minDate,
          lastDate: ctrl.to,
          onChanged: ctrl.setFrom,
        ),
        DateTimeField(
          label: 'Hasta',
          value: ctrl.to,
          firstDate: ctrl.from,
          lastDate: HistoryController.maxDate,
          onChanged: ctrl.setTo,
        ),
        SelectField<int>(
          label: 'Línea',
          value: ctrl.line,
          options: {for (final l in productionLines) l.id: l.name},
          onChanged: ctrl.setLine,
        ),
        SelectField<TypeFilter>(
          label: 'Tipo de máquina',
          value: ctrl.machineType,
          options: const {
            TypeFilter.integrado: 'Integrado',
            TypeFilter.rompedora: 'Rompedora',
            TypeFilter.todos: 'Todos',
          },
          onChanged: ctrl.setMachineType,
        ),
        SelectField<String>(
          label: 'Turno',
          value: ctrl.shift,
          options: shiftOptions,
          onChanged: ctrl.setShift,
        ),
        SelectField<String>(
          label: 'Agrupación',
          value: ctrl.grouping,
          options: groupingOptions,
          onChanged: ctrl.setGrouping,
        ),
      ],
    );

    final machinesSet = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Máquinas a graficar', bottom: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in ctrl.lineMachines)
              ChipCheckbox(
                label: m.name,
                checked: ctrl.machines.contains(m.id),
                color: ctrl.colorFor(m.id),
                onChanged: () => ctrl.toggleMachine(m.id),
              ),
          ],
        ),
      ],
    );

    final variablesSet = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Variables a visualizar', bottom: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in historyVariables)
              ChipCheckbox(
                label: v.label,
                checked: ctrl.variables.contains(v.key),
                onChanged: () => ctrl.toggleVariable(v.key),
              ),
          ],
        ),
      ],
    );

    final loadBtn = AppButton(
      label: ctrl.loading ? 'Cargando' : 'Cargar datos',
      expand: true,
      icon: ctrl.loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : null,
      onPressed: ctrl.loading ? null : () => _load(context),
    );
    final clearBtn = AppButton(
      label: 'Limpiar filtros',
      variant: AppButtonVariant.outline,
      expand: true,
      onPressed: ctrl.clear,
    );

    final Widget bottom;
    if (context.isLg) {
      // lg: [máquinas 1fr] [variables 1.35fr] [botones apilados abajo]
      bottom = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 100, child: machinesSet),
            const SizedBox(width: 20),
            Expanded(flex: 135, child: variablesSet),
            const SizedBox(width: 20),
            SizedBox(
              width: 126,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [loadBtn, const SizedBox(height: 8), clearBtn],
              ),
            ),
          ],
        ),
      );
    } else {
      bottom = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          machinesSet,
          const SizedBox(height: 20),
          variablesSet,
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: loadBtn),
              const SizedBox(width: 8),
              Expanded(child: clearBtn),
            ],
          ),
        ],
      );
    }

    return AppCard(
      padding: EdgeInsets.all(context.isSm ? 18 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [fields, const SizedBox(height: 16), bottom],
      ),
    );
  }
}
