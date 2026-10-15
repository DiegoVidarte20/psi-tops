import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class AppTableColumn {
  const AppTableColumn(
    this.label, {
    this.alignRight = false,
    this.flex = false,
    this.header,
    this.padding,
  });

  final String label;
  final bool alignRight;

  /// true: esta columna absorbe el espacio sobrante.
  final bool flex;

  /// Encabezado personalizado (p. ej. checkbox "seleccionar todo").
  final Widget? header;

  /// Padding propio de la columna (si no, el de la tabla).
  final EdgeInsets? padding;
}

class AppTableRow {
  const AppTableRow(this.cells, {this.highlighted = false});
  final List<Widget> cells;
  final bool highlighted;
}

/// Tabla del diseño: encabezado gris (bg-surface), filas con borde superior,
/// ancho mínimo y scroll horizontal en pantallas angostas.
class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.minWidth,
    this.cellPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.headerPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    this.emptyMessage,
  });

  final List<AppTableColumn> columns;
  final List<AppTableRow> rows;
  final double minWidth;
  final EdgeInsets cellPadding;
  final EdgeInsets headerPadding;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    EdgeInsets padFor(int i, EdgeInsets base) {
      final p = columns[i].padding;
      return p == null ? base : base.copyWith(left: p.left, right: p.right);
    }

    Widget align(int i, Widget child) => Align(
      alignment: columns[i].alignRight
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: child,
    );

    final header = TableRow(
      decoration: const BoxDecoration(color: AppColors.surface),
      children: [
        for (var i = 0; i < columns.length; i++)
          Padding(
            padding: padFor(i, headerPadding),
            child: align(
              i,
              columns[i].header ??
                  Text(
                    columns[i].label.toUpperCase(),
                    softWrap: false,
                    style: AppText.overline(),
                  ),
            ),
          ),
      ],
    );

    final body = [
      for (final r in rows)
        TableRow(
          decoration: BoxDecoration(
            color: r.highlighted
                ? AppColors.primarySoft.withValues(alpha: 0.5)
                : null,
            border: const Border(top: BorderSide(color: AppColors.lineSoft)),
          ),
          children: [
            for (var i = 0; i < columns.length; i++)
              Padding(
                padding: padFor(i, cellPadding),
                child: align(i, r.cells[i]),
              ),
          ],
        ),
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, c) => Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: math.max(c.maxWidth, minWidth),
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: {
                      for (var i = 0; i < columns.length; i++)
                        i: columns[i].flex
                            ? const FlexColumnWidth()
                            : const IntrinsicColumnWidth(),
                    },
                    children: [header, ...body],
                  ),
                ),
              ),
            ),
          ),
          if (rows.isEmpty && emptyMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.lineSoft)),
              ),
              child: Text(
                emptyMessage!,
                textAlign: TextAlign.center,
                style: AppText.sans(size: 13, color: AppColors.inkMuted),
              ),
            ),
        ],
      ),
    );
  }
}

/// Píldora de estado pequeña ("Buena", "Activo"...).
class TablePill extends StatelessWidget {
  const TablePill(this.label, {super.key, this.bg, this.fg});

  final String label;
  final Color? bg;
  final Color? fg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: bg ?? AppColors.runSoft,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      softWrap: false,
      style: AppText.sans(
        size: 11,
        weight: FontWeight.w600,
        color: fg ?? AppColors.runStrong,
      ),
    ),
  );
}
