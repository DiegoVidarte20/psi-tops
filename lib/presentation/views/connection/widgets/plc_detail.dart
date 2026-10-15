import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/state/plc_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../data/mock/plc_data.dart';
import '../../../../data/models/machine.dart';
import '../../../../data/models/plc.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_checkbox.dart';
import '../../../widgets/responsive_grid.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/text_link.dart';
import 'plc_connection_button.dart';

MachineStatus _tone(PlcStatus s) => switch (s) {
  PlcStatus.connected => MachineStatus.run,
  PlcStatus.connecting => MachineStatus.pause,
  PlcStatus.error => MachineStatus.stop,
  PlcStatus.disconnected => MachineStatus.offline,
};

/// Detalle del PLC: estado, estadísticas y tags a grabar.
class PlcDetail extends StatelessWidget {
  const PlcDetail({super.key, required this.plcId});

  final String plcId;

  @override
  Widget build(BuildContext context) {
    final plc = PlcScope.of(context);
    final d = plc.device(plcId);
    final r = plc.runtime[plcId]!;
    final tags = plc.tagsByPlc[plcId]!;
    final connected = r.status == PlcStatus.connected;
    final pad = context.isSm ? 18.0 : 16.0;

    // Agrupa tags por máquina
    final groups = <String, List<PlcTag>>{};
    for (final t in tags) {
      groups.putIfAbsent(t.machine, () => []).add(t);
    }

    final stats = [
      ('Latencia', connected && r.latency != null ? '${r.latency} ms' : '—'),
      ('Variables', '${tags.length}'),
      ('Seleccionadas', '${r.selected.length} / ${tags.length}'),
      ('Última lectura', connected ? 'hace 1 s' : '—'),
    ];

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 6,
          children: [
            Text(
              d.name,
              style: AppText.sans(size: 19, weight: FontWeight.w700),
            ),
            StatusBadge(status: _tone(r.status), label: r.status.label),
          ],
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            style: AppText.sans(size: 12.5, color: AppColors.inkMuted),
            children: [
              TextSpan(
                text: d.ip,
                style: AppText.mono(size: 12.5, color: AppColors.inkMuted),
              ),
              TextSpan(
                text:
                    ' · ${d.model} · Rack ${d.rack} · Slot ${d.slot} · S7 / ISO-on-TCP',
              ),
            ],
          ),
        ),
      ],
    );
    final button = PlcConnectionButton(plcId: plcId, size: AppButtonSize.md);

    return AppCard(
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(pad),
            child: context.isSm
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: title),
                      const SizedBox(width: 12),
                      button,
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title, const SizedBox(height: 12), button],
                  ),
          ),
          // Estadísticas: 2 columnas · sm: 4
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border.symmetric(
                horizontal: BorderSide(color: AppColors.line),
              ),
            ),
            child: ResponsiveGrid(
              columns: context.isSm ? 4 : 2,
              gap: 0,
              children: [
                for (final (label, value) in stats)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: pad,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label.toUpperCase(), style: AppText.overline()),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: AppText.mono(
                            size: 14,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (r.status == PlcStatus.error)
            Container(
              margin: EdgeInsets.fromLTRB(pad, 16, pad, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.stopSoft,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.stop.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      LucideIcons.triangleAlert,
                      size: 16,
                      color: AppColors.stopStrong,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${r.error}. Revise el cable de red o la configuración de IP y pulse «Reintentar».',
                      style: AppText.sans(
                        size: 12.5,
                        color: AppColors.stopStrong,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 16, pad, 8),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  'Datos del PLC a grabar',
                  style: AppText.sans(size: 14, weight: FontWeight.w700),
                ),
                Wrap(
                  spacing: 16,
                  children: [
                    TextLink(
                      label: 'Seleccionar todo',
                      size: 12.5,
                      bold: true,
                      onTap: () =>
                          plc.setSelection(plcId, tags.map((t) => t.id)),
                    ),
                    TextLink(
                      label: 'Ninguna',
                      size: 12.5,
                      color: AppColors.inkMuted,
                      hoverColor: AppColors.ink,
                      underline: false,
                      onTap: () => plc.setSelection(plcId, const []),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _TagsTable(
            pad: pad,
            groups: groups,
            runtime: r,
            connected: connected,
            onToggle: (id) => plc.toggleTag(plcId, id),
            onToggleGroup: (ids) {
              final all = ids.every(r.selected.contains);
              plc.setSelection(
                plcId,
                all
                    ? r.selected.where((id) => !ids.contains(id)).toList()
                    : {...r.selected, ...ids},
              );
            },
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: pad, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Text(
              connected
                  ? 'Las variables marcadas se graban cada ${plc.interval} s mientras el grabado esté activo.'
                  : 'Puede elegir las variables antes de conectar; los valores aparecen al establecer la conexión.',
              style: AppText.sans(size: 12, color: AppColors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tabla de tags agrupada por máquina (con fila de grupo a todo el ancho).
class _TagsTable extends StatelessWidget {
  const _TagsTable({
    required this.pad,
    required this.groups,
    required this.runtime,
    required this.connected,
    required this.onToggle,
    required this.onToggleGroup,
  });

  final double pad;
  final Map<String, List<PlcTag>> groups;
  final PlcRuntime runtime;
  final bool connected;
  final ValueChanged<String> onToggle;
  final ValueChanged<List<String>> onToggleGroup;

  static const _minWidth = 700.0;
  static const _addrW = 240.0;
  static const _typeW = 70.0;
  static const _valueW = 110.0;
  static const _unitW = 70.0;

  @override
  Widget build(BuildContext context) {
    final checkW = pad + 16 + 12;
    final head = AppText.overline();
    final text = AppText.sans(size: 12.5);

    return LayoutBuilder(
      builder: (context, c) {
        final width = math.max(c.maxWidth, _minWidth);
        final varW = width - checkW - _addrW - _typeW - _valueW - _unitW - pad;

        Widget row(
          List<Widget> cells, {
          Color? bg,
          Color border = AppColors.lineSoft,
          double vPad = 8,
        }) => Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border(top: BorderSide(color: border)),
          ),
          padding: EdgeInsets.symmetric(vertical: vPad),
          child: Row(children: cells),
        );

        Widget cell(
          double w,
          Widget child, {
          bool right = false,
          double r = 12,
        }) => SizedBox(
          width: w,
          child: Padding(
            padding: EdgeInsets.only(left: 12, right: r),
            child: Align(
              alignment: right ? Alignment.centerRight : Alignment.centerLeft,
              child: child,
            ),
          ),
        );

        Widget check(Widget child) => SizedBox(
          width: checkW,
          child: Padding(
            padding: EdgeInsets.only(left: pad - 4),
            child: Align(alignment: Alignment.centerLeft, child: child),
          ),
        );

        final rows = <Widget>[
          row(
            [
              check(const SizedBox.shrink()),
              cell(varW, Text('VARIABLE', style: head)),
              cell(_addrW, Text('DIRECCIÓN', style: head)),
              cell(_typeW, Text('TIPO', style: head)),
              cell(
                _valueW,
                Text('VALOR ACTUAL', style: head, softWrap: false),
                right: true,
              ),
              cell(_unitW + pad, Text('UNIDAD', style: head), r: pad),
            ],
            bg: AppColors.surface,
            border: Colors.transparent,
            vPad: 10,
          ),
        ];

        for (final entry in groups.entries) {
          final ids = entry.value.map((t) => t.id).toList();
          final allSel = ids.every(runtime.selected.contains);
          rows.add(
            row([
              check(
                AppCheckbox(
                  checked: allSel,
                  onChanged: () => onToggleGroup(ids),
                  semanticLabel:
                      'Seleccionar todas las variables de ${entry.key}',
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    entry.key,
                    style: text.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ], border: AppColors.line),
          );
          for (final t in entry.value) {
            final sel = runtime.selected.contains(t.id);
            final v = runtime.values[t.id];
            final isBool = t.dataType == 'BOOL';
            final valueColor = !connected || v == null
                ? AppColors.inkFaint
                : isBool
                ? (v >= 1 ? AppColors.run : AppColors.stop)
                : AppColors.ink;
            rows.add(
              row([
                check(
                  AppCheckbox(
                    checked: sel,
                    onChanged: () => onToggle(t.id),
                    semanticLabel: 'Grabar ${t.name} de ${t.machine}',
                  ),
                ),
                cell(
                  varW,
                  Text(
                    t.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text,
                  ),
                ),
                cell(
                  _addrW,
                  Text(
                    t.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.mono(size: 11.5, color: AppColors.inkMuted),
                  ),
                ),
                cell(
                  _typeW,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      t.dataType,
                      style: AppText.mono(size: 11, color: AppColors.inkMuted),
                    ),
                  ),
                ),
                cell(
                  _valueW,
                  Text(
                    connected && v != null
                        ? formatTagValue(v, t.dataType, t.decimals)
                        : '—',
                    softWrap: false,
                    style: AppText.mono(
                      size: 12.5,
                      weight: FontWeight.w600,
                      color: valueColor,
                    ),
                  ),
                  right: true,
                ),
                cell(
                  _unitW + pad,
                  Text(t.unit, style: text.copyWith(color: AppColors.inkMuted)),
                  r: pad,
                ),
              ], bg: sel ? AppColors.primarySoft.withValues(alpha: 0.4) : null),
            );
          }
        }

        return Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rows,
              ),
            ),
          ),
        );
      },
    );
  }
}
