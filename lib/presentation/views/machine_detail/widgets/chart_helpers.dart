import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/chart_theme.dart';
import '../logic/machine_series.dart';

/// Solo líneas horizontales (CartesianGrid vertical={false}).
FlGridData horizontalGrid({required double interval}) => FlGridData(
  show: true,
  drawVerticalLine: false,
  horizontalInterval: interval,
  getDrawingHorizontalLine: (_) =>
      const FlLine(color: ChartTheme.gridStroke, strokeWidth: 1),
);

/// Ejes: X con 5 horas (índices 0,15,30,45,60) e Y a la izquierda.
FlTitlesData chartTitles({
  required List<DetailPoint> points,
  required List<int> ticks,
  required double leftReserved,
  required double leftInterval,
  required String Function(double value) leftLabel,
}) {
  const none = AxisTitles(sideTitles: SideTitles(showTitles: false));
  return FlTitlesData(
    topTitles: none,
    rightTitles: none,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 24,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final i = value.round();
          if (value != i.toDouble() ||
              !ticks.contains(i) ||
              i >= points.length) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            meta: meta,
            space: 6,
            fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
            child: Text(points[i].t, style: ChartTheme.tick),
          );
        },
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: leftReserved,
        interval: leftInterval,
        minIncluded: true,
        maxIncluded: false,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          meta: meta,
          space: 6,
          child: Text(leftLabel(value), style: ChartTheme.tick),
        ),
      ),
    ),
  );
}

/// Franja roja de la parada (ReferenceArea).
RangeAnnotations stopAnnotation(StopWindow? stop) => RangeAnnotations(
  verticalRangeAnnotations: [
    if (stop != null)
      VerticalRangeAnnotation(
        x1: stop.fromIndex.toDouble(),
        x2: stop.toIndex.toDouble(),
        color: ChartTheme.stopFill,
      ),
  ],
);
