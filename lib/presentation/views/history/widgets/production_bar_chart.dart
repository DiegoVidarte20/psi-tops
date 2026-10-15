import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/chart_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../data/mock/history_data.dart';
import '../../../widgets/app_card.dart';
import '../logic/history_logic.dart';

/// "Producción por día (m)" — barras agrupadas por máquina.
class ProductionBarChart extends StatelessWidget {
  const ProductionBarChart({super.key, required this.series});

  final List<LoadedSeries> series;

  static const _leftReserved = 52.0;

  @override
  Widget build(BuildContext context) {
    final data = buildDailyProduction(series);
    final prefix = series.isEmpty ? '' : series.first.name.split(' ').first;
    final names = series.isEmpty
        ? '—'
        : series
              .map(
                (s) =>
                    s.name.replaceFirst(RegExp(r'^(Integrado|Rompedora) '), ''),
              )
              .join(' vs ');
    const none = AxisTitles(sideTitles: SideTitles(showTitles: false));

    return AppCard(
      padding: EdgeInsets.all(context.isSm ? 18 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Producción por día (m) · ${prefix.isEmpty ? '' : '$prefix '}$names',
            style: AppText.sans(size: 15, weight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            // Ancho de barra como recharts (maxBarSize 24, barGap 6)
            child: LayoutBuilder(
              builder: (context, c) {
                final n = math.max(1, series.length);
                final group = (c.maxWidth - _leftReserved) / 7;
                final rodW = math
                    .min(24.0, (group * 0.8 - 6 * (n - 1)) / n)
                    .clamp(4.0, 24.0);
                return BarChart(
                  duration: Duration.zero,
                  BarChartData(
                    minY: 0,
                    maxY: 30000,
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      horizontalInterval: 15000,
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
                          reservedSize: 24,
                          getTitlesWidget: (v, meta) => SideTitleWidget(
                            meta: meta,
                            space: 6,
                            child: Text(
                              historyDayLabels[v.toInt()],
                              style: ChartTheme.tick,
                            ),
                          ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: _leftReserved,
                          interval: 15000,
                          getTitlesWidget: (v, meta) => SideTitleWidget(
                            meta: meta,
                            space: 6,
                            child: Text(
                              formatNumber(v),
                              style: ChartTheme.tick,
                            ),
                          ),
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      enabled: series.isNotEmpty,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.white,
                        tooltipBorder: const BorderSide(color: AppColors.line),
                        tooltipBorderRadius: BorderRadius.circular(6),
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                          '${historyDayLabels[group.x]}\n',
                          AppText.mono(size: 12, color: AppColors.ink),
                          textAlign: TextAlign.left,
                          children: [
                            TextSpan(
                              text:
                                  '${series[ri].name}: ${formatNumber(rod.toY)} m',
                              style: AppText.mono(
                                size: 12,
                                color: series[ri].color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var d = 0; d < 7; d++)
                        BarChartGroupData(
                          x: d,
                          barsSpace: 6,
                          barRods: [
                            for (final s in series)
                              BarChartRodData(
                                toY: data[s.id]![d].toDouble(),
                                color: s.color,
                                width: rodW,
                                borderRadius: BorderRadius.zero,
                              ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
