import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../routes/app_routes.dart';
import 'machine_nav_list.dart';
import 'nav_hover_tile.dart';
import 'sidebar_status.dart';

class _NavItem {
  final String label;
  final String route;
  final IconData icon;
  final bool Function(String path) match;
  const _NavItem(this.label, this.route, this.icon, this.match);
}

final _navItems = <_NavItem>[
  _NavItem(
    'Vista de planta',
    AppRoutes.plantView,
    LucideIcons.layoutGrid,
    (p) => p == AppRoutes.plantView,
  ),
  _NavItem(
    'Detalle de máquina',
    AppRoutes.machine(AppRoutes.defaultMachineId),
    LucideIcons.cpu,
    (p) => p.startsWith(AppRoutes.machineDetail),
  ),
  _NavItem(
    'Histórico y gráficas',
    AppRoutes.history,
    LucideIcons.trendingUp,
    (p) => p.startsWith(AppRoutes.history),
  ),
  _NavItem(
    'Base de datos',
    AppRoutes.database,
    LucideIcons.database,
    (p) => p.startsWith(AppRoutes.database),
  ),
  _NavItem(
    'Conexión y grabado',
    AppRoutes.connection,
    LucideIcons.cable,
    (p) => p.startsWith(AppRoutes.connection),
  ),
];

/// Sidebar navy (236 px en escritorio, drawer de 272 px en móvil).
class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  final String currentRoute;
  final void Function(String route) onNavigate;

  @override
  Widget build(BuildContext context) {
    final onDetail = currentRoute.startsWith(AppRoutes.machineDetail);

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLANTA TOPS',
            style: AppText.overline(
              color: Colors.white.withValues(alpha: 0.55),
              tracking: 0.14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Monitoreo de\nproducción',
            style: AppText.sans(
              size: 18,
              weight: FontWeight.w700,
              color: Colors.white,
              height: 1.25,
            ),
          ),
        ],
      ),
    );

    final nav = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in _navItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _NavLink(
                item: item,
                active: item.match(currentRoute),
                onTap: () => onNavigate(item.route),
              ),
            ),
        ],
      ),
    );

    final status = Padding(
      padding: const EdgeInsets.all(16),
      child: SidebarStatus(currentRoute: currentRoute),
    );

    return ColoredBox(
      color: AppColors.navy,
      child: LayoutBuilder(
        builder: (context, c) {
          // Pantallas muy bajas (móvil horizontal): todo el sidebar hace scroll.
          if (c.maxHeight < 560) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  nav,
                  if (onDetail)
                    MachineNavList(
                      currentRoute: currentRoute,
                      onNavigate: onNavigate,
                      scrollable: false,
                    ),
                  status,
                ],
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              nav,
              Expanded(
                child: onDetail
                    ? MachineNavList(
                        currentRoute: currentRoute,
                        onNavigate: onNavigate,
                      )
                    : const SizedBox.shrink(),
              ),
              status,
            ],
          );
        },
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : Colors.white.withValues(alpha: 0.85);
    return NavHoverTile(
      active: active,
      onTap: onTap,
      child: Row(
        children: [
          Icon(item.icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: AppText.sans(
                size: 14,
                weight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
