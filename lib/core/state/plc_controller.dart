import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../../data/mock/plc_data.dart';
import '../../data/models/plc.dart';
import '../../presentation/widgets/app_toast.dart';
import '../utils/format.dart';
import '../utils/time.dart';

/// Estado global de conexión a PLC y grabado (port de PlcContext.tsx).
/// Simulado: con el backend real (FastAPI / OPC UA) se reemplazan
/// connect/disconnect/_tick por llamadas al servicio.
class PlcController extends ChangeNotifier {
  PlcController({math.Random? random}) : _rnd = random ?? math.Random() {
    for (final d in devices) {
      tagsByPlc[d.id] = buildPlcTags(d);
      runtime[d.id] = PlcRuntime({
        for (final t in tagsByPlc[d.id]!)
          if (t.defaultSelected) t.id,
      });
    }
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  final math.Random _rnd;
  final List<PlcDevice> devices = plcDevices;
  final Map<String, List<PlcTag>> tagsByPlc = {};
  final Map<String, PlcRuntime> runtime = {};
  final List<Timer> _timers = [];
  Timer? _ticker;
  bool _disposed = false;

  // ---------- Grabado ----------
  bool recording = false;
  int elapsed = 0;
  int recordCount = 0;
  int interval = 1;
  final List<RecordEntry> log = [];
  int _logId = 0;

  // ---------- Derivados ----------
  int get connectedCount =>
      devices.where((d) => runtime[d.id]!.status == PlcStatus.connected).length;
  int get errorCount =>
      devices.where((d) => runtime[d.id]!.status == PlcStatus.error).length;
  int get connectingCount => devices
      .where((d) => runtime[d.id]!.status == PlcStatus.connecting)
      .length;
  int get recordableCount => devices
      .where((d) => runtime[d.id]!.status == PlcStatus.connected)
      .fold(0, (s, d) => s + runtime[d.id]!.selected.length);
  int get plcsWithSelection => devices
      .where(
        (d) =>
            runtime[d.id]!.status == PlcStatus.connected &&
            runtime[d.id]!.selected.isNotEmpty,
      )
      .length;
  bool get allConnected => connectedCount == devices.length;

  PlcDevice device(String id) => devices.firstWhere((d) => d.id == id);

  // ---------- Conexión ----------
  void connect(String id) {
    final r = runtime[id]!;
    if (r.status == PlcStatus.connecting || r.status == PlcStatus.connected) {
      return;
    }
    r
      ..status = PlcStatus.connecting
      ..error = null;
    notifyListeners();
    final d = device(id);
    final delay = Duration(milliseconds: 700 + _rnd.nextInt(900));
    _timers.add(
      Timer(delay, () {
        if (_disposed || r.status != PlcStatus.connecting) return;
        if (d.failFirstAttempt && r.attempts == 0) {
          r
            ..status = PlcStatus.error
            ..error = 'Sin respuesta del PLC · timeout 3 s'
            ..attempts += 1;
          notifyListeners();
          AppToast.errorGlobal(
            '${d.name}: sin respuesta',
            description: 'Revise el cableado de red o reintente la conexión.',
          );
          return;
        }
        r
          ..status = PlcStatus.connected
          ..latency = 8 + _rnd.nextInt(15)
          ..attempts += 1
          ..values = {for (final t in tagsByPlc[id]!) t.id: t.base};
        notifyListeners();
      }),
    );
  }

  void disconnect(String id) {
    final r = runtime[id]!
      ..status = PlcStatus.disconnected
      ..latency = null
      ..values = {}
      ..error = null;
    if (recording && recordableCount == 0) {
      recording = false;
      AppToast.infoGlobal(
        'Grabado detenido',
        description: 'No quedan PLC conectados con variables seleccionadas.',
      );
    }
    assert(r.status == PlcStatus.disconnected);
    notifyListeners();
  }

  void connectAll() {
    for (final d in devices) {
      final s = runtime[d.id]!.status;
      if (s == PlcStatus.disconnected || s == PlcStatus.error) connect(d.id);
    }
  }

  void disconnectAll() {
    for (final d in devices) {
      if (runtime[d.id]!.status != PlcStatus.disconnected) disconnect(d.id);
    }
  }

  // ---------- Selección de tags ----------
  void toggleTag(String plcId, String tagId) {
    final sel = runtime[plcId]!.selected;
    sel.contains(tagId) ? sel.remove(tagId) : sel.add(tagId);
    notifyListeners();
  }

  void setSelection(String plcId, Iterable<String> tagIds) {
    runtime[plcId]!.selected
      ..clear()
      ..addAll(tagIds);
    notifyListeners();
  }

  // ---------- Grabado ----------
  void startRecording() {
    if (recordableCount == 0) {
      AppToast.errorGlobal(
        'No hay variables para grabar',
        description: 'Conecte al menos un PLC y seleccione sus variables.',
      );
      return;
    }
    recording = true;
    elapsed = 0;
    recordCount = 0;
    log.clear();
    notifyListeners();
    AppToast.successGlobal(
      'Grabado iniciado',
      description: 'Los datos se guardan en la tabla registros_plc.',
    );
  }

  void stopRecording() {
    recording = false;
    notifyListeners();
    AppToast.successGlobal(
      'Grabado detenido',
      description:
          '${formatNumber(recordCount)} registros guardados en esta sesión.',
    );
  }

  void setInterval(int seconds) {
    interval = seconds;
    notifyListeners();
  }

  double _nextValue(PlcTag t, double? prev) {
    final current = prev ?? t.base;
    switch (t.mode) {
      case TagMode.counter:
        return current + t.rate;
      case TagMode.noise:
        if (t.variance == 0) return t.base;
        return t.base + (_rnd.nextDouble() - 0.5) * 2 * t.variance;
      case TagMode.state:
        return t.base;
    }
  }

  void _tick() {
    var changed = false;
    for (final d in devices) {
      final r = runtime[d.id]!;
      if (r.status != PlcStatus.connected) continue;
      r.values = {
        for (final t in tagsByPlc[d.id]!) t.id: _nextValue(t, r.values[t.id]),
      };
      r.latency = math.max(4, (r.latency ?? 12) + _rnd.nextInt(5) - 2);
      changed = true;
    }

    if (recording) {
      elapsed += 1;
      if (elapsed % interval == 0) {
        final time = formatClock(DateTime.now());
        final entries = <RecordEntry>[];
        for (final d in devices) {
          final r = runtime[d.id]!;
          if (r.status != PlcStatus.connected) continue;
          for (final t in tagsByPlc[d.id]!) {
            if (!r.selected.contains(t.id)) continue;
            entries.add(
              RecordEntry(
                id: ++_logId,
                time: time,
                plc: d.name,
                machine: t.machine,
                variable: t.name,
                address: t.address,
                dataType: t.dataType,
                value: r.values[t.id] ?? t.base,
                unit: t.unit,
                decimals: t.decimals,
              ),
            );
          }
        }
        recordCount += entries.length;
        log.insertAll(0, entries.reversed);
        if (log.length > 80) log.removeRange(80, log.length);
      }
      changed = true;
    }
    if (changed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }
}

/// Da acceso al [PlcController] en toda la app y reconstruye a quien lo use.
class PlcScope extends InheritedNotifier<PlcController> {
  const PlcScope({
    super.key,
    required PlcController controller,
    required super.child,
  }) : super(notifier: controller);

  static PlcController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PlcScope>()!.notifier!;
}
