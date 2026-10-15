import 'package:flutter/material.dart';
import '../views/plant_view/plant_view_screen.dart';
import '../views/machine_detail/machine_detail_screen.dart';
import '../views/history/history_screen.dart';
import '../views/database/database_settings_screen.dart';
import '../views/connection/connection_recording_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const plantView = '/';
  static const machineDetail = '/maquina'; // /maquina/:machineId
  static const history = '/historico';
  static const database = '/base-datos';
  static const connection = '/conexion';

  static const defaultMachineId = 'integrado-1a';

  static String machine(String id) => '$machineDetail/$id';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? plantView);
    final segs = uri.pathSegments;

    if (segs.isEmpty) {
      return _page(plantView, const PlantViewScreen(), settings);
    }

    switch ('/${segs.first}') {
      case machineDetail:
        // /maquina -> redirige a la máquina por defecto (como en el diseño)
        final id = segs.length > 1 ? segs[1] : defaultMachineId;
        return _page(machine(id), MachineDetailScreen(machineId: id), settings);
      case history:
        return _page(history, const HistoryScreen(), settings);
      case database:
        return _page(database, const DatabaseSettingsScreen(), settings);
      case connection:
        return _page(connection, const ConnectionRecordingScreen(), settings);
      default:
        return _page(plantView, const PlantViewScreen(), settings);
    }
  }

  /// Sin animación: así el sidebar queda fijo al cambiar de sección (como en web).
  static Route<dynamic> _page(
    String name,
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: RouteSettings(name: name, arguments: settings.arguments),
      pageBuilder: (_, _, _) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}
