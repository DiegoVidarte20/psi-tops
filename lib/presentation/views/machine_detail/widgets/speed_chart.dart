import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/chart_theme.dart';
import '../../../widgets/app_card.dart';
import '../logic/machine_series.dart';
import 'chart_helpers.dart';

/// "Velocidad de máquina (m/min)": salida vs alimentación.
class SpeedChart extends StatelessWidget {
  const SpeedChart({
    super.key,
    required this.series,
    required this.outLabel,
    required this.feedLabel,
  });

  final DetailSeries series;
  final String outLabel;
  final String feedLabel;

  @override
  Widget build(BuildContext context) {
    final pts = series.points;
    final last = pts.last;
    final max = pts.map((p) => p.out).reduce(math.max);
    final running = pts.where((p) => p.out > 0).map((p) => p.out).toList();
    final min = running.isEmpty ? 0 : running.reduce(math.min);
    final yMax = max > 100 ? 300.0 : 200.0;

    LineChartBarData line(List<FlSpot> spots, Color color) => LineChartBarData(
      spots: spots,
      color: color,
      barWidth: 2,
      isCurved: false,
      dotData: const FlDotData(show: false),
    );

    return AppCard(
      padding: EdgeInsets.all(context.isSm ? 18 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                'Velocidad de máquina (m/min)',
                style: AppText.sans(size: 15, weight: FontWeight.w700),
              ),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _LegendLine(color: AppColors.primary, label: outLabel),
                  _LegendLine(color: ChartTheme.feed, label: feedLabel),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: context.isSm ? 250 : 230,
            child: LineChart(
              duration: Duration.zero,
              LineChartData(
                minX: 0,
                maxX: (pts.length - 1).toDouble(),
                minY: 0,
                maxY: yMax,
                clipData: const FlClipData.all(),
                borderData: FlBorderData(show: false),
                gridData: horizontalGrid(interval: yMax / 3),
                titlesData:
                    chartTitles(
                      points: pts,
                      ticks: series.tickIndexes,
                      leftReserved: 36,
                      leftInterval: yMax / 3,
                      leftLabel: (v) => v.round().toString(),
                    ).copyWith(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          interval: yMax / 3,
                          getTitlesWidget: (value, meta) => SideTitleWidget(
                            meta: meta,
                            space: 6,
                            child: Text(
                              value.round().toString(),
                              style: ChartTheme.tick,
                            ),
                          ),
                        ),
                      ),
                    ),
                rangeAnnotations: stopAnnotation(series.stop),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.white,
                    tooltipBorder: const BorderSide(color: AppColors.line),
                    tooltipBorderRadius: BorderRadius.circular(6),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (spots) => [
                      for (var k = 0; k < spots.length; k++)
                        LineTooltipItem(
                          k == 0 ? '${pts[spots[k].x.round()].t}\n' : '',
                          AppText.mono(size: 12, color: AppColors.ink),
                          textAlign: TextAlign.left,
                          children: [
                            TextSpan(
                              text:
                                  '${spots[k].barIndex == 0 ? outLabel : feedLabel}: ${spots[k].y.round()} m/min',
                              style: AppText.mono(
                                size: 12,
                                color: spots[k].barIndex == 0
                                    ? AppColors.primary
                                    : ChartTheme.feed,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                lineBarsData: [
                  line([
                    for (var i = 0; i < pts.length; i++)
                      FlSpot(i.toDouble(), pts[i].out.toDouble()),
                  ], AppColors.primary),
                  line([
                    for (var i = 0; i < pts.length; i++)
                      FlSpot(i.toDouble(), pts[i].feed.toDouble()),
                  ], ChartTheme.feed),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            runSpacing: 4,
            children: [
              Text.rich(
                TextSpan(
                  style: _foot,
                  children: [
                    const TextSpan(text: 'Valor actual: '),
                    TextSpan(
                      text: '${last.out}',
                      style: _num(AppColors.primary),
                    ),
                    const TextSpan(text: ' / '),
                    TextSpan(
                      text: '${last.feed}',
                      style: _num(ChartTheme.feed),
                    ),
                    const TextSpan(text: ' m/min'),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  style: _foot,
                  children: [
                    const TextSpan(text: 'Máx. ventana: '),
                    TextSpan(text: '$max', style: _num(AppColors.ink)),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  style: _foot,
                  children: [
                    const TextSpan(text: 'Mín. en marcha: '),
                    TextSpan(text: '$min', style: _num(AppColors.ink)),
                  ],
                ),
              ),
              Text(
                'Muestreo: 1 s · registro en base de datos cada 10 s',
                style: _foot,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static final _foot = AppText.sans(size: 12, color: AppColors.inkMuted);
  static TextStyle _num(Color c) =>
      AppText.mono(size: 12, weight: FontWeight.w600, color: c);
}

class _LegendLine extends StatelessWidget {
  const _LegendLine({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppText.sans(size: 12.5, color: AppColors.inkMuted)),
      ],
    );
  }
}
