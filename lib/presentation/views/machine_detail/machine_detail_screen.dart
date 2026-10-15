import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/time.dart';
import '../../../data/mock/machines_data.dart';
import '../../../data/models/machine.dart';
import '../../layout/app_shell.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/responsive_grid.dart';
import '../../widgets/status_badge.dart';
import 'logic/machine_kpis.dart';
import 'logic/machine_series.dart';
import 'widgets/monitored_variables.dart';
import 'widgets/shifts_table.dart';
import 'widgets/speed_chart.dart';
import 'widgets/status_timeline_chart.dart';

class MachineDetailScreen extends StatelessWidget {
  const MachineDetailScreen({super.key, required this.machineId});

  final String machineId;

  @override
  Widget build(BuildContext context) =>
      AppShell(child: _MachineDetailBody(machineId: machineId));
}

class _MachineDetailBody extends StatefulWidget {
  const _MachineDetailBody({required this.machineId});

  final String machineId;

  @override
  State<_MachineDetailBody> createState() => _MachineDetailBodyState();
}

class _MachineDetailBodyState extends State<_MachineDetailBody> {
  RangeKey _range = RangeKey.h2;
  DateTime _now = DateTime.now();
  Timer? _timer;

  // La serie se recalcula solo cuando cambia el minuto o el rango.
  DetailSeries? _series;
  String? _seriesKey;

  @override
  void initState() {
    super.initState();
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

  DetailSeries _seriesFor(Machine m, int index) {
    final minuteKey = _now.millisecondsSinceEpoch ~/ 60000;
    final key = '${m.id}|${_range.name}|$minuteKey';
    if (_seriesKey != key || _series == null) {
      final at = DateTime.fromMillisecondsSinceEpoch(minuteKey * 60000);
      final minutes = _range == RangeKey.turno
          ? minutesSinceShiftStart(at)
          : _range.minutes;
      _series = buildDetailSeries(m, minutes, at, index + 1);
      _seriesKey = key;
    }
    return _series!;
  }

  @override
  Widget build(BuildContext context) {
    final index = machines.indexWhere((m) => m.id == widget.machineId);
    if (index < 0) return const _NotFound();

    final machine = machines[index];
    final series = _seriesFor(machine, index);
    final kpis = buildDetailKpis(machine);
    final integrado = machine.type == MachineType.integrado;

    final charts = [
      StatusTimelineChart(
        series: series,
        range: _range,
        onRange: (r) => setState(() => _range = r),
      ),
      SpeedChart(
        series: series,
        outLabel: integrado ? 'Vel. salida' : 'Vel. máquina',
        feedLabel: 'Vel. alimentación',
      ),
    ];
    final side = [
      ShiftsTable(machine: machine, date: formatDate(_now)),
      MonitoredVariables(machine: machine),
    ];

    Widget stack(List<Widget> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 20),
          items[i],
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Breadcrumb(machine: machine),
        const SizedBox(height: 20),
        _Header(machine: machine),
        const SizedBox(height: 20),

        // KPIs: grid-cols-2 · md:grid-cols-3 · xl:grid-cols-5
        ResponsiveGrid(
          columns: context.isXl ? 5 : (context.isMd ? 3 : 2),
          gap: 12,
          children: [
            for (final k in kpis)
              KpiCard(
                label: k.label,
                value: k.value,
                unit: k.unit,
                sub: k.sub,
                subColor: k.subOk ? AppColors.run : AppColors.inkMuted,
              ),
          ],
        ),
        const SizedBox(height: 20),

        // lg: gráficas + columna derecha de 340 px · < lg: apilado
        if (context.isLg)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: stack(charts)),
              const SizedBox(width: 20),
              SizedBox(width: 340, child: stack(side)),
            ],
          )
        else
          stack([...charts, ...side]),
      ],
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.machine});

  final Machine machine;

  @override
  Widget build(BuildContext context) {
    const chevron = Icon(
      LucideIcons.chevronRight,
      size: 14,
      color: AppColors.inkFaint,
    );
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        _TextLink(
          label: 'Vista de planta',
          onTap: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.plantView),
        ),
        chevron,
        Text(
          'Línea ${machine.line}',
          style: AppText.sans(size: 13, color: AppColors.inkMuted),
        ),
        chevron,
        Text(
          machine.name,
          style: AppText.sans(size: 13, weight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.machine});

  final Machine machine;

  @override
  Widget build(BuildContext context) {
    final info = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        Text(
          machine.name,
          style: AppText.sans(
            size: context.isSm ? 29 : 26,
            weight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        StatusBadge(
          status: machine.status,
          size: BadgeSize.md,
          label: '${machine.status.label} desde ${machine.since}',
        ),
        Text(
          'Línea ${machine.line} · ${machine.plc} · DB_DATA',
          style: AppText.sans(size: 13, color: AppColors.inkMuted),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        AppButton(
          label: 'Ver histórico',
          variant: AppButtonVariant.outline,
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.history),
        ),
        AppButton(
          label: 'Exportar datos',
          onPressed: () => AppToast.success(
            context,
            'Exportación iniciada',
            description: '${machine.name} · Excel (.xlsx)',
          ),
        ),
      ],
    );

    if (context.isMd) {
      return Row(
        children: [
          Expanded(child: info),
          const SizedBox(width: 16),
          actions,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [info, const SizedBox(height: 16), actions],
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text(
            'Máquina no encontrada',
            style: AppText.sans(size: 20, weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Seleccione una máquina de la vista de planta.',
            textAlign: TextAlign.center,
            style: AppText.sans(size: 14, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 16),
          _TextLink(
            label: 'Volver a vista de planta',
            size: 14,
            bold: true,
            onTap: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.plantView),
          ),
        ],
      ),
    );
  }
}

class _TextLink extends StatefulWidget {
  const _TextLink({
    required this.label,
    required this.onTap,
    this.size = 13,
    this.bold = false,
  });

  final String label;
  final VoidCallback onTap;
  final double size;
  final bool bold;

  @override
  State<_TextLink> createState() => _TextLinkState();
}

class _TextLinkState extends State<_TextLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style:
              AppText.sans(
                size: widget.size,
                weight: widget.bold ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.primary,
              ).copyWith(
                decoration: _hover ? TextDecoration.underline : null,
                decorationColor: AppColors.primary,
              ),
        ),
      ),
    );
  }
}
