import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/chart_theme.dart';
import '../../../../data/mock/history_data.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_toast.dart';
import '../logic/history_logic.dart';

const _tools = ['Zoom', 'Cursor de valor', 'Ver tabla', 'Descargar imagen'];

/// "Velocidad de salida (m/min) · promedio por hora" (7 días).
class SpeedHistoryChart extends StatelessWidget {
  const SpeedHistoryChart({
    super.key,
    required this.series,
    required this.loading,
  });

  final List<LoadedSeries> series;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final data = buildHourlySeries(series);
    final stops = activeStops(series);
    const none = AxisTitles(sideTitles: SideTitles(showTitles: false));

    return AppCard(
      padding: EdgeInsets.all(context.isSm ? 18 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Text(
                'Velocidad de salida (m/min) · promedio por hora · 07/10 – 14/10/2026',
                style: AppText.sans(size: 15, weight: FontWeight.w700),
              ),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final s in series)
                    _Legend(
                      label: s.name,
                      swatch: Container(width: 16, height: 2, color: s.color),
                    ),
                  _Legend(
                    label: 'Máquina detenida',
                    swatch: Container(
                      width: 16,
                      height: 12,
                      decoration: BoxDecoration(
                        color: ChartTheme.stopFill,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: context.isSm ? 300 : 260,
            child: Stack(
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: loading ? 0.4 : 1,
                  child: LineChart(
                    duration: Duration.zero,
                    LineChartData(
                      minX: 0,
                      maxX: 168,
                      minY: 0,
                      maxY: 300,
                      clipData: const FlClipData.all(),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: 100,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: ChartTheme.gridStroke,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: none,
                        rightTitles: none,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 24,
                            reservedSize: 24,
                            getTitlesWidget: (v, meta) => SideTitleWidget(
                              meta: meta,
                              space: 6,
                              fitInside: SideTitleFitInsideData.fromTitleMeta(
                                meta,
                              ),
                              child: Text(
                                historyDayLabels[(v / 24).round().clamp(
                                  0,
                                  historyDayLabels.length - 1,
                                )],
                                style: ChartTheme.tick,
                              ),
                            ),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 100,
                            reservedSize: 36,
                            getTitlesWidget: (v, meta) => SideTitleWidget(
                              meta: meta,
                              space: 6,
                              child: Text(
                                v.round().toString(),
                                style: ChartTheme.tick,
                              ),
                            ),
                          ),
                        ),
                      ),
                      rangeAnnotations: RangeAnnotations(
                        verticalRangeAnnotations: [
                          for (final s in stops)
                            VerticalRangeAnnotation(
                              x1: s.from.toDouble(),
                              x2: s.to.toDouble(),
                              color: ChartTheme.stopFill,
                            ),
                        ],
                      ),
                      lineTouchData: LineTouchData(
                        enabled: series.isNotEmpty,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppColors.white,
                          tooltipBorder: const BorderSide(
                            color: AppColors.line,
                          ),
                          tooltipBorderRadius: BorderRadius.circular(6),
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (spots) => [
                            for (var k = 0; k < spots.length; k++)
                              LineTooltipItem(
                                k == 0 ? '${_hourLabel(spots[k].x)}\n' : '',
                                AppText.mono(size: 12, color: AppColors.ink),
                                textAlign: TextAlign.left,
                                children: [
                                  TextSpan(
                                    text:
                                        '${series[spots[k].barIndex].name}: ${spots[k].y.round()} m/min',
                                    style: AppText.mono(
                                      size: 12,
                                      color: series[spots[k].barIndex].color,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      lineBarsData: [
                        for (final s in series)
                          LineChartBarData(
                            spots: [
                              for (var h = 0; h <= 168; h++)
                                FlSpot(h.toDouble(), data[s.id]![h].toDouble()),
                            ],
                            color: s.color,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                          ),
                      ],
                    ),
                  ),
                ),
                if (series.isEmpty)
                  Center(
                    child: Text(
                      'Seleccione máquinas y pulse «Cargar datos».',
                      style: AppText.sans(size: 13, color: AppColors.inkMuted),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Herramientas:',
                style: AppText.sans(size: 12.5, color: AppColors.inkMuted),
              ),
              for (final t in _tools)
                AppButton(
                  label: t,
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.outline,
                  onPressed: () => AppToast.info(
                    context,
                    t,
                    description: 'Herramienta aplicada a la gráfica.',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _hourLabel(double x) {
    final h = x.round();
    final day =
        historyDayLabels[(h ~/ 24).clamp(0, historyDayLabels.length - 1)];
    return '$day · ${(h % 24).toString().padLeft(2, '0')}:00';
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.label, required this.swatch});

  final String label;
  final Widget swatch;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      swatch,
      const SizedBox(width: 6),
      Text(label, style: AppText.sans(size: 12.5, color: AppColors.inkMuted)),
    ],
  );
}
