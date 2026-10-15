import 'package:flutter/material.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/format.dart';
import '../../layout/app_shell.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/responsive_grid.dart';
import 'logic/history_logic.dart';
import 'widgets/history_filter_panel.dart';
import 'widgets/production_bar_chart.dart';
import 'widgets/shift_hours_panel.dart';
import 'widgets/speed_history_chart.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => const AppShell(child: _HistoryBody());
}

class _HistoryBody extends StatefulWidget {
  const _HistoryBody();

  @override
  State<_HistoryBody> createState() => _HistoryBodyState();
}

class _HistoryBodyState extends State<_HistoryBody> {
  final _ctrl = HistoryController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        final series = _ctrl.loadedSeries;
        final n = series.length;
        final daily = buildDailyProduction(series);
        final totalProduction = daily.values.fold<int>(
          0,
          (sum, days) => sum + days.fold<int>(0, (a, b) => a + b),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(machinesCount: n),
            const SizedBox(height: 20),
            HistoryFilterPanel(ctrl: _ctrl),
            const SizedBox(height: 20),

            // KPIs: grid-cols-2 · md:3 · xl:5
            ResponsiveGrid(
              columns: context.isXl ? 5 : (context.isMd ? 3 : 2),
              gap: 12,
              children: [
                KpiCard(
                  label: 'Registros cargados',
                  value: formatNumber(
                    (recordsPerMachine[_ctrl.loadedGrouping] ?? 168) * n,
                  ),
                  sub:
                      'de ${formatNumber(60480 * n)} crudos · 7 días × $n máquinas',
                ),
                KpiCard(
                  label: 'Producción del rango',
                  value: formatNumber(totalProduction),
                  unit: 'm',
                  sub: n == 0 ? '—' : series.map((s) => s.name).join(' + '),
                ),
                KpiCard(
                  label: 'Vel. salida promedio',
                  value: n > 0 ? '179' : '—',
                  unit: 'm/min',
                  sub: 'máx. 191 · mín. en marcha 58',
                ),
                KpiCard(
                  label: 'Horas trabajo / pausa',
                  value: n > 0 ? formatNumber(149.2 * n, 1) : '—',
                  unit: '/ ${formatNumber(10.8 * n, 1)} h',
                  sub: 'Disponibilidad 93,2 %',
                ),
                KpiCard(
                  label: 'Paradas detectadas',
                  value: '${n * 7}',
                  valueColor: AppColors.stop,
                  sub: 'Más larga: 2 h 40 min · 09/10 T2',
                ),
              ],
            ),
            const SizedBox(height: 20),

            SpeedHistoryChart(series: series, loading: _ctrl.loading),
            const SizedBox(height: 20),

            // lg: [1.65fr | 1fr] · < lg: apilado
            if (context.isLg)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 165,
                    child: ProductionBarChart(series: series),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(flex: 100, child: ShiftHoursPanel()),
                ],
              )
            else ...[
              ProductionBarChart(series: series),
              const SizedBox(height: 20),
              const ShiftHoursPanel(),
            ],
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.machinesCount});

  final int machinesCount;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histórico y gráficas',
          style: AppText.sans(
            size: context.isSm ? 27 : 24,
            weight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Consulta de la base de datos (retención 5 años) · compare máquinas y variables en un rango de fechas',
          style: AppText.sans(size: 13.5, color: AppColors.inkMuted),
        ),
      ],
    );
    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        AppButton(
          label: 'Guardar vista',
          variant: AppButtonVariant.outline,
          onPressed: () => AppToast.success(
            context,
            'Vista guardada',
            description: 'Disponible en sus vistas guardadas.',
          ),
        ),
        AppButton(
          label: 'Exportar selección',
          onPressed: () => AppToast.success(
            context,
            'Exportación iniciada',
            description: '$machinesCount máquinas · Excel (.xlsx)',
          ),
        ),
      ],
    );

    if (context.isMd) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: title),
          const SizedBox(width: 16),
          actions,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [title, const SizedBox(height: 16), actions],
    );
  }
}
