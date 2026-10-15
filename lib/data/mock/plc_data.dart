import '../../core/utils/format.dart';
import '../models/machine.dart';
import '../models/plc.dart';
import 'machines_data.dart';

/// 12 PLC de la red de planta (data/plcs.ts).
const plcDevices = <PlcDevice>[
  PlcDevice(
    'l1-rom',
    'PLC L1-ROM',
    1,
    PlcKind.rom,
    '192.168.10.11',
    'Siemens S7-1200',
  ),
  PlcDevice(
    'l1-int',
    'PLC L1-INT',
    1,
    PlcKind.intg,
    '192.168.10.12',
    'Siemens S7-1500',
  ),
  PlcDevice(
    'l2-rom',
    'PLC L2-ROM',
    2,
    PlcKind.rom,
    '192.168.10.21',
    'Siemens S7-1200',
  ),
  PlcDevice(
    'l2-int',
    'PLC L2-INT',
    2,
    PlcKind.intg,
    '192.168.10.22',
    'Siemens S7-1500',
  ),
  PlcDevice(
    'l3-rom',
    'PLC L3-ROM',
    3,
    PlcKind.rom,
    '192.168.10.31',
    'Siemens S7-1200',
  ),
  PlcDevice(
    'l3-int',
    'PLC L3-INT',
    3,
    PlcKind.intg,
    '192.168.10.32',
    'Siemens S7-1500',
  ),
  PlcDevice(
    'l4-rom',
    'PLC L4-ROM',
    4,
    PlcKind.rom,
    '192.168.10.41',
    'Siemens S7-1200',
  ),
  PlcDevice(
    'l4-int',
    'PLC L4-INT',
    4,
    PlcKind.intg,
    '192.168.10.42',
    'Siemens S7-1500',
  ),
  PlcDevice(
    'l5-rom',
    'PLC L5-ROM',
    5,
    PlcKind.rom,
    '192.168.10.51',
    'Siemens S7-1200',
    failFirstAttempt: true,
  ),
  PlcDevice(
    'l5-int',
    'PLC L5-INT',
    5,
    PlcKind.intg,
    '192.168.10.52',
    'Siemens S7-1500',
  ),
  PlcDevice(
    'l6-rom',
    'PLC L6-ROM',
    6,
    PlcKind.rom,
    '192.168.10.61',
    'Siemens S7-1200',
  ),
  PlcDevice(
    'l6-int',
    'PLC L6-INT',
    6,
    PlcKind.intg,
    '192.168.10.62',
    'Siemens S7-1500',
  ),
];

const _romTemplates = <PlcTagTemplate>[
  PlcTagTemplate(
    'ESTADO',
    'Estado de máquina',
    'BOOL',
    'ON/OFF',
    0,
    TagMode.state,
    TagSource.estado,
    defaultSelected: true,
  ),
  PlcTagTemplate(
    'VEL_MAQUINA',
    'Velocidad de máquina',
    'REAL',
    'm/min',
    1,
    TagMode.noise,
    TagSource.metric,
    metricKey: 'velMaquina',
    variance: 1.8,
    defaultSelected: true,
  ),
  PlcTagTemplate(
    'VEL_BANDA',
    'Velocidad banda enfriamiento',
    'REAL',
    'm/min',
    1,
    TagMode.noise,
    TagSource.metric,
    metricKey: 'velBanda',
    variance: 0.8,
    defaultSelected: true,
  ),
  PlcTagTemplate(
    'VEL_ALIMENTACION',
    'Velocidad de alimentación',
    'REAL',
    'm/min',
    1,
    TagMode.noise,
    TagSource.metric,
    metricKey: 'velAlim',
    variance: 0.8,
    defaultSelected: true,
  ),
  PlcTagTemplate(
    'ESTIRAMIENTO',
    'Estiramiento',
    'REAL',
    '',
    2,
    TagMode.noise,
    TagSource.metric,
    metricKey: 'estiramiento',
    variance: 0.04,
  ),
  PlcTagTemplate(
    'HORAS_TRABAJO',
    'Horas de trabajo turno',
    'REAL',
    'h',
    3,
    TagMode.counter,
    TagSource.horasTrabajo,
  ),
  PlcTagTemplate(
    'HOROMETRO',
    'Horómetro',
    'REAL',
    'h',
    2,
    TagMode.counter,
    TagSource.horometro,
  ),
];

const _intTemplates = <PlcTagTemplate>[
  PlcTagTemplate(
    'ESTADO',
    'Estado de máquina',
    'BOOL',
    'ON/OFF',
    0,
    TagMode.state,
    TagSource.estado,
    defaultSelected: true,
  ),
  PlcTagTemplate(
    'VEL_SALIDA',
    'Velocidad de salida',
    'REAL',
    'm/min',
    1,
    TagMode.noise,
    TagSource.metric,
    metricKey: 'velSalida',
    variance: 2,
    defaultSelected: true,
  ),
  PlcTagTemplate(
    'VEL_ALIMENTACION',
    'Velocidad de alimentación',
    'REAL',
    'm/min',
    1,
    TagMode.noise,
    TagSource.metric,
    metricKey: 'velAlim',
    variance: 2,
    defaultSelected: true,
  ),
  PlcTagTemplate(
    'PRODUCCION_T',
    'Producción turno',
    'DINT',
    'm',
    0,
    TagMode.counter,
    TagSource.metric,
    metricKey: 'produccion',
    defaultSelected: true,
  ),
  PlcTagTemplate(
    'METROS',
    'Metros',
    'DINT',
    'm',
    0,
    TagMode.counter,
    TagSource.metros,
  ),
  PlcTagTemplate(
    'HORAS_TRABAJO',
    'Horas de trabajo turno',
    'REAL',
    'h',
    3,
    TagMode.counter,
    TagSource.horasTrabajo,
  ),
  PlcTagTemplate(
    'HORAS_PAUSA',
    'Horas de pausa turno',
    'REAL',
    'h',
    2,
    TagMode.state,
    TagSource.horasPausa,
  ),
  PlcTagTemplate(
    'HOROMETRO',
    'Horómetro',
    'REAL',
    'h',
    2,
    TagMode.counter,
    TagSource.horometro,
  ),
];

MachineMetric? _metric(Machine m, String? key) {
  if (key == null) return null;
  for (final x in m.metrics) {
    if (x.key.name == key) return x;
  }
  return null;
}

/// Tags de un PLC (port de utils/plcTags.ts → buildPlcTags).
List<PlcTag> buildPlcTags(PlcDevice d) {
  final type = d.kind == PlcKind.rom
      ? MachineType.rompedora
      : MachineType.integrado;
  final templates = d.kind == PlcKind.rom ? _romTemplates : _intTemplates;
  final kind = d.kind == PlcKind.rom ? 'ROM' : 'INT';

  return [
    for (final m in machines.where((m) => m.line == d.line && m.type == type))
      for (final t in templates)
        if (t.source != TagSource.metric || _metric(m, t.metricKey) != null)
          () {
            final code = '${kind}_${m.name.split(' ')[1]}';
            final running = m.status == MachineStatus.run;
            final outSpeed = _metric(m, 'velSalida')?.value ?? 0;
            double base = 0;
            double rate = 0;
            switch (t.source) {
              case TagSource.estado:
                base = running ? 1 : 0;
              case TagSource.metric:
                base = _metric(m, t.metricKey)?.value ?? 0;
                if (t.metricKey == 'produccion') {
                  rate = running ? outSpeed / 60 : 0;
                }
              case TagSource.horometro:
                base = m.horometro;
                rate = running ? 1 / 3600 : 0;
              case TagSource.metros:
                base = (m.production * 1.705).roundToDouble();
                rate = running ? outSpeed / 60 : 0;
              case TagSource.horasTrabajo:
                base = running ? 3.6 : 1.2;
                rate = running ? 1 / 3600 : 0;
              case TagSource.horasPausa:
                base = running ? 0.2 : 2.6;
            }
            return PlcTag(
              id: '${d.id}.$code.${t.field}',
              plcId: d.id,
              machineId: m.id,
              machine: m.name,
              name: t.name,
              address: 'DB_DATA.$code.${t.field}',
              dataType: t.dataType,
              unit: t.unit,
              decimals: t.decimals,
              mode: t.mode,
              base: base,
              variance: running ? t.variance : 0,
              rate: rate,
              defaultSelected: t.defaultSelected,
            );
          }(),
  ];
}

String formatTagValue(double value, String dataType, int decimals) {
  if (dataType == 'BOOL') return value >= 1 ? 'ON' : 'OFF';
  return formatNumber(
    dataType == 'DINT' ? value.floorToDouble() : value,
    decimals,
  );
}
