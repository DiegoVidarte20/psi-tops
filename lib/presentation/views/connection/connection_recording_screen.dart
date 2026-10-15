import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/state/plc_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/format.dart';
import '../../layout/app_shell.dart';
import '../../widgets/app_button.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/responsive_grid.dart';
import 'widgets/plc_detail.dart';
import 'widgets/plc_list.dart';
import 'widgets/recording_log.dart';

class ConnectionRecordingScreen extends StatelessWidget {
  const ConnectionRecordingScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const AppShell(child: _ConnectionBody());
}

class _ConnectionBody extends StatefulWidget {
  const _ConnectionBody();

  @override
  State<_ConnectionBody> createState() => _ConnectionBodyState();
}

class _ConnectionBodyState extends State<_ConnectionBody> {
  String _selectedId = 'l1-int';
  final _detailKey = GlobalKey();

  void _select(String id) {
    setState(() => _selectedId = id);
    // En móvil/tablet el detalle está debajo: baja hasta él.
    if (!context.isLg) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _detailKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plc = PlcScope.of(context);
    final n = plc.devices.length;
    final recordable = plc.recordableCount;

    final header = _Header(plc: plc);

    final kpis = ResponsiveGrid(
      columns: context.isXl ? 5 : (context.isMd ? 3 : 2),
      gap: 12,
      children: [
        KpiCard(
          label: 'PLC conectados',
          value: '${plc.connectedCount}',
          unit: '/ $n',
          valueColor: plc.connectedCount > 0 ? AppColors.run : AppColors.ink,
          sub: plc.errorCount > 0
              ? '${plc.errorCount} sin respuesta · revisar red'
              : plc.connectingCount > 0
              ? '${plc.connectingCount} conectando…'
              : 'Red 192.168.10.0/24',
          subColor: plc.errorCount > 0 ? AppColors.stop : AppColors.inkMuted,
        ),
        KpiCard(
          label: 'Datos a grabar',
          value: '$recordable',
          sub: 'de ${plc.plcsWithSelection} PLC conectados',
        ),
        KpiCard(
          label: 'Estado de grabado',
          value: plc.recording ? 'Grabando' : 'Detenido',
          valueSize: 24,
          valueColor: plc.recording ? AppColors.stop : AppColors.inkMuted,
          sub: plc.recording
              ? '${formatDuration(plc.elapsed)} transcurrido'
              : recordable == 0
              ? 'Conecte un PLC para empezar'
              : 'Listo para iniciar',
        ),
        KpiCard(
          label: 'Registros grabados',
          value: formatNumber(plc.recordCount),
          sub: 'En esta sesión',
        ),
        KpiCard(
          label: 'Tasa de escritura',
          value: formatNumber(
            recordable / plc.interval,
            recordable % plc.interval == 0 ? 0 : 1,
          ),
          unit: 'reg/s',
          sub: 'Muestreo cada ${plc.interval} s',
        ),
      ],
    );

    final list = PlcList(selectedId: _selectedId, onSelect: _select);
    final detail = KeyedSubtree(
      key: _detailKey,
      child: PlcDetail(plcId: _selectedId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 20),
        kpis,
        const SizedBox(height: 20),
        // lg: [360px | 1fr] · < lg: apilado
        if (context.isLg)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 360, child: list),
              const SizedBox(width: 20),
              Expanded(child: detail),
            ],
          )
        else ...[
          list,
          const SizedBox(height: 20),
          detail,
        ],
        const SizedBox(height: 20),
        const RecordingLog(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.plc});

  final PlcController plc;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conexión y grabado',
          style: AppText.sans(
            size: context.isSm ? 27 : 24,
            weight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${plc.devices.length} PLC en la red de planta · conecte, elija los datos de cada PLC e inicie el grabado en base de datos',
          style: AppText.sans(size: 13.5, color: AppColors.inkMuted),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (plc.allConnected)
          AppButton(
            label: 'Desconectar todos',
            variant: AppButtonVariant.outline,
            onPressed: plc.disconnectAll,
          )
        else
          AppButton(
            label: 'Conectar todos',
            variant: AppButtonVariant.outline,
            icon: const Icon(LucideIcons.plugZap),
            onPressed: plc.connectingCount > 0 ? null : plc.connectAll,
          ),
        if (plc.recording)
          AppButton(
            label: 'Detener grabado',
            variant: AppButtonVariant.danger,
            icon: const Icon(LucideIcons.square, size: 14),
            onPressed: plc.stopRecording,
          )
        else
          AppButton(
            label: 'Iniciar grabado',
            icon: const Icon(LucideIcons.circle, size: 14),
            onPressed: plc.recordableCount == 0 ? null : plc.startRecording,
          ),
      ],
    );

    if (context.isMd) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: title),
          const SizedBox(width: 16),
          actions,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [title, const SizedBox(height: 16), actions],
    );
  }
}
