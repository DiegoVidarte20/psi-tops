import '../../core/utils/format.dart';
import '../../core/utils/random.dart';
import 'machines_data.dart';
import '../models/machine.dart';

/// Registro histórico de la base de datos (data/database.ts).
class DbRecord {
  final int id;
  final DateTime time;
  final String line;
  final String machineId;
  final String machine;
  final String variableKey;
  final String variable;
  final double value;
  final int decimals;
  final String unit;
  final String shift; // T1 | T2 | T3
  final bool goodQuality;

  const DbRecord({
    required this.id,
    required this.time,
    required this.line,
    required this.machineId,
    required this.machine,
    required this.variableKey,
    required this.variable,
    required this.value,
    required this.decimals,
    required this.unit,
    required this.shift,
    this.goodQuality = true,
  });

  String get timeLabel =>
      '${pad2(time.day)}/${pad2(time.month)}/${time.year} '
      '${pad2(time.hour)}:${pad2(time.minute)}:${pad2(time.second)}';

  String get quality => goodQuality ? 'Buena' : 'Dudosa';

  /// "En marcha" si la velocidad o el estado es > 0.
  bool get running => value > 0;
}

String shiftOf(DateTime d) {
  final h = d.hour;
  if (h >= 6 && h < 14) return 'T1';
  if (h >= 14 && h < 22) return 'T2';
  return 'T3';
}

DbRecord _r(
  int id,
  DateTime t,
  Machine m,
  String key,
  String variable,
  double value,
  int decimals,
  String unit, {
  bool good = true,
}) => DbRecord(
  id: id,
  time: t,
  line: 'Línea ${m.line}',
  machineId: m.id,
  machine: m.name,
  variableKey: key,
  variable: variable,
  value: value,
  decimals: decimals,
  unit: unit,
  shift: shiftOf(t),
  goodQuality: good,
);

List<DbRecord>? _cache;

/// 12 registros exactos del diseño + histórico generado (5 máquinas,
/// cada 10 s) para que la paginación tenga páginas reales.
List<DbRecord> get dbRecords => _cache ??= _build();

List<DbRecord> _build() {
  Machine m(String id) => machines.firstWhere((x) => x.id == id);
  final i1a = m('integrado-1a');
  final t0 = DateTime(2026, 10, 14, 9, 50, 10);
  final t1 = DateTime(2026, 10, 14, 9, 50, 0);
  final t2 = DateTime(2026, 10, 14, 9, 49, 50);

  final list = <DbRecord>[
    _r(48211904, t0, i1a, 'velSalida', 'Velocidad de salida', 185, 0, 'm/min'),
    _r(
      48211903,
      t0,
      i1a,
      'velAlim',
      'Velocidad de alimentación',
      178,
      0,
      'm/min',
    ),
    _r(48211902, t0, i1a, 'estado', 'Estado de máquina', 1, 0, 'ON/OFF'),
    _r(48211880, t1, i1a, 'metros', 'Metros', 12480, 0, 'm'),
    _r(48211879, t1, i1a, 'produccion', 'Producción T1', 7320, 0, 'm'),
    _r(48211878, t1, i1a, 'horasTrabajo', 'Horas de trabajo T1', 3.6, 2, 'h'),
    _r(48211877, t1, i1a, 'horasPausa', 'Horas de pausa T1', 0.2, 2, 'h'),
    _r(48211876, t1, i1a, 'horometro', 'Horómetro', 18432.5, 1, 'h'),
    _r(48211851, t1, i1a, 'velSalida', 'Velocidad de salida', 184, 0, 'm/min'),
    _r(
      48211850,
      t1,
      i1a,
      'velAlim',
      'Velocidad de alimentación',
      177,
      0,
      'm/min',
    ),
    _r(48211798, t2, i1a, 'velSalida', 'Velocidad de salida', 186, 0, 'm/min'),
    _r(
      48211797,
      t2,
      i1a,
      'velAlim',
      'Velocidad de alimentación',
      178,
      0,
      'm/min',
    ),
  ];

  // Histórico generado hacia atrás cada 10 s.
  final sample = [
    'integrado-1a',
    'integrado-1b',
    'rompedora-1a',
    'integrado-2a',
    'rompedora-2b',
  ].map(m).toList();
  var id = 48211790;
  var t = t2;
  for (var step = 1; step <= 300; step++) {
    t = t.subtract(const Duration(seconds: 10));
    for (var k = 0; k < sample.length; k++) {
      final mc = sample[k];
      final run = mc.status == MachineStatus.run;
      final n = seededNoise(step * 13 + k * 101) - 0.5;
      final out = run ? (mc.outputSpeed + n * 6).roundToDouble() : 0.0;
      final feed = run ? (mc.feedSpeed + n * 5).roundToDouble() : 0.0;
      final good = (step * 7 + k) % 53 != 0;
      final outLabel = mc.type == MachineType.integrado
          ? 'Velocidad de salida'
          : 'Velocidad de máquina';
      list.add(
        _r(id--, t, mc, 'velSalida', outLabel, out, 0, 'm/min', good: good),
      );
      list.add(
        _r(
          id--,
          t,
          mc,
          'velAlim',
          'Velocidad de alimentación',
          feed,
          0,
          'm/min',
        ),
      );
      if (step % 6 == 0) {
        list.add(
          _r(
            id--,
            t,
            mc,
            'estado',
            'Estado de máquina',
            run ? 1 : 0,
            0,
            'ON/OFF',
          ),
        );
      }
    }
  }
  return list;
}

class ExportColumn {
  final String key;
  final String label;
  final bool checked;
  const ExportColumn(this.key, this.label, this.checked);
}

const exportColumns = [
  ExportColumn('fecha_hora', 'Fecha / hora', true),
  ExportColumn('linea', 'Línea', true),
  ExportColumn('maquina', 'Máquina', true),
  ExportColumn('estado', 'Estado de máquina', true),
  ExportColumn('vel_salida', 'Velocidad de salida', true),
  ExportColumn('vel_alim', 'Velocidad de alimentación', true),
  ExportColumn('metros', 'Metros', false),
  ExportColumn('h_trabajo', 'Horas de trabajo', true),
  ExportColumn('h_pausa', 'Horas de pausa', true),
  ExportColumn('produccion', 'Producción', true),
  ExportColumn('horometro', 'Horómetro', false),
  ExportColumn('turno', 'Turno', true),
  ExportColumn('calidad', 'Calidad de dato', false),
];

const quickRanges = ['Hoy', 'Últimos 7 días', 'Este mes', 'Este año'];

class ShiftConfig {
  final String name;
  final String start;
  final String end;
  final String report;
  const ShiftConfig(this.name, this.start, this.end, this.report);
}

const shiftConfig = [
  ShiftConfig('Turno 1', '06:00', '14:00', 'Cierre 14:05 · Excel'),
  ShiftConfig('Turno 2', '14:00', '22:00', 'Cierre 22:05 · Excel'),
  ShiftConfig('Turno 3', '22:00', '06:00', 'Cierre 06:05 · Excel'),
];

class AppUser {
  final String name;
  final String email;
  final String role;
  final String lastAccess;
  const AppUser(this.name, this.email, this.role, this.lastAccess);
}

const users = [
  AppUser(
    'Carlos Huamán',
    'c.huaman@plantatops.pe',
    'Administrador',
    'hoy 09:41',
  ),
  AppUser(
    'María Quispe',
    'm.quispe@plantatops.pe',
    'Supervisor de producción',
    'hoy 07:12',
  ),
  AppUser(
    'Jorge Ramírez',
    'j.ramirez@plantatops.pe',
    'Mantenimiento',
    'ayer 22:30',
  ),
  AppUser(
    'Lucía Torres',
    'l.torres@plantatops.pe',
    'Gerencia (solo lectura)',
    '13/10/2026',
  ),
];
