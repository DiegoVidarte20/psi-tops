import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/format.dart';
import '../../../../data/mock/database_data.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_checkbox.dart';
import '../../../widgets/app_toast.dart';
import '../../../widgets/select_field.dart';
import '../../../widgets/text_link.dart';
import '../logic/database_controller.dart';

/// "Columnas a exportar / visualizar" + "Exportar" (dos tarjetas).
class ExportPanel extends StatelessWidget {
  const ExportPanel({super.key, required this.ctrl});

  final DatabaseController ctrl;

  @override
  Widget build(BuildContext context) {
    final columnsCard = AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Columnas a exportar / visualizar',
            style: AppText.sans(size: 14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final c in exportColumns)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ctrl.toggleExportCol(c.key),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      AppCheckbox(checked: ctrl.exportCols.contains(c.key)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(c.label, style: AppText.sans(size: 13)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        c.key,
                        style: AppText.mono(
                          size: 11,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            children: [
              TextLink(
                label: 'Seleccionar todo',
                size: 12.5,
                bold: true,
                onTap: () => ctrl.setAllExportCols(true),
              ),
              TextLink(
                label: 'Ninguna',
                size: 12.5,
                color: AppColors.inkMuted,
                hoverColor: AppColors.ink,
                underline: false,
                onTap: () => ctrl.setAllExportCols(false),
              ),
            ],
          ),
        ],
      ),
    );

    final exportCard = AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Exportar',
            style: AppText.sans(size: 14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SelectField<String>(
            label: 'Formato',
            value: ctrl.format,
            options: const {
              'xlsx': 'Excel (.xlsx)',
              'csv': 'CSV (.csv)',
              'pdf': 'PDF (.pdf)',
            },
            onChanged: ctrl.setFormat,
          ),
          const SizedBox(height: 12),
          SelectField<String>(
            label: 'Alcance',
            value: ctrl.scope,
            options: {
              'filtrado':
                  'Resultado filtrado (${formatNumber(ctrl.filteredCount)} registros)',
              'seleccion': 'Filas seleccionadas (${ctrl.selected.length})',
              'pagina': 'Página actual',
            },
            onChanged: ctrl.setScope,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Exportar datos de fecha a fecha',
            variant: AppButtonVariant.success,
            expand: true,
            onPressed: ctrl.exportCols.isEmpty
                ? null
                : () => AppToast.success(
                    context,
                    'Exportación en curso',
                    description:
                        '${ctrl.exportCols.length} columnas · ${ctrl.format.toUpperCase()}',
                  ),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Cargar selección en gráfica',
            variant: AppButtonVariant.outlinePrimary,
            expand: true,
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.history),
          ),
          const SizedBox(height: 12),
          Text(
            'Última exportación: 13/10/2026 17:42 · Integrado 1A · Excel · 9 columnas',
            style: AppText.sans(
              size: 11.5,
              color: AppColors.inkMuted,
              height: 1.375,
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [columnsCard, const SizedBox(height: 20), exportCard],
    );
  }
}
