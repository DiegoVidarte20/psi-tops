import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/format.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_checkbox.dart';
import '../../../widgets/app_data_table.dart';
import '../../../widgets/app_toast.dart';
import '../../../widgets/pagination_bar.dart';
import '../../../widgets/select_field.dart';
import '../../../widgets/text_input_field.dart';
import '../logic/database_controller.dart';

/// "Tabla de registros" con búsqueda, selección y paginación real.
class RecordsTable extends StatefulWidget {
  const RecordsTable({super.key, required this.ctrl});

  final DatabaseController ctrl;

  @override
  State<RecordsTable> createState() => _RecordsTableState();
}

class _RecordsTableState extends State<RecordsTable> {
  late final _search = TextEditingController(text: widget.ctrl.query);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    final rows = ctrl.pageRows;
    final total = ctrl.visibleRows.length;

    final text = AppText.sans(size: 12.5);
    final mono = AppText.mono(size: 12.5);

    final columns = [
      AppTableColumn(
        '',
        padding: const EdgeInsets.only(left: 12, right: 4),
        header: AppCheckbox(
          checked: ctrl.pageAllSelected,
          onChanged: ctrl.togglePage,
          semanticLabel: 'Seleccionar todas las filas de la página',
        ),
      ),
      const AppTableColumn('ID'),
      const AppTableColumn('Fecha / hora'),
      const AppTableColumn('Línea'),
      const AppTableColumn('Máquina'),
      const AppTableColumn('Variable', flex: true),
      const AppTableColumn('Valor', alignRight: true),
      const AppTableColumn('Unidad'),
      const AppTableColumn('Turno'),
      const AppTableColumn(
        'Calidad',
        padding: EdgeInsets.only(left: 12, right: 16),
      ),
    ];

    final tableRows = [
      for (final r in rows)
        AppTableRow(highlighted: ctrl.selected.contains(r.id), [
          AppCheckbox(
            checked: ctrl.selected.contains(r.id),
            onChanged: () => ctrl.toggleRow(r.id),
            semanticLabel: 'Seleccionar registro ${r.id}',
          ),
          Text(
            formatNumber(r.id),
            softWrap: false,
            style: mono.copyWith(color: AppColors.inkMuted),
          ),
          Text(
            r.timeLabel,
            softWrap: false,
            style: mono.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            r.line,
            softWrap: false,
            style: text.copyWith(color: AppColors.inkMuted),
          ),
          Text(
            r.machine,
            softWrap: false,
            style: text.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(r.variable, softWrap: false, style: text),
          Text(
            formatNumber(r.value, r.decimals),
            softWrap: false,
            style: mono.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            r.unit,
            softWrap: false,
            style: text.copyWith(color: AppColors.inkMuted),
          ),
          Text(r.shift, softWrap: false, style: text),
          r.goodQuality
              ? const TablePill('Buena')
              : const TablePill(
                  'Dudosa',
                  bg: AppColors.pauseSoft,
                  fg: AppColors.pauseStrong,
                ),
        ]),
    ];

    return AppCard(
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Text(
                      'Tabla de registros',
                      style: AppText.sans(size: 14, weight: FontWeight.w700),
                    ),
                    Text(
                      '${formatNumber(total)} registros filtrados · mostrando ${ctrl.rangeLabel} · ordenado por fecha/hora desc.',
                      style: AppText.sans(size: 12, color: AppColors.inkMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: context.isSm ? 240 : double.infinity,
                      child: TextInputField(
                        controller: _search,
                        hint: 'Buscar valor, tag, máquina…',
                        prefixIcon: LucideIcons.search,
                        height: 36,
                        fontSize: 13,
                        onChanged: ctrl.setQuery,
                      ),
                    ),
                    AppButton(
                      label: 'Columnas',
                      size: AppButtonSize.sm,
                      height: 36,
                      variant: AppButtonVariant.outline,
                      onPressed: () => AppToast.info(
                        context,
                        'Columnas',
                        description:
                            'Use el panel «Columnas a exportar» para elegir.',
                      ),
                    ),
                    AppButton(
                      label: 'Actualizar',
                      size: AppButtonSize.sm,
                      height: 36,
                      variant: AppButtonVariant.outline,
                      onPressed: () =>
                          AppToast.success(context, 'Tabla actualizada'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppDataTable(
            minWidth: 920,
            columns: columns,
            rows: tableRows,
            cellPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            headerPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            emptyMessage: ctrl.query.trim().isEmpty
                ? 'Ningún registro coincide con los filtros aplicados.'
                : 'Ningún registro coincide con «${ctrl.query.trim()}».',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Filas por página',
                      style: AppText.sans(
                        size: 12.5,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 76,
                      child: SelectField<int>(
                        compact: true,
                        value: ctrl.perPage,
                        options: const {25: '25', 50: '50', 100: '100'},
                        onChanged: ctrl.setPerPage,
                      ),
                    ),
                  ],
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: PaginationBar(
                    page: ctrl.page,
                    pageCount: ctrl.pageCount,
                    onPage: ctrl.setPage,
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
