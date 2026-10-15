import '../models/machine.dart';

const integradoVariables = <MonitoredVariable>[
  MonitoredVariable(
    'Estado de máquina',
    'DB_DATA.ESTADO_MAQUINA',
    'BOOL',
    'por evento',
  ),
  MonitoredVariable(
    'Velocidad de salida',
    'DB_DATA.VEL_SALIDA',
    'REAL',
    'cada 10 s',
  ),
  MonitoredVariable(
    'Velocidad de alimentación',
    'DB_DATA.VEL_ALIMENTACION',
    'REAL',
    'cada 10 s',
  ),
  MonitoredVariable('Metros', 'DB_DATA.METROS', 'DINT', 'cada 1 min'),
  MonitoredVariable(
    'Horas de trabajo (T1, T2, T3)',
    'DB_DATA.HORAS_TRABAJO[1..3]',
    'REAL',
    'cada 1 min',
  ),
  MonitoredVariable(
    'Horas de pausa (T1, T2, T3)',
    'DB_DATA.HORAS_PAUSA[1..3]',
    'REAL',
    'cada 1 min',
  ),
  MonitoredVariable(
    'Producción (T1, T2, T3)',
    'DB_DATA.PRODUCCION[1..3]',
    'DINT',
    'cada 1 min',
  ),
  MonitoredVariable(
    'Horómetro',
    'DB_DATA.HOROMETRO',
    'REAL',
    'cierre de turno',
  ),
];

const rompedoraVariables = <MonitoredVariable>[
  MonitoredVariable(
    'Estado de máquina',
    'DB_DATA.ESTADO_MAQUINA',
    'BOOL',
    'por evento',
  ),
  MonitoredVariable(
    'Velocidad de máquina',
    'DB_DATA.VEL_MAQUINA',
    'REAL',
    'cada 10 s',
  ),
  MonitoredVariable(
    'Velocidad de alimentación',
    'DB_DATA.VEL_ALIMENTACION',
    'REAL',
    'cada 10 s',
  ),
  MonitoredVariable(
    'Estiramiento',
    'DB_DATA.ESTIRAMIENTO',
    'REAL',
    'cada 10 s',
  ),
  MonitoredVariable(
    'Horas de trabajo (T1, T2, T3)',
    'DB_DATA.HORAS_TRABAJO[1..3]',
    'REAL',
    'cada 1 min',
  ),
  MonitoredVariable(
    'Horas de pausa (T1, T2, T3)',
    'DB_DATA.HORAS_PAUSA[1..3]',
    'REAL',
    'cada 1 min',
  ),
  MonitoredVariable(
    'Horómetro',
    'DB_DATA.HOROMETRO',
    'REAL',
    'cierre de turno',
  ),
];
