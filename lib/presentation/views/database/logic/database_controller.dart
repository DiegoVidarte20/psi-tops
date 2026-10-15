import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../../../data/mock/database_data.dart';

/// "Ahora" para los datos en duro (último registro). Con el backend real
/// reemplazar por DateTime.now().
final dataNow = DateTime(2026, 10, 14, 9, 50);

class DbFilters {
  DateTime from;
  DateTime to;
  String? range;
  String line; // 'todas' | '1'..'6'
  String machine; // 'todas' | id
  String variable; // 'todas' | key
  String shift; // 'todos' | 'T1' | 'T2' | 'T3'
  String state; // 'cualquiera' | 'marcha' | 'detenida'

  DbFilters({
    required this.from,
    required this.to,
    this.range = 'Este mes',
    this.line = 'todas',
    this.machine = 'integrado-1a',
    this.variable = 'todas',
    this.shift = 'todos',
    this.state = 'cualquiera',
  });

  factory DbFilters.initial() => DbFilters(
    from: DateTime(2026, 10, 1, 0, 0),
    to: DateTime(2026, 10, 14, 9, 50),
  );

  DbFilters copy() => DbFilters(
    from: from,
    to: to,
    range: range,
    line: line,
    machine: machine,
    variable: variable,
    shift: shift,
    state: state,
  );

  bool matches(DbRecord r) {
    // "Hasta" incluye todo el minuto (09:50 -> 09:50:59).
    final toEnd = to.add(const Duration(seconds: 59));
    if (r.time.isBefore(from) || r.time.isAfter(toEnd)) return false;
    if (line != 'todas' && r.line != 'Línea $line') return false;
    if (machine != 'todas' && r.machineId != machine) return false;
    if (variable != 'todas' && r.variableKey != variable) return false;
    if (shift != 'todos' && r.shift != shift) return false;
    final isSpeedOrState = r.unit == 'm/min' || r.unit == 'ON/OFF';
    if (state == 'marcha' && !(isSpeedOrState && r.running)) return false;
    if (state == 'detenida' && !(isSpeedOrState && !r.running)) return false;
    return true;
  }
}

/// Estado de la pestaña "Base de datos": filtros, búsqueda, paginación,
/// selección de filas y columnas a exportar.
class DatabaseController extends ChangeNotifier {
  DatabaseController() {
    _applyFilters();
    selected.addAll(_filtered.take(3).map((r) => r.id));
  }

  // ---------- Filtros ----------
  DbFilters draft = DbFilters.initial();
  DbFilters _applied = DbFilters.initial();
  List<DbRecord> _filtered = const [];

  void updateDraft(void Function(DbFilters f) change) {
    change(draft);
    notifyListeners();
  }

  void setQuickRange(String r) {
    final now = dataNow;
    draft.range = r;
    draft.to = now;
    draft.from = switch (r) {
      'Hoy' => DateTime(now.year, now.month, now.day),
      'Últimos 7 días' => DateTime(now.year, now.month, now.day - 7),
      'Este mes' => DateTime(now.year, now.month, 1),
      _ => DateTime(now.year, 1, 1),
    };
    notifyListeners();
  }

  /// Aplica los filtros y devuelve cuántos registros quedaron.
  int applyFilters() {
    _applied = draft.copy();
    _applyFilters();
    page = 1;
    selected.removeWhere((id) => !_filtered.any((r) => r.id == id));
    notifyListeners();
    return _filtered.length;
  }

  void clearFilters() {
    draft = DbFilters.initial();
    notifyListeners();
  }

  void _applyFilters() {
    _filtered = dbRecords.where(_applied.matches).toList();
  }

  // ---------- Búsqueda + paginación ----------
  String query = '';
  int page = 1;
  int perPage = 25;

  void setQuery(String q) {
    query = q;
    page = 1;
    notifyListeners();
  }

  void setPerPage(int v) {
    perPage = v;
    page = 1;
    notifyListeners();
  }

  void setPage(int p) {
    page = p.clamp(1, pageCount);
    notifyListeners();
  }

  int get filteredCount => _filtered.length;

  List<DbRecord> get visibleRows {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _filtered;
    return _filtered
        .where(
          (r) =>
              '${r.machine} ${r.variable} ${r.value} ${r.line} ${r.timeLabel}'
                  .toLowerCase()
                  .contains(q),
        )
        .toList();
  }

  int get pageCount => math.max(1, (visibleRows.length / perPage).ceil());

  List<DbRecord> get pageRows {
    final rows = visibleRows;
    final start = (page - 1) * perPage;
    if (start >= rows.length) return const [];
    return rows.sublist(start, math.min(start + perPage, rows.length));
  }

  /// "1 – 25" de la página actual (o "0" si no hay filas).
  String get rangeLabel {
    final total = visibleRows.length;
    if (total == 0) return '0';
    final start = (page - 1) * perPage + 1;
    final end = math.min(page * perPage, total);
    return '$start – $end';
  }

  // ---------- Selección de filas ----------
  final Set<int> selected = {};

  bool get pageAllSelected =>
      pageRows.isNotEmpty && pageRows.every((r) => selected.contains(r.id));

  void toggleRow(int id) {
    selected.contains(id) ? selected.remove(id) : selected.add(id);
    notifyListeners();
  }

  void togglePage() {
    final ids = pageRows.map((r) => r.id);
    pageAllSelected ? selected.removeAll(ids) : selected.addAll(ids);
    notifyListeners();
  }

  // ---------- Exportación ----------
  final Set<String> exportCols = {
    for (final c in exportColumns)
      if (c.checked) c.key,
  };
  String format = 'xlsx';
  String scope = 'filtrado';

  void toggleExportCol(String key) {
    exportCols.contains(key) ? exportCols.remove(key) : exportCols.add(key);
    notifyListeners();
  }

  void setAllExportCols(bool all) {
    exportCols.clear();
    if (all) exportCols.addAll(exportColumns.map((c) => c.key));
    notifyListeners();
  }

  void setFormat(String v) {
    format = v;
    notifyListeners();
  }

  void setScope(String v) {
    scope = v;
    notifyListeners();
  }
}
