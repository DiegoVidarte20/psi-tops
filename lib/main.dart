import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/state/plc_controller.dart';
import 'core/theme/app_theme.dart';
import 'presentation/widgets/app_toast.dart';
import 'presentation/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null); // inicializa locale español
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Estado global de PLC / grabado (lo usan el sidebar y "Conexión y grabado").
  final _plc = PlcController();

  @override
  void dispose() {
    _plc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: AppToast.messengerKey,
      builder: (context, child) => PlcScope(controller: _plc, child: child!),
      title: 'Monitoreo de producción · Planta Tops',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateRoute: AppRoutes.generateRoute,
      // Evita que una URL profunda (ej. /maquina/integrado-2a) apile '/', '/maquina', ...
      onGenerateInitialRoutes: (name) => [
        AppRoutes.generateRoute(RouteSettings(name: name)),
      ],
      initialRoute: AppRoutes.plantView,
    );
  }
}
