import 'dart:math' as math;

enum MachineStatus { run, pause, stop, offline }

extension MachineStatusX on MachineStatus {
  String get label => switch (this) {
    MachineStatus.run => 'En marcha',
    MachineStatus.pause => 'En pausa',
    MachineStatus.stop => 'Detenida',
    MachineStatus.offline => 'Sin comunicación',
  };
}

enum MachineType { rompedora, integrado }

enum MetricKey {
  velMaquina,
  velBanda,
  velAlim,
  estiramiento,
  velSalida,
  produccion,
}

class MachineMetric {
  final MetricKey key;
  final String label;
  final double value;
  final String unit;
  final int decimals;

  const MachineMetric(
    this.key,
    this.label,
    this.value,
    this.unit, [
    this.decimals = 0,
  ]);

  /// Simula el valor en vivo (igual que liveMetricValue del diseño).
  double liveValue(MachineStatus status, int tick, int seed) {
    if (status != MachineStatus.run || unit != 'm/min' || value == 0) {
      return value;
    }
    return value + (math.sin(tick * 0.9 + seed * 1.7) * 1.4).round();
  }
}

class Machine {
  final String id;
  final String name;
  final MachineType type;
  final int line;
  final MachineStatus status;
  final String since;
  final String? statusNote;
  final String plc;
  final double horometro;
  final String lastSeen;
  final List<MachineMetric> metrics;

  const Machine({
    required this.id,
    required this.name,
    required this.type,
    required this.line,
    required this.status,
    required this.since,
    this.statusNote,
    required this.plc,
    required this.horometro,
    required this.lastSeen,
    required this.metrics,
  });

  MachineMetric? metric(MetricKey key) {
    for (final m in metrics) {
      if (m.key == key) return m;
    }
    return null;
  }

  double get production => metric(MetricKey.produccion)?.value ?? 0;

  /// Vel. salida (integrado) o vel. máquina (rompedora).
  double get outputSpeed =>
      metric(MetricKey.velSalida)?.value ??
      metric(MetricKey.velMaquina)?.value ??
      0;

  /// Vel. alimentación o vel. banda enfriadora.
  double get feedSpeed =>
      metric(MetricKey.velAlim)?.value ??
      metric(MetricKey.velBanda)?.value ??
      0;
}

class MonitoredVariable {
  final String name;
  final String tag;
  final String type; // BOOL | REAL | DINT
  final String sampling;
  const MonitoredVariable(this.name, this.tag, this.type, this.sampling);
}

class ProductionLine {
  final int id;
  final String name;
  final String summary;
  const ProductionLine(this.id, this.name, this.summary);
}
