import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/time.dart';
import '../../../data/mock/lines_data.dart';
import '../../../data/mock/machines_data.dart';
import '../../../data/models/machine.dart';
import '../../layout/app_shell.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/responsive_grid.dart';
import 'widgets/clock_box.dart';
import 'widgets/line_section.dart';

class PlantViewScreen extends StatelessWidget {
  const PlantViewScreen({super.key});

  @override
  Widget build(BuildContext context) => const AppShell(child: _PlantViewBody());
}

class _PlantViewBody extends StatefulWidget {
  const _PlantViewBody();

  @override
  State<_PlantViewBody> createState() => _PlantViewBodyState();
}

class _PlantViewBodyState extends State<_PlantViewBody> {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // "actualización cada 1 s"
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tick = _now.millisecondsSinceEpoch ~/ 1000;
    final shift = getShift(_now);

    List<Machine> byStatus(MachineStatus s) =>
        machines.where((m) => m.status == s).toList();
    final running = byStatus(MachineStatus.run);
    final paused = byStatus(MachineStatus.pause);
    final stopped = byStatus(MachineStatus.stop);
    final offline = byStatus(MachineStatus.offline);
    final rompedoras = machines
        .where((m) => m.type == MachineType.rompedora)
        .length;
    final integrados = machines.length - rompedoras;
    final totalProduction = machines.fold<double>(
      0,
      (s, m) => s + m.production,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          now: _now,
          shift: shift,
          subtitle:
              '${productionLines.length} líneas · $rompedoras rompedoras · $integrados integrados · actualización cada 1 s',
        ),
        const SizedBox(height: 20),

        // KPIs: grid-cols-2 · md:grid-cols-3 · xl:grid-cols-6
        ResponsiveGrid(
          columns: context.isXl ? 6 : (context.isMd ? 3 : 2),
          gap: 12,
          children: [
            KpiCard(
              label: 'En marcha',
              value: '${running.length}',
              unit: '/ ${machines.length}',
              valueColor: AppColors.run,
              sub:
                  '${running.where((m) => m.type == MachineType.rompedora).length} rompedoras · '
                  '${running.where((m) => m.type == MachineType.integrado).length} integrados',
            ),
            KpiCard(
              label: 'En pausa',
              value: '${paused.length}',
              valueColor: AppColors.pause,
              sub: paused
                  .map((m) => '${m.name} · ${m.statusNote ?? ''}')
                  .join(', '),
            ),
            KpiCard(
              label: 'Detenidas',
              value: '${stopped.length}',
              valueColor: AppColors.stop,
              sub: 'Línea 5 completa sin programa',
            ),
            KpiCard(
              label: 'Sin comunicación',
              value: '${offline.length}',
              valueColor: AppColors.offlineStrong,
              sub: offline.map((m) => '${m.name} · revisar PLC').join(', '),
            ),
            KpiCard(
              label: 'Producción del turno',
              value: formatNumber(totalProduction),
              unit: 'm',
              sub: 'Suma de integrados en marcha',
            ),
            KpiCard(
              label: 'Horas trabajo / pausa',
              value: '46,2',
              unit: '/ 3,8 h',
              sub: 'Acumulado del turno, ${machines.length} máquinas',
            ),
          ],
        ),
        const SizedBox(height: 20),

        const _Legend(),
        const SizedBox(height: 20),

        for (var i = 0; i < productionLines.length; i++) ...[
          if (i > 0) const SizedBox(height: 20),
          LineSection(
            line: productionLines[i],
            machines: machines
                .where((m) => m.line == productionLines[i].id)
                .toList(),
            tick: tick,
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.now,
    required this.shift,
    required this.subtitle,
  });

  final DateTime now;
  final ShiftInfo shift;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado de planta en tiempo real',
          style: AppText.sans(
            size: context.isSm ? 27 : 24,
            weight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppText.sans(size: 13.5, color: AppColors.inkMuted),
        ),
      ],
    );

    final dateBox = ClockBox(
      label: 'Fecha y hora',
      value: '${formatDate(now)} · ${formatClock(now)}',
    );
    final shiftBox = ClockBox(
      label: 'Turno actual',
      value: '${shift.label} · ${shift.range}',
    );

    // xl: título a la izquierda y relojes a la derecha
    if (context.isXl) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: title),
          const SizedBox(width: 16),
          IntrinsicWidth(
            child: Row(
              children: [
                Expanded(child: dateBox),
                const SizedBox(width: 12),
                Expanded(child: shiftBox),
              ],
            ),
          ),
        ],
      );
    }

    // < xl: apilado; relojes en 1 columna (móvil) o 2 columnas (sm+)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        title,
        const SizedBox(height: 16),
        ResponsiveGrid(
          columns: context.isSm ? 2 : 1,
          gap: 12,
          children: [dateBox, shiftBox],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  static const _items = [
    ('En marcha', AppColors.run),
    ('En pausa', AppColors.pause),
    ('Detenida', AppColors.stop),
    ('Sin comunicación', AppColors.offline),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 24,
      runSpacing: 8,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 6,
          children: [
            Text('LEYENDA', style: AppText.overline(tracking: 0.1)),
            for (final (label, color) in _items)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppText.sans(size: 12.5, color: AppColors.inkMuted),
                  ),
                ],
              ),
          ],
        ),
        if (context.isMd)
          Text(
            'Haga clic en una máquina para ver su detalle, turnos y tendencias',
            style: AppText.sans(size: 12.5, color: AppColors.inkMuted),
          ),
      ],
    );
  }
}
