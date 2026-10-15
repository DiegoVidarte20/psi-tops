enum PlcStatus { disconnected, connecting, connected, error }

extension PlcStatusX on PlcStatus {
  String get label => switch (this) {
    PlcStatus.connected => 'Conectado',
    PlcStatus.connecting => 'Conectando…',
    PlcStatus.error => 'Sin respuesta',
    PlcStatus.disconnected => 'Desconectado',
  };
}

enum PlcKind { rom, intg }

enum TagMode { state, noise, counter }

enum TagSource { estado, metric, horometro, metros, horasTrabajo, horasPausa }

class PlcDevice {
  final String id;
  final String name;
  final int line;
  final PlcKind kind;
  final String ip;
  final String model;
  final int rack;
  final int slot;
  final bool failFirstAttempt;
  const PlcDevice(
    this.id,
    this.name,
    this.line,
    this.kind,
    this.ip,
    this.model, {
    this.rack = 0,
    this.slot = 1,
    this.failFirstAttempt = false,
  });
}

class PlcTagTemplate {
  final String field;
  final String name;
  final String dataType; // BOOL | REAL | DINT
  final String unit;
  final int decimals;
  final TagMode mode;
  final TagSource source;
  final String? metricKey; // nombre de MetricKey
  final double variance;
  final bool defaultSelected;
  const PlcTagTemplate(
    this.field,
    this.name,
    this.dataType,
    this.unit,
    this.decimals,
    this.mode,
    this.source, {
    this.metricKey,
    this.variance = 0,
    this.defaultSelected = false,
  });
}

class PlcTag {
  final String id;
  final String plcId;
  final String machineId;
  final String machine;
  final String name;
  final String address;
  final String dataType;
  final String unit;
  final int decimals;
  final TagMode mode;
  final double base;
  final double variance;
  final double rate;
  final bool defaultSelected;
  const PlcTag({
    required this.id,
    required this.plcId,
    required this.machineId,
    required this.machine,
    required this.name,
    required this.address,
    required this.dataType,
    required this.unit,
    required this.decimals,
    required this.mode,
    required this.base,
    required this.variance,
    required this.rate,
    required this.defaultSelected,
  });
}

class PlcRuntime {
  PlcStatus status = PlcStatus.disconnected;
  int? latency;
  String? error;
  int attempts = 0;
  final Set<String> selected;
  Map<String, double> values = {};
  PlcRuntime(this.selected);
}

class RecordEntry {
  final int id;
  final String time;
  final String plc;
  final String machine;
  final String variable;
  final String address;
  final String dataType;
  final double value;
  final String unit;
  final int decimals;
  const RecordEntry({
    required this.id,
    required this.time,
    required this.plc,
    required this.machine,
    required this.variable,
    required this.address,
    required this.dataType,
    required this.value,
    required this.unit,
    required this.decimals,
  });
}
