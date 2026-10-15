/// Datos en duro de "Histórico y gráficas" (src/data/history.ts).
const historyDayLabels = [
  '07/10',
  '08/10',
  '09/10',
  '10/10',
  '11/10',
  '12/10',
  '13/10',
  '14/10',
];

class HistoryStop {
  final int from;
  final int to;
  final bool allMachines; // scope 'all' | 'first'
  const HistoryStop(this.from, this.to, {this.allMachines = false});
}

const historyStops = [
  HistoryStop(47, 51),
  HistoryStop(99, 107, allMachines: true),
  HistoryStop(140, 143),
];

const referenceDailyProduction = [
  [23800, 24600, 15700, 24100, 11100, 24900, 12300],
  [21300, 22100, 21800, 22500, 11400, 22800, 11000],
];

class ShiftHours {
  final String label;
  final double work;
  final double pause;
  const ShiftHours(this.label, this.work, this.pause);
}

const historyShiftHours = [
  ShiftHours('Turno 1 · 06:00–14:00', 104.2, 5.8),
  ShiftHours('Turno 2 · 14:00–22:00', 97.6, 12.4),
  ShiftHours('Turno 3 · 22:00–06:00', 96.6, 3.4),
];

class HistoryVariable {
  final String key;
  final String label;
  const HistoryVariable(this.key, this.label);
}

const historyVariables = [
  HistoryVariable('estado', 'Estado de máquina'),
  HistoryVariable('velSalida', 'Velocidad de salida'),
  HistoryVariable('velAlim', 'Velocidad de alimentación'),
  HistoryVariable('metros', 'Metros'),
  HistoryVariable('produccion', 'Producción'),
  HistoryVariable('horasTrabajo', 'Horas de trabajo'),
  HistoryVariable('horasPausa', 'Horas de pausa'),
  HistoryVariable('horometro', 'Horómetro'),
];
