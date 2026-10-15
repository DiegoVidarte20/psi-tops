import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/chart_theme.dart';
import '../../../../core/utils/random.dart';
import '../../../../data/mock/history_data.dart';
import '../../../../data/mock/machines_data.dart' as data;
import '../../../../data/models/machine.dart';

/// Serie cargada en las gráficas (una por máquina).
class LoadedSeries {
  final String id;
  final String name;
  final Color color;
  final int index;
  final int seed;
  const LoadedSeries(this.id, this.name, this.color, this.index, this.seed);
}

enum TypeFilter { integrado, rompedora, todos }

const groupingOptions = {
  '15min': 'Cada 15 min',
  'hora': 'Cada 1 hora',
  'turno': 'Por turno',
  'dia': 'Por día',
};

const shiftOptions = {
  'todos': 'Todos los turnos',
  't1': 'Turno 1',
  't2': 'Turno 2',
  't3': 'Turno 3',
};

const recordsPerMachine = {'15min': 672, 'hora': 168, 'turno': 21, 'dia': 7};

final _defaultFrom = DateTime(2026, 10, 7, 6, 0);
final _defaultTo = DateTime(2026, 10, 14, 9, 50);
const _defaultVariables = [
  'estado',
  'velSalida',
  'produccion',
  'horasTrabajo',
  'horasPausa',
];

/// Estado de los filtros (port de hooks/useHistoryFilters.ts).
class HistoryController extends ChangeNotifier {
  HistoryController() {
    machines.addAll(_defaultMachines(line, machineType));
    variables.addAll(_defaultVariables);
    loadedSeries = _toSeries(machines.toList(), line);
    loadedGrouping = grouping;
  }

  DateTime from = _defaultFrom;
  DateTime to = _defaultTo;

  /// Retención de 5 años en base de datos.
  static DateTime get minDate => DateTime(
    DateTime.now().year - 5,
    DateTime.now().month,
    DateTime.now().day,
  );
  static DateTime get maxDate => DateTime.now().add(const Duration(days: 1));

  void setFrom(DateTime v) {
    from = v;
    if (to.isBefore(from)) to = from;
    notifyListeners();
  }

  void setTo(DateTime v) {
    to = v;
    if (from.isAfter(to)) from = to;
    notifyListeners();
  }

  int line = 1;
  TypeFilter machineType = TypeFilter.integrado;
  String shift = 'todos';
  String grouping = 'hora';
  final List<String> machines = [];
  final List<String> variables = [];

  List<LoadedSeries> loadedSeries = const [];
  String loadedGrouping = 'hora';
  bool loading = false;
  Timer? _loadTimer;

  List<Machine> get lineMachines =>
      allMachines.where((m) => m.line == line).toList();

  static List<Machine> get allMachines => data.machines;

  static List<String> _defaultMachines(int line, TypeFilter type) => allMachines
      .where(
        (m) =>
            m.line == line &&
            (type == TypeFilter.todos || m.type.name == type.name),
      )
      .take(2)
      .map((m) => m.id)
      .toList();

  static List<LoadedSeries> _toSeries(List<String> ids, int line) {
    final lm = allMachines.where((m) => m.line == line).toList();
    return [
      for (var i = 0; i < ids.length; i++)
        () {
          final pos = lm.indexWhere((m) => m.id == ids[i]);
          return LoadedSeries(
            ids[i],
            pos >= 0 ? lm[pos].name : ids[i],
            ChartTheme.series[(pos < 0 ? 0 : pos) % ChartTheme.series.length],
            i,
            pos + line * 7,
          );
        }(),
    ];
  }

  Color colorFor(String id) {
    final pos = lineMachines.indexWhere((m) => m.id == id);
    return ChartTheme.series[(pos < 0 ? 0 : pos) % ChartTheme.series.length];
  }

  void setLine(int v) {
    line = v;
    machines
      ..clear()
      ..addAll(_defaultMachines(line, machineType));
    notifyListeners();
  }

  void setMachineType(TypeFilter v) {
    machineType = v;
    machines
      ..clear()
      ..addAll(_defaultMachines(line, machineType));
    notifyListeners();
  }

  void setShift(String v) {
    shift = v;
    notifyListeners();
  }

  void setGrouping(String v) {
    grouping = v;
    notifyListeners();
  }

  void toggleMachine(String id) {
    machines.contains(id) ? machines.remove(id) : machines.add(id);
    notifyListeners();
  }

  void toggleVariable(String key) {
    variables.contains(key) ? variables.remove(key) : variables.add(key);
    notifyListeners();
  }

  /// Devuelve false si no hay máquinas seleccionadas.
  bool load() {
    if (machines.isEmpty) return false;
    loading = true;
    notifyListeners();
    _loadTimer?.cancel();
    _loadTimer = Timer(const Duration(milliseconds: 450), () {
      final ordered = lineMachines
          .where((m) => machines.contains(m.id))
          .map((m) => m.id)
          .toList();
      loadedSeries = _toSeries(ordered, line);
      loadedGrouping = grouping;
      loading = false;
      notifyListeners();
    });
    return true;
  }

  void clear() {
    from = _defaultFrom;
    to = _defaultTo;
    line = 1;
    machineType = TypeFilter.integrado;
    shift = 'todos';
    grouping = 'hora';
    machines.clear();
    variables.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }
}

// ---------- Series (port de utils/history.ts) ----------

double _baseSpeed(Machine m, int index) {
  final live = m.outputSpeed;
  if (live != 0) return live - 2;
  return m.type == MachineType.integrado
      ? 176.0 - index * 6
      : 138.0 - index * 3;
}

bool isStopped(int hour, int index) => historyStops.any(
  (s) => hour >= s.from && hour < s.to && (s.allMachines || index == 0),
);

/// 169 puntos (0..168 h) por serie.
Map<String, List<int>> buildHourlySeries(List<LoadedSeries> series) {
  final out = <String, List<int>>{};
  for (final s in series) {
    final m = data.machines.firstWhere((x) => x.id == s.id);
    final base = _baseSpeed(m, s.index);
    out[s.id] = [
      for (var h = 0; h <= 168; h++)
        isStopped(h, s.index)
            ? 0
            : (base + (seededNoise(h * 7 + s.seed * 31) - 0.5) * 7).round(),
    ];
  }
  return out;
}

/// Producción por día (7 días) por serie.
Map<String, List<int>> buildDailyProduction(List<LoadedSeries> series) {
  return {
    for (final s in series)
      s.id: [
        for (var d = 0; d < 7; d++)
          s.index < referenceDailyProduction.length
              ? referenceDailyProduction[s.index][d]
              : (15000 + seededNoise(d * 13 + s.seed * 17) * 9000).round(),
      ],
  };
}

List<HistoryStop> activeStops(List<LoadedSeries> series) => historyStops
    .where((s) => s.allMachines || series.any((x) => x.index == 0))
    .toList();
