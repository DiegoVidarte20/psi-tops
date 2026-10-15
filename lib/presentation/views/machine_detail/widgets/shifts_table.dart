import 'package:flutter/material.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/format.dart';
import '../../../../data/models/machine.dart';
import '../../../widgets/app_card.dart';

/// "Turnos de hoy" (components/machine/ShiftsTable.tsx).
class ShiftsTable extends StatelessWidget {
  const ShiftsTable({super.key, required this.machine, required this.date});

  final Machine machine;
  final String date;

  @override
  Widget build(BuildContext context) {
    final pad = context.isSm ? 18.0 : 16.0;
    final running = machine.status == MachineStatus.run;
    final integrado = machine.type == MachineType.integrado;
    final t1 = integrado ? machine.production : machine.outputSpeed * 48;
    final t3Calc = (t1 * 0.705).round();
    final t3 = integrado ? (t3Calc != 0 ? t3Calc : 5160) : 5240;
    final t1Work = running ? 3.6 : 1.2;
    final t1Pause = running ? 0.2 : 2.6;
    final availability = ((t1Work + 7.4) / (t1Work + t1Pause + 8) * 100)
        .round();

    final rows = [
      _ShiftRow(
        'Turno 1',
        '06:00 – 14:00 · en curso',
        formatNumber(t1Work, 1),
        formatNumber(t1Pause, 1),
        formatNumber(t1),
        current: true,
      ),
      const _ShiftRow('Turno 2', '14:00 – 22:00', '—', '—', '—'),
      _ShiftRow('Turno 3', '22:00 – 06:00', '7,4', '0,6', formatNumber(t3)),
      _ShiftRow(
        'Turno total',
        'día de producción',
        formatNumber(t1Work + 7.4, 1),
        formatNumber(t1Pause + 0.6, 1),
        formatNumber(t1 + t3),
        bold: true,
      ),
    ];

    final head = AppText.overline(height: 1.2);
    final mono = AppText.mono(size: 13);

    TableRow row(_ShiftRow r) => TableRow(
      decoration: BoxDecoration(
        color: r.current ? AppColors.primarySoft.withValues(alpha: 0.6) : null,
        border: const Border(top: BorderSide(color: AppColors.lineSoft)),
      ),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(pad, 10, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.name,
                style: AppText.sans(
                  size: 13,
                  weight: r.current || r.bold
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
              Text(
                r.sub,
                style: AppText.sans(size: 11.5, color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
        _cell('${r.work} h', mono),
        _cell('${r.pause} h', mono.copyWith(color: AppColors.pause)),
        _cell('${r.prod} m', mono, right: pad),
      ],
    );

    return AppCard(
      padding: EdgeInsets.symmetric(vertical: pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    'Turnos de hoy',
                    style: AppText.sans(size: 15, weight: FontWeight.w700),
                  ),
                ),
                Text(
                  date,
                  style: AppText.sans(size: 12.5, color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tabla a todo el ancho; en pantallas < 300 px hace scroll horizontal.
          LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: c.maxWidth < 300 ? 300 : c.maxWidth,
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(),
                    1: IntrinsicColumnWidth(),
                    2: IntrinsicColumnWidth(),
                    3: IntrinsicColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(pad, 8, 8, 8),
                          child: Text('TURNO', style: head),
                        ),
                        _cell('TRABAJO', head),
                        _cell('PAUSA', head),
                        _cell('PRODUCCIÓN', head, right: pad),
                      ],
                    ),
                    ...rows.map(row),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 0, pad, 0),
            child: Container(
              padding: const EdgeInsets.only(top: 12),
              margin: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.lineSoft)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _kv(
                    'Totales acumulados (mes)',
                    '214,6 h · 196 480 m',
                    AppColors.ink,
                    FontWeight.w400,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        // stretch: sin esto la barra mide 0 px de alto
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: availability,
                            child: const ColoredBox(color: AppColors.run),
                          ),
                          Expanded(
                            flex: 100 - availability,
                            child: const ColoredBox(color: AppColors.pause),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _kv(
                    'Disponibilidad del turno',
                    '$availability %',
                    AppColors.run,
                    FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _cell(String text, TextStyle style, {double right = 8}) =>
      Padding(
        padding: EdgeInsets.fromLTRB(8, 10, right, 10),
        child: Text(
          text,
          softWrap: false,
          textAlign: TextAlign.right,
          style: style,
        ),
      );

  static Widget _kv(String k, String v, Color color, FontWeight weight) => Row(
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      Expanded(
        child: Text(
          k,
          style: AppText.sans(size: 12.5, color: AppColors.inkMuted),
        ),
      ),
      Text(
        v,
        style: AppText.mono(size: 12.5, color: color, weight: weight),
      ),
    ],
  );
}

class _ShiftRow {
  final String name;
  final String sub;
  final String work;
  final String pause;
  final String prod;
  final bool current;
  final bool bold;
  const _ShiftRow(
    this.name,
    this.sub,
    this.work,
    this.pause,
    this.prod, {
    this.current = false,
    this.bold = false,
  });
}
