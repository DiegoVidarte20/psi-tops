import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import '../../core/state/plc_controller.dart';
import '../routes/app_routes.dart';

enum _Tone { ok, alert, plain }

class _Row {
  final String label;
  final String value;
  final _Tone tone;
  const _Row(this.label, this.value, [this.tone = _Tone.plain]);
}

/// Bloque de estado al pie del sidebar (cambia según la sección).
/// Datos en duro por ahora.
class SidebarStatus extends StatelessWidget {
  const SidebarStatus({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final plc = PlcScope.of(context);
    final connected = plc.connectedCount;
    final recording = plc.recording;
    final plcRow = _Row(
      'PLC conectados',
      '$connected / ${plc.devices.length}',
      connected > 0 ? _Tone.ok : _Tone.plain,
    );

    final List<_Row> rows;
    if (currentRoute.startsWith(AppRoutes.database)) {
      rows = const [
        _Row('Base de datos', 'En línea', _Tone.ok),
        _Row('Registros', '48,2 M'),
        _Row('Retención', '5 años'),
      ];
    } else if (currentRoute.startsWith(AppRoutes.connection)) {
      rows = [
        plcRow,
        _Row(
          'Grabado',
          recording ? 'Activo' : 'Detenido',
          recording ? _Tone.alert : _Tone.plain,
        ),
        _Row('Registros', formatNumber(plc.recordCount)),
      ];
    } else {
      rows = [
        plcRow,
        const _Row('Base de datos', 'En línea', _Tone.ok),
        const _Row('Último registro', 'hace 1 s'),
      ];
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.navy700,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    rows[i].label,
                    style: AppText.sans(
                      size: 12.5,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  rows[i].value,
                  softWrap: false,
                  style: AppText.mono(
                    size: 12.5,
                    weight: FontWeight.w500,
                    color: switch (rows[i].tone) {
                      _Tone.ok => AppColors.runBright,
                      _Tone.alert => AppColors.alertText,
                      _Tone.plain => Colors.white,
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
