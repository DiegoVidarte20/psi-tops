import '../../../../core/utils/random.dart';
import '../../../../core/utils/time.dart';
import '../../../../data/models/machine.dart';

/// Rango de las gráficas del detalle.
enum RangeKey {
  h1('1 h', 60),
  h2('2 h', 120),
  h8('8 h', 480),
  turno('Turno', 0),
  h24('24 h', 1440);

  const RangeKey(this.label, this.minutes);
  final String label;
  final int minutes; // 0 = se calcula desde el inicio del turno
}

class DetailPoint {
  final String t;
  final int out;
  final int feed;
  final int on;
  DetailPoint(this.t, this.out, this.feed, this.on);
}

class StopWindow {
  final int fromIndex;
  final int toIndex;
  final int minutes;
  const StopWindow(this.fromIndex, this.toIndex, this.minutes);
}

class DetailSeries {
  final List<DetailPoint> points;
  final StopWindow? stop;
  final List<int> tickIndexes;
  const DetailSeries(this.points, this.stop, this.tickIndexes);
}

const _points = 61;

/// Port de buildDetailSeries (utils/machineSeries.ts).
DetailSeries buildDetailSeries(
  Machine machine,
  int rangeMinutes,
  DateTime now,
  int seed,
) {
  final step = rangeMinutes / (_points - 1);
  final outLive = machine.outputSpeed;
  final feedLive = machine.feedSpeed;
  final integrado = machine.type == MachineType.integrado;
  final outBase = outLive != 0 ? outLive : (integrado ? 178.0 : 140.0);
  final feedBase = feedLive != 0 ? feedLive : (integrado ? 171.0 : 41.0);

  final (double, double) off = switch (machine.status) {
    MachineStatus.run => (0.36, 0.48),
    MachineStatus.pause => (0.9, 1.01),
    _ => (0.42, 1.01),
  };

  final points = <DetailPoint>[];
  var fromIdx = -1;
  var toIdx = _points - 1;
  for (var i = 0; i < _points; i++) {
    final frac = i / (_points - 1);
    final time = now.subtract(
      Duration(milliseconds: ((rangeMinutes - i * step) * 60000).round()),
    );
    final isOff = frac >= off.$1 && frac < off.$2;
    if (isOff && fromIdx == -1) fromIdx = i;
    if (!isOff && fromIdx != -1 && toIdx == _points - 1 && i > fromIdx) {
      toIdx = i;
    }
    final ramp =
        machine.status == MachineStatus.run &&
            frac >= off.$2 &&
            frac < off.$2 + 0.035
        ? 0.88
        : 1.0;
    final n = seededNoise(seed * 100 + i) - 0.5;
    points.add(
      DetailPoint(
        formatClock(time, withSeconds: false),
        isOff ? 0 : ((outBase + n * 5) * ramp).round(),
        isOff ? 0 : ((feedBase + n * 4) * ramp).round(),
        isOff ? 0 : 1,
      ),
    );
  }
  if (machine.status == MachineStatus.run) {
    final last = points[_points - 1];
    points[_points - 1] = DetailPoint(
      last.t,
      outLive.round(),
      feedLive.round(),
      last.on,
    );
  }

  final stop = fromIdx >= 0
      ? StopWindow(fromIdx, toIdx, ((toIdx - fromIdx) * step).round())
      : null;
  return DetailSeries(points, stop, const [0, 15, 30, 45, 60]);
}
