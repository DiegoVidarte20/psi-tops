import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/state/plc_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/format.dart';
import '../../../../data/mock/plc_data.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_data_table.dart';
import '../../../widgets/select_field.dart';

const _visible = 15;

/// "Registro de grabado": últimas lecturas guardadas en registros_plc.
class RecordingLog extends StatelessWidget {
  const RecordingLog({super.key});

  @override
  Widget build(BuildContext context) {
    final plc = PlcScope.of(context);
    final rows = plc.log.take(_visible).toList();
    final pad = context.isSm ? 18.0 : 16.0;

    final pill = plc.recording
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.stopSoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.stop,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Grabando · ',
                  style: AppText.sans(
                    size: 11.5,
                    weight: FontWeight.w600,
                    color: AppColors.stopStrong,
                  ),
                ),
                Text(
                  formatDuration(plc.elapsed),
                  style: AppText.mono(
                    size: 11.5,
                    weight: FontWeight.w600,
                    color: AppColors.stopStrong,
                  ),
                ),
              ],
            ),
          )
        : const TablePill(
            'Detenido',
            bg: AppColors.offlineSoft,
            fg: AppColors.offlineStrong,
          );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            Text(
              'Registro de grabado',
              style: AppText.sans(size: 15, weight: FontWeight.w700),
            ),
            pill,
          ],
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            style: AppText.sans(size: 12.5, color: AppColors.inkMuted),
            children: [
              const TextSpan(text: 'Destino: base de datos · tabla '),
              TextSpan(
                text: 'registros_plc',
                style: AppText.mono(size: 12.5, color: AppColors.inkMuted),
              ),
              const TextSpan(text: ' · datos simulados'),
            ],
          ),
        ),
      ],
    );

    final sampling = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Muestreo',
          style: AppText.sans(size: 12.5, color: AppColors.inkMuted),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 92,
          child: SelectField<int>(
            compact: true,
            enabled: !plc.recording,
            value: plc.interval,
            options: const {1: '1 s', 5: '5 s', 10: '10 s', 30: '30 s'},
            onChanged: plc.setInterval,
          ),
        ),
      ],
    );

    final text = AppText.sans(size: 12.5);

    return AppCard(
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(pad),
            child: context.isSm
                ? Row(
                    children: [
                      Expanded(child: info),
                      const SizedBox(width: 12),
                      sampling,
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [info, const SizedBox(height: 12), sampling],
                  ),
          ),
          if (rows.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Column(
                children: [
                  const Icon(
                    LucideIcons.database,
                    size: 28,
                    color: AppColors.inkFaint,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    plc.recording
                        ? 'Esperando la primera muestra…'
                        : 'Aún no hay datos grabados',
                    textAlign: TextAlign.center,
                    style: AppText.sans(size: 14, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 384),
                    child: Text(
                      plc.recording
                          ? 'La primera lectura se guardará en ${plc.interval} s.'
                          : 'Conecte uno o más PLC, marque los datos que desea guardar y pulse «Iniciar grabado».',
                      textAlign: TextAlign.center,
                      style: AppText.sans(
                        size: 12.5,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            AppDataTable(
              minWidth: 760,
              cellPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              headerPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              columns: [
                AppTableColumn(
                  'Hora',
                  padding: EdgeInsets.only(left: pad, right: 12),
                ),
                const AppTableColumn('PLC'),
                const AppTableColumn('Máquina'),
                const AppTableColumn('Variable', flex: true),
                const AppTableColumn('Dirección'),
                const AppTableColumn('Valor', alignRight: true),
                AppTableColumn(
                  'Unidad',
                  padding: EdgeInsets.only(left: 12, right: pad),
                ),
              ],
              rows: [
                for (final e in rows)
                  AppTableRow([
                    Text(
                      e.time,
                      softWrap: false,
                      style: AppText.mono(size: 12.5, weight: FontWeight.w500),
                    ),
                    Text(
                      e.plc,
                      softWrap: false,
                      style: text.copyWith(color: AppColors.inkMuted),
                    ),
                    Text(
                      e.machine,
                      softWrap: false,
                      style: text.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(e.variable, softWrap: false, style: text),
                    Text(
                      e.address,
                      softWrap: false,
                      style: AppText.mono(
                        size: 11.5,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    Text(
                      formatTagValue(e.value, e.dataType, e.decimals),
                      softWrap: false,
                      style: AppText.mono(size: 12.5, weight: FontWeight.w600),
                    ),
                    Text(
                      e.unit,
                      softWrap: false,
                      style: text.copyWith(color: AppColors.inkMuted),
                    ),
                  ]),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Text(
                'Mostrando los últimos ${rows.length} de ${formatNumber(plc.recordCount)} registros grabados en esta sesión',
                style: AppText.sans(size: 12, color: AppColors.inkMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
