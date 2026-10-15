import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:psi_tops/core/theme/app_colors.dart';
import 'package:psi_tops/main.dart';
import 'package:psi_tops/presentation/views/history/widgets/shift_hours_panel.dart';
import 'package:psi_tops/presentation/views/machine_detail/widgets/shifts_table.dart';

/// Ajusta el tamaño de la "pantalla" del test (en px lógicos).
void setScreen(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Carga IBM Plex desde los assets de la app para que los textos midan
/// igual que en el dispositivo (la fuente por defecto de los tests es más ancha).
Future<void> loadAppFonts() async {
  const fonts = {
    'IBMPlexSans': ['Regular', 'Medium', 'SemiBold', 'Bold'],
    'IBMPlexMono': ['Regular', 'Medium', 'SemiBold'],
  };
  for (final e in fonts.entries) {
    final loader = FontLoader(e.key);
    for (final w in e.value) {
      loader.addFont(rootBundle.load('assets/fonts/${e.key}-$w.ttf'));
    }
    await loader.load();
  }
}

void main() {
  setUpAll(loadAppFonts);

  group('Escritorio (1440 x 900)', () {
    testWidgets('muestra sidebar fijo y la vista de planta', (tester) async {
      setScreen(tester, const Size(1440, 900));
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      // Sidebar fijo con las 5 secciones, sin hamburguesa
      expect(find.text('Vista de planta'), findsOneWidget);
      expect(find.text('Detalle de máquina'), findsOneWidget);
      expect(find.text('Histórico y gráficas'), findsOneWidget);
      expect(
        find.text('Base de datos'),
        findsWidgets,
      ); // nav + bloque de estado
      expect(find.text('Conexión y grabado'), findsOneWidget);
      expect(find.byIcon(LucideIcons.menu), findsNothing);

      // Contenido de la vista de planta
      expect(find.text('Estado de planta en tiempo real'), findsOneWidget);
      expect(find.text('EN MARCHA'), findsOneWidget);
      expect(find.text('PRODUCCIÓN DEL TURNO'), findsOneWidget);
      expect(find.text('Línea 1'), findsOneWidget);
      expect(find.text('Línea 6'), findsOneWidget);
      expect(find.text('Integrado 1A'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('navega a otra sección desde el sidebar', (tester) async {
      setScreen(tester, const Size(1440, 900));
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      await tester.tap(find.text('Histórico y gráficas'));
      await tester.pumpAndSettle();

      expect(find.text('Guardar vista'), findsOneWidget);
      expect(find.text('Estado de planta en tiempo real'), findsNothing);
    });

    testWidgets('clic en una máquina abre su detalle', (tester) async {
      setScreen(tester, const Size(1440, 900));
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      await tester.ensureVisible(find.text('Integrado 2A'));
      await tester.pump();
      await tester.tap(find.text('Integrado 2A'));
      await tester.pumpAndSettle();

      // Lista de máquinas en el sidebar + contenido del detalle
      expect(find.text('MÁQUINAS'), findsOneWidget);
      expect(find.text('Línea 2 · PLC L2-INT · DB_DATA'), findsOneWidget);
      expect(
        find.text('Estado de máquina · encendido / apagado'),
        findsOneWidget,
      );
    });
  });

  group('Móvil (390 x 844)', () {
    testWidgets('usa header con hamburguesa y oculta el sidebar', (
      tester,
    ) async {
      setScreen(tester, const Size(390, 844));
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      expect(find.byIcon(LucideIcons.menu), findsOneWidget);
      expect(find.text('Monitoreo de producción'), findsOneWidget);
      expect(find.text('Vista de planta'), findsNothing);
      expect(find.text('Estado de planta en tiempo real'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('el drawer se abre desde la IZQUIERDA y navega', (
      tester,
    ) async {
      setScreen(tester, const Size(390, 844));
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      await tester.tap(find.byIcon(LucideIcons.menu));
      await tester.pumpAndSettle();

      final drawer = find.byType(Drawer);
      expect(drawer, findsOneWidget);
      expect(tester.getTopLeft(drawer).dx, 0); // pegado al borde izquierdo
      expect(tester.getSize(drawer).width, lessThanOrEqualTo(272));
      expect(find.text('Vista de planta'), findsOneWidget);

      await tester.tap(find.text('Conexión y grabado'));
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsNothing);
      expect(find.text('PLC en red'), findsOneWidget);
    });

    testWidgets('el botón X cierra el drawer', (tester) async {
      setScreen(tester, const Size(390, 844));
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      await tester.tap(find.byIcon(LucideIcons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(LucideIcons.x));
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsNothing);
      expect(find.text('Estado de planta en tiempo real'), findsOneWidget);
    });
  });

  group('Detalle de máquina', () {
    Future<void> openDetail(WidgetTester tester, Size size, String id) async {
      setScreen(tester, size);
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.pushReplacementNamed('/maquina/$id');
      await tester.pumpAndSettle();
    }

    testWidgets('web: KPIs, gráficas, turnos y variables', (tester) async {
      await openDetail(tester, const Size(1440, 900), 'integrado-1a');

      expect(find.text('En marcha desde 06:12'), findsOneWidget);
      expect(find.text('VELOCIDAD DE SALIDA'), findsOneWidget);
      expect(find.text('HORÓMETRO'), findsOneWidget);
      expect(
        find.text('Estado de máquina · encendido / apagado'),
        findsOneWidget,
      );
      expect(find.text('Velocidad de máquina (m/min)'), findsOneWidget);
      expect(find.text('Turnos de hoy'), findsOneWidget);
      expect(find.text('Variables monitoreadas'), findsOneWidget);
      expect(find.text('DB_DATA.VEL_SALIDA'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Columna derecha fija de 340 px a la derecha de las gráficas
      final speed = tester.getRect(find.text('Velocidad de máquina (m/min)'));
      final shifts = tester.getRect(find.text('Turnos de hoy'));
      expect(shifts.left, greaterThan(speed.left + 300));
    });

    testWidgets('botones de rango compactos (web y móvil)', (tester) async {
      for (final size in const [Size(1440, 900), Size(390, 844)]) {
        await openDetail(tester, size, 'integrado-1a');
        final title = tester.getRect(
          find.text('Estado de máquina · encendido / apagado'),
        );
        final b1 = tester.getRect(find.text('1 h'));
        final b24 = tester.getRect(find.text('24 h'));
        // Todos los botones en una sola fila, angostos (no estirados)
        expect(b24.top, b1.top);
        for (final l in const ['1 h', '2 h', '8 h', 'Turno', '24 h']) {
          final btn = find.ancestor(
            of: find.text(l),
            matching: find.byType(AnimatedContainer),
          );
          expect(tester.getSize(btn.first).width, lessThan(100));
        }
        if (size.width >= 1024) {
          // Web: título a la izquierda y botones a la derecha, misma fila
          expect((b1.center.dy - title.center.dy).abs(), lessThan(12));
          expect(b1.left, greaterThan(title.right));
        } else {
          // Móvil: botones debajo del título
          expect(b1.top, greaterThan(title.bottom));
        }
      }
    });

    testWidgets('web: cambia el rango de la gráfica', (tester) async {
      await openDetail(tester, const Size(1440, 900), 'integrado-1a');
      await tester.tap(find.text('24 h'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Turno'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('web: rompedora muestra sus KPIs propios', (tester) async {
      await openDetail(tester, const Size(1440, 900), 'rompedora-2a');
      expect(find.text('VELOCIDAD DE MÁQUINA'), findsOneWidget);
      expect(find.text('ESTIRAMIENTO'), findsOneWidget);
      expect(find.text('DB_DATA.ESTIRAMIENTO'), findsOneWidget);
    });

    testWidgets('web: botón Ver histórico navega', (tester) async {
      await openDetail(tester, const Size(1440, 900), 'integrado-1a');
      await tester.tap(find.text('Ver histórico'));
      await tester.pumpAndSettle();
      expect(find.text('Histórico y gráficas'), findsWidgets);
      expect(find.text('Guardar vista'), findsOneWidget);
    });

    testWidgets('móvil: todo apilado y sin errores', (tester) async {
      await openDetail(tester, const Size(360, 800), 'integrado-2b');
      expect(find.text('En pausa desde 09:38'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // En móvil la tabla de turnos va debajo de las gráficas
      await tester.scrollUntilVisible(
        find.text('Turnos de hoy'),
        300,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .first,
      );
      final speed = tester.getRect(find.text('Velocidad de máquina (m/min)'));
      final shifts = tester.getRect(find.text('Turnos de hoy'));
      expect(shifts.top, greaterThan(speed.top));
      expect(tester.takeException(), isNull);
    });

    testWidgets('máquina inexistente muestra aviso', (tester) async {
      await openDetail(tester, const Size(1440, 900), 'no-existe');
      expect(find.text('Máquina no encontrada'), findsOneWidget);
    });
  });

  group('Histórico y gráficas', () {
    Future<void> openHistory(WidgetTester tester, Size size) async {
      setScreen(tester, size);
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushReplacementNamed('/historico');
      await tester.pumpAndSettle();
    }

    Finder vScroll() => find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .first;

    testWidgets('web: filtros en 6 columnas, KPIs y gráficas', (tester) async {
      await openHistory(tester, const Size(1440, 900));

      expect(find.text('DESDE'), findsOneWidget);
      expect(find.text('AGRUPACIÓN'), findsOneWidget);
      expect(find.text('MÁQUINAS A GRAFICAR'), findsOneWidget);
      expect(find.text('REGISTROS CARGADOS'), findsOneWidget);
      expect(find.text('PARADAS DETECTADAS'), findsOneWidget);
      // xl: los 6 campos en una sola fila
      expect(
        tester.getRect(find.text('AGRUPACIÓN')).top,
        tester.getRect(find.text('DESDE')).top,
      );
      // Por defecto se cargan Integrado 1A e Integrado 1B
      expect(find.text('Integrado 1A + Integrado 1B'), findsOneWidget);
      expect(
        find.text('Producción por día (m) · Integrado 1A vs 1B'),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.text('Horas trabajo vs pausa por turno · rango'),
        300,
        scrollable: vScroll(),
      );
      // lg: barras y panel de turnos lado a lado
      final bars = tester.getRect(
        find.text('Producción por día (m) · Integrado 1A vs 1B'),
      );
      final hours = tester.getRect(
        find.text('Horas trabajo vs pausa por turno · rango'),
      );
      expect((bars.top - hours.top).abs(), lessThan(4));
      expect(hours.left, greaterThan(bars.right));
      expect(tester.takeException(), isNull);
    });

    testWidgets('sin máquinas: Cargar datos muestra error', (tester) async {
      await openHistory(tester, const Size(1440, 900));
      await tester.tap(find.text('Limpiar filtros'));
      await tester.pump();
      await tester.tap(find.text('Cargar datos'));
      await tester.pump();
      expect(
        find.text('Seleccione al menos una máquina para graficar'),
        findsOneWidget,
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('cargar otra selección actualiza las series', (tester) async {
      await openHistory(tester, const Size(1440, 900));
      // agrega Rompedora 1A (tipo: Todos no es necesario, el chip es de la línea)
      await tester.tap(find.text('Rompedora 1A'));
      await tester.pump();
      await tester.tap(find.text('Cargar datos'));
      await tester.pump();
      expect(find.text('Cargando'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(
        find.text('Rompedora 1A + Integrado 1A + Integrado 1B'),
        findsOneWidget,
      );
      expect(find.text('3 máquinas'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('móvil: todo apilado y sin errores', (tester) async {
      await openHistory(tester, const Size(390, 844));
      // 1 columna: "Hasta" debajo de "Desde"
      expect(
        tester.getRect(find.text('HASTA')).top,
        greaterThan(tester.getRect(find.text('DESDE')).bottom),
      );
      // Botones Cargar / Limpiar en la misma fila
      await tester.scrollUntilVisible(
        find.text('Limpiar filtros'),
        300,
        scrollable: vScroll(),
      );
      expect(
        tester.getRect(find.text('Cargar datos')).top,
        tester.getRect(find.text('Limpiar filtros')).top,
      );
      await tester.scrollUntilVisible(
        find.text('Horas trabajo vs pausa por turno · rango'),
        300,
        scrollable: vScroll(),
      );
      final bars = tester.getRect(
        find.text('Producción por día (m) · Integrado 1A vs 1B'),
      );
      final hours = tester.getRect(
        find.text('Horas trabajo vs pausa por turno · rango'),
      );
      expect(hours.top, greaterThan(bars.bottom));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Desde/Hasta alineados con los selects y abren calendario', (
      tester,
    ) async {
      await openHistory(tester, const Size(1440, 900));
      final desde = tester.getRect(
        find
            .ancestor(
              of: find.text('07/10/2026 06:00'),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final linea = tester.getRect(
        find
            .ancestor(
              of: find.byType(DropdownButton<int>),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(desde.height, linea.height);
      expect(desde.top, linea.top);

      await tester.tap(find.text('07/10/2026 06:00'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget); // en español
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsNothing);
    });

    testWidgets('barras verde/ámbar visibles (horas por turno)', (
      tester,
    ) async {
      await openHistory(tester, const Size(1440, 900));
      Finder bars(Color c) => find.descendant(
        of: find.byType(ShiftHoursPanel),
        matching: find.byWidgetPredicate(
          (w) => w is ColoredBox && w.color == c,
        ),
      );
      expect(bars(AppColors.run), findsNWidgets(3));
      expect(bars(AppColors.pause), findsNWidgets(3));
      for (var i = 0; i < 3; i++) {
        expect(tester.getSize(bars(AppColors.run).at(i)).height, 10);
        expect(tester.getSize(bars(AppColors.pause).at(i)).height, 10);
      }
    });
  });

  testWidgets('barra de disponibilidad visible (detalle de máquina)', (
    tester,
  ) async {
    setScreen(tester, const Size(1440, 900));
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushReplacementNamed('/maquina/integrado-1a');
    await tester.pumpAndSettle();
    final run = find.descendant(
      of: find.byType(ShiftsTable),
      matching: find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == AppColors.run,
      ),
    );
    expect(tester.getSize(run).height, 8);
  });

  group('Base de datos', () {
    Future<void> openDb(WidgetTester tester, Size size) async {
      setScreen(tester, size);
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushReplacementNamed('/base-datos');
      await tester.pumpAndSettle();
    }

    Finder vScroll() => find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .first;

    Future<void> showPager(WidgetTester tester) => tester.scrollUntilVisible(
      find.text('Filas por página'),
      300,
      scrollable: vScroll(),
    );

    // Integrado 1A: 12 del diseño + 300×2 velocidades + 50 estados = 662
    const total = '662 registros filtrados';

    testWidgets('web: columna de filtros + tabla + resumen', (tester) async {
      await openDb(tester, const Size(1440, 900));
      expect(find.text('Filtros de consulta'), findsOneWidget);
      expect(find.text('Tabla de registros'), findsOneWidget);
      expect(find.textContaining('$total · mostrando 1 – 25'), findsOneWidget);
      // xl: columna izquierda de 280 px a la izquierda de la tabla
      final filters = tester.getRect(find.text('Filtros de consulta'));
      final table = tester.getRect(find.text('Tabla de registros'));
      expect(table.left, greaterThan(filters.left + 270));
      expect((table.top - filters.top).abs(), lessThan(4));
      expect(tester.takeException(), isNull);
    });

    testWidgets('paginación: páginas, flechas y filas por página', (
      tester,
    ) async {
      await openDb(tester, const Size(1440, 900));
      await showPager(tester);
      // 662 / 25 = 27 páginas -> ‹ 1 2 3 … 27 ›
      expect(find.text('27'), findsOneWidget);

      await tester.tap(find.text('2').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('mostrando 26 – 50'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Página siguiente'));
      await tester.pumpAndSettle();
      expect(find.textContaining('mostrando 51 – 75'), findsOneWidget);

      await tester.tap(find.text('27'));
      await tester.pumpAndSettle();
      expect(find.textContaining('mostrando 651 – 662'), findsOneWidget);

      // 100 filas por página -> vuelve a la página 1, 7 páginas
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('100').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('mostrando 1 – 100'), findsOneWidget);
      await showPager(tester);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('27'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('búsqueda sin resultados muestra aviso', (tester) async {
      await openDb(tester, const Size(1440, 900));
      await tester.enterText(find.byType(TextField), 'zzz-no-existe');
      await tester.pumpAndSettle();
      expect(find.textContaining('0 registros filtrados'), findsOneWidget);
      expect(
        find.text('Ningún registro coincide con «zzz-no-existe».'),
        findsOneWidget,
      );
    });

    testWidgets('aplicar filtros (todas las máquinas) cambia el total', (
      tester,
    ) async {
      await openDb(tester, const Size(1440, 900));
      await tester.tap(find.text('Integrado 1A').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Todas las máquinas').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pump();
      expect(
        find.textContaining('3\u00A0262 registros filtrados'),
        findsOneWidget,
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('pestañas de configuración', (tester) async {
      await openDb(tester, const Size(1440, 900));
      await tester.tap(find.text('Usuarios'));
      await tester.pumpAndSettle();
      expect(find.text('Carlos Huamán'), findsOneWidget);
      await tester.tap(find.text('Turnos'));
      await tester.pumpAndSettle();
      expect(find.text('Cierre 14:05 · Excel'), findsOneWidget);
      await tester.tap(find.text('Variables por máquina'));
      await tester.pumpAndSettle();
      expect(find.text('DB_DATA.VEL_SALIDA'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('móvil: apilado, tabla con scroll y paginación', (
      tester,
    ) async {
      await openDb(tester, const Size(390, 844));
      await showPager(tester);
      final filters = tester.getRect(find.text('Filtros de consulta'));
      final table = tester.getRect(find.text('Tabla de registros'));
      expect(table.top, greaterThan(filters.bottom));
      // móvil: 0 vecinos -> ‹ 1 … 27 ›
      expect(find.text('27'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Página siguiente'));
      await tester.pumpAndSettle();
      expect(find.textContaining('mostrando 26 – 50'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Conexión y grabado', () {
    Future<void> openConn(WidgetTester tester, Size size) async {
      setScreen(tester, size);
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushReplacementNamed('/conexion');
      await tester.pumpAndSettle();
    }

    // Conectar tarda 0,7–1,6 s (no usar pumpAndSettle: el spinner gira).
    Future<void> waitConnect(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
    }

    testWidgets('web: lista de 12 PLC + detalle al costado', (tester) async {
      await openConn(tester, const Size(1440, 900));
      expect(find.text('PLC en red'), findsOneWidget);
      expect(find.text('PLC L6-INT'), findsOneWidget);
      expect(find.text('Datos del PLC a grabar'), findsOneWidget);
      expect(find.text('Aún no hay datos grabados'), findsOneWidget);
      // lg: detalle a la derecha de la lista de 360 px
      final list = tester.getRect(find.text('PLC en red'));
      final detail = tester.getRect(find.text('Datos del PLC a grabar'));
      expect(detail.left, greaterThan(list.left + 350));
      // Por defecto se muestra PLC L1-INT
      expect(find.text('PLC L1-INT'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('conectar PLC: estado, valores, KPI y sidebar', (tester) async {
      await openConn(tester, const Size(1440, 900));
      // sidebar + KPI "PLC conectados"
      expect(find.text('0 / 12'), findsNWidgets(2));
      // botón grande del detalle
      await tester.tap(find.text('Conectar').last);
      await tester.pump();
      expect(find.text('Conectando'), findsWidgets);
      await waitConnect(tester);
      expect(find.text('Conectado'), findsOneWidget); // badge del detalle
      expect(find.text('1 / 12'), findsNWidgets(2)); // sidebar en vivo + KPI
      expect(find.text('Desconectar'), findsNWidgets(2));
      expect(find.text('ON'), findsWidgets); // Estado de máquina = ON
      expect(tester.takeException(), isNull);
    });

    testWidgets('L5-ROM falla el primer intento y luego reintenta', (
      tester,
    ) async {
      await openConn(tester, const Size(1440, 900));
      await tester.ensureVisible(find.text('PLC L5-ROM'));
      await tester.pump();
      await tester.tap(find.text('PLC L5-ROM'));
      await tester.pump();
      // botón grande del detalle (el título del detalle ya es L5-ROM)
      expect(find.text('PLC L5-ROM'), findsNWidgets(2));
      await tester.ensureVisible(find.text('Conectar').last);
      await tester.pump();
      await tester.tap(find.text('Conectar').last);
      await waitConnect(tester);
      expect(find.text('PLC L5-ROM: sin respuesta'), findsOneWidget); // toast
      expect(find.text('Reintentar'), findsNWidgets(2));
      expect(find.textContaining('Revise el cable de red'), findsOneWidget);
      expect(find.text('1 sin respuesta · revisar red'), findsOneWidget);

      await tester.ensureVisible(find.text('Reintentar').last);
      await tester.pump();
      await tester.tap(find.text('Reintentar').last);
      await waitConnect(tester);
      expect(find.text('Reintentar'), findsNothing);
      expect(find.text('1 / 12'), findsNWidgets(2));
    });

    testWidgets('grabado: iniciar, registrar y detener', (tester) async {
      await openConn(tester, const Size(1440, 900));
      // Sin PLC conectados no se puede grabar
      await tester.tap(find.text('Iniciar grabado'));
      await tester.pump();
      expect(find.text('Grabado iniciado'), findsNothing);

      await tester.tap(find.text('Conectar').last); // PLC L1-INT
      await waitConnect(tester);
      await tester.tap(find.text('Iniciar grabado'));
      await tester.pump();
      expect(find.text('Grabado iniciado'), findsOneWidget);
      expect(find.text('Activo'), findsOneWidget); // sidebar

      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Aún no hay datos grabados'), findsNothing);
      expect(find.textContaining('Mostrando los últimos'), findsOneWidget);
      expect(find.text('PLC L1-INT'), findsWidgets);

      await tester.tap(find.text('Detener grabado'));
      await tester.pump();
      expect(find.text('Iniciar grabado'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('filtro "Conectados" sin PLC muestra aviso', (tester) async {
      await openConn(tester, const Size(1440, 900));
      await tester.tap(find.text('Conectados'));
      await tester.pump();
      expect(find.text('Ningún PLC coincide con el filtro.'), findsOneWidget);
    });

    testWidgets('móvil: apilado y al tocar un PLC baja al detalle', (
      tester,
    ) async {
      await openConn(tester, const Size(390, 844));
      expect(tester.takeException(), isNull);
      final list = tester.getRect(find.text('PLC en red'));
      final detail = tester.getRect(find.text('Datos del PLC a grabar'));
      expect(detail.top, greaterThan(list.bottom));

      await tester.ensureVisible(find.text('PLC L3-ROM'));
      await tester.pump();
      await tester.tap(find.text('PLC L3-ROM'));
      await tester.pumpAndSettle();
      // el título del detalle quedó visible arriba
      final title = tester.getRect(find.text('PLC L3-ROM').last);
      expect(title.top, lessThan(844 / 2));
      expect(tester.takeException(), isNull);
    });
  });
}
