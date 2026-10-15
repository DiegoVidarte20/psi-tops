import '../../../../core/utils/format.dart';
import '../../../../data/models/machine.dart';

class DetailKpi {
  final String label;
  final String value;
  final String? unit;
  final String sub;
  final bool subOk;
  const DetailKpi(
    this.label,
    this.value,
    this.unit,
    this.sub, {
    this.subOk = false,
  });
}

/// Port de buildDetailKpis (utils/machineKpis.ts).
List<DetailKpi> buildDetailKpis(Machine m) {
  final running = m.status == MachineStatus.run;
  final kpis = <DetailKpi>[];

  if (m.type == MachineType.integrado) {
    final out = m.metric(MetricKey.velSalida)?.value ?? 0;
    final feed = m.metric(MetricKey.velAlim)?.value ?? 0;
    final prod = m.production;
    kpis.addAll([
      DetailKpi(
        'Velocidad de salida',
        formatNumber(out),
        'm/min',
        'Promedio del turno ${running ? formatNumber(out - 4) : 0} m/min',
        subOk: running,
      ),
      DetailKpi(
        'Velocidad de alimentación',
        formatNumber(feed),
        'm/min',
        'Relación salida/alimentación ${feed != 0 ? formatNumber(out / feed, 2) : '—'}',
      ),
      DetailKpi(
        'Metros producidos',
        formatNumber((prod * 1.705).round()),
        'm',
        'Contador del día',
      ),
      DetailKpi(
        'Producción turno 1',
        formatNumber(prod),
        'm',
        running ? '3,6 h trabajo · 0,2 h pausa' : '1,2 h trabajo · 2,6 h pausa',
      ),
    ]);
  } else {
    final speed = m.metric(MetricKey.velMaquina)?.value ?? 0;
    final feedMetric =
        m.metric(MetricKey.velAlim) ?? m.metric(MetricKey.velBanda);
    final stretch = m.metric(MetricKey.estiramiento);
    kpis.addAll([
      DetailKpi(
        'Velocidad de máquina',
        formatNumber(speed),
        'm/min',
        'Promedio del turno ${running ? formatNumber(speed - 3) : 0} m/min',
        subOk: running,
      ),
      DetailKpi(
        feedMetric?.key == MetricKey.velBanda
            ? 'Velocidad banda enfr.'
            : 'Velocidad de alimentación',
        formatNumber(feedMetric?.value ?? 0),
        'm/min',
        'Lectura en tiempo real',
      ),
      DetailKpi(
        'Estiramiento',
        stretch != null ? formatNumber(stretch.value, 1) : '—',
        null,
        stretch != null
            ? 'Relación vel. máquina / alimentación'
            : 'No disponible en este equipo',
      ),
      DetailKpi(
        'Horas de trabajo T1',
        running ? '3,6' : '1,2',
        'h',
        running ? '0,2 h de pausa en el turno' : '2,6 h de pausa en el turno',
      ),
    ]);
  }

  kpis.add(
    DetailKpi(
      'Horómetro',
      formatNumber(m.horometro, 1),
      'h',
      'Acumulado de vida de máquina',
    ),
  );
  return kpis;
}
