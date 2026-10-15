import 'package:flutter/material.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../layout/app_shell.dart';
import '../../widgets/app_card.dart';
import 'logic/database_controller.dart';
import 'widgets/config_tables.dart';
import 'widgets/export_panel.dart';
import 'widgets/query_filters_panel.dart';
import 'widgets/records_table.dart';
import 'widgets/storage_summary.dart';

class DatabaseSettingsScreen extends StatelessWidget {
  const DatabaseSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const AppShell(child: _DatabaseBody());
}

enum _Tab {
  base('Base de datos'),
  variables('Variables por máquina'),
  turnos('Turnos'),
  usuarios('Usuarios');

  const _Tab(this.label);
  final String label;
}

class _DatabaseBody extends StatefulWidget {
  const _DatabaseBody();

  @override
  State<_DatabaseBody> createState() => _DatabaseBodyState();
}

class _DatabaseBodyState extends State<_DatabaseBody> {
  final _ctrl = DatabaseController();
  _Tab _tab = _Tab.base;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Configuración · Base de datos',
          style: AppText.sans(
            size: context.isSm ? 27 : 24,
            weight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tabla de registros históricos de las 25 máquinas · filtre, seleccione columnas, exporte o cargue en gráfica',
          style: AppText.sans(size: 13.5, color: AppColors.inkMuted),
        ),
        const SizedBox(height: 20),
        // Pestañas (scroll horizontal en móvil)
        Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: AppCard(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final t in _Tab.values) ...[
                    if (t != _Tab.values.first) const SizedBox(width: 4),
                    _TabButton(
                      label: t.label,
                      active: _tab == t,
                      onTap: () => setState(() => _tab = t),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_tab == _Tab.base)
          ListenableBuilder(
            listenable: _ctrl,
            builder: (context, _) => _BaseTab(ctrl: _ctrl),
          )
        else
          ConfigTables(
            key: ValueKey(_tab),
            tab: switch (_tab) {
              _Tab.variables => ConfigTab.variables,
              _Tab.turnos => ConfigTab.turnos,
              _ => ConfigTab.usuarios,
            },
          ),
      ],
    );
  }
}

class _BaseTab extends StatelessWidget {
  const _BaseTab({required this.ctrl});

  final DatabaseController ctrl;

  @override
  Widget build(BuildContext context) {
    final left = [
      QueryFiltersPanel(ctrl: ctrl),
      const SizedBox(height: 20),
      ExportPanel(ctrl: ctrl),
    ];
    final right = [
      RecordsTable(ctrl: ctrl),
      const SizedBox(height: 20),
      const StorageSummary(),
    ];

    // lg: [260px | 1fr] · xl: [280px | 1fr] · < lg: apilado
    if (context.isLg) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.isXl ? 280 : 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: left,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: right,
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [...left, const SizedBox(height: 20), ...right],
    );
  }
}

class _TabButton extends StatefulWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        button: true,
        selected: a,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: a
                  ? AppColors.navy
                  : _hover
                  ? AppColors.surface
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                widget.label,
                softWrap: false,
                style: AppText.sans(
                  size: 13,
                  weight: FontWeight.w600,
                  color: a ? Colors.white : AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
