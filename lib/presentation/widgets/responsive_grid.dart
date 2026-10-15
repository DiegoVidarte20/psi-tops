import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Grid tipo CSS (`grid grid-cols-N gap-X`) sin LayoutBuilder:
/// - columnas del mismo ancho (Expanded + flex)
/// - tarjetas de una misma fila con la misma altura (stretch)
/// - soporte de `col-span` mediante [span].
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.columns,
    required this.children,
    this.gap = 12,
    this.rowGap,
    this.span,
    this.equalHeight = true,
  });

  final int columns;
  final List<Widget> children;
  final double gap;
  final double? rowGap;
  final int Function(int index)? span;

  /// true: todas las celdas de una fila con la misma altura (IntrinsicHeight).
  /// false: alineadas arriba (para formularios, inputs, etc.).
  final bool equalHeight;

  @override
  Widget build(BuildContext context) {
    final cols = math.max(1, columns);
    final rows = <Widget>[];
    var cells = <Widget>[];
    var used = 0;

    void addCell(Widget child, int s) {
      if (cells.isNotEmpty) cells.add(SizedBox(width: gap));
      // Un ítem con span = columns ocupa la fila completa (igual que col-span-full).
      cells.add(Expanded(flex: s, child: child));
      used += s;
    }

    void flush() {
      if (cells.isEmpty) return;
      // Rellena columnas vacías para que el ancho sea igual al de filas completas.
      while (used < cols) {
        cells.add(SizedBox(width: gap));
        cells.add(const Expanded(child: SizedBox.shrink()));
        used++;
      }
      final row = Row(
        crossAxisAlignment: equalHeight
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.start,
        children: cells,
      );
      rows.add(equalHeight ? IntrinsicHeight(child: row) : row);
      cells = <Widget>[];
      used = 0;
    }

    for (var i = 0; i < children.length; i++) {
      final s = math.min(cols, math.max(1, span?.call(i) ?? 1));
      if (used + s > cols) flush();
      addCell(children[i], s);
    }
    flush();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: rowGap ?? gap),
          rows[i],
        ],
      ],
    );
  }
}
