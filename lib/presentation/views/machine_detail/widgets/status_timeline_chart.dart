import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../widgets/app_card.dart';
import '../logic/machine_series.dart';
import 'chart_helpers.dart';

/// "Estado de máquina · encendido / apagado" + selector de rango.
class StatusTimelineChart extends StatelessWidget {
  const StatusTimelineChart({
    super.key,
    required this.series,
    required this.range,
    required this.onRange,
  });

  final DetailSeries series;
  final RangeKey range;
  final ValueChanged<RangeKey> onRange;

  static const _leftReserved = 36.0;

  @override
  Widget build(BuildContext context) {
    final stop = series.stop;
    final spots = [
      for (var i = 0; i < series.points.length; i++)
        FlSpot(i.toDouble(), series.points[i].on.toDouble()),
    ];

    return AppCard(
      padding: EdgeInsets.all(context.isSm ? 18 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Text(
                'Estado de máquina · encendido / apagado',
                style: AppText.sans(size: 15, weight: FontWeight.w700),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final r in RangeKey.values)
                    _RangeButton(
                      label: r.label,
                      active: r == range,
                      onTap: () => onRange(r),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: Stack(
              children: [
                LineChart(
                  duration: Duration.zero,
                  LineChartData(
                    minX: 0,
                    maxX: (series.points.length - 1).toDouble(),
                    minY: 0,
                    maxY: 1.12,
                    clipData: const FlClipData.all(),
                    borderData: FlBorderData(show: false),
                    gridData: horizontalGrid(interval: 1),
                    lineTouchData: const LineTouchData(enabled: false),
                    titlesData: chartTitles(
                      points: series.points,
                      ticks: series.tickIndexes,
                      leftReserved: _leftReserved,
                      leftInterval: 1,
                      leftLabel: (v) => v == 0
                          ? 'OFF'
                          : v == 1
                          ? 'ON'
                          : '',
                    ),
                    rangeAnnotations: stopAnnotation(stop),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isStepLineChart: true,
                        lineChartStepData: const LineChartStepData(
                          stepDirection: LineChartStepData.stepDirectionForward,
                        ),
                        color: AppColors.run,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.runSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                if (stop != null)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: _leftReserved,
                        bottom: 24,
                      ),
                      child: Align(
                        alignment: Alignment(
                          ((stop.fromIndex + stop.toIndex) /
                                      2 /
                                      (series.points.length - 1)) *
                                  2 -
                              1,
                          -1,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'parada ${stop.minutes} min',
                            style: AppText.sans(
                              size: 11,
                              color: AppColors.stop,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeButton extends StatefulWidget {
  const _RangeButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_RangeButton> createState() => _RangeButtonState();
}

class _RangeButtonState extends State<_RangeButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        button: true,
        selected: active,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary
                  : _hover
                  ? AppColors.surface
                  : AppColors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.lineStrong,
              ),
            ),
            // widthFactor: 1 -> el botón mide lo que su texto, no todo el ancho
            child: Center(
              widthFactor: 1,
              child: Text(
                widget.label,
                style: AppText.sans(
                  size: 12.5,
                  weight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
