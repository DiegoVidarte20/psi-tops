import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/mock/machines_data.dart';
import '../../data/models/machine.dart';
import '../routes/app_routes.dart';
import 'nav_hover_tile.dart';

/// Lista de máquinas que aparece en el sidebar dentro de "Detalle de máquina".
class MachineNavList extends StatelessWidget {
  const MachineNavList({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    this.scrollable = true,
  });

  final String currentRoute;
  final void Function(String route) onNavigate;
  final bool scrollable;

  static Color _dot(MachineStatus s) => switch (s) {
    MachineStatus.run => AppColors.runBright,
    MachineStatus.pause => AppColors.pause,
    MachineStatus.stop => AppColors.stopDot,
    MachineStatus.offline => Colors.white.withValues(alpha: 0.4),
  };

  @override
  Widget build(BuildContext context) {
    final ordered = [
      ...machines.where((m) => m.type == MachineType.integrado),
      ...machines.where((m) => m.type == MachineType.rompedora),
    ];
    final segs = Uri.parse(currentRoute).pathSegments;
    final activeId = segs.length > 1 ? segs[1] : null;

    Widget item(Machine m) {
      final route = AppRoutes.machine(m.id);
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: NavHoverTile(
          active: m.id == activeId,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          onTap: () => onNavigate(route),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _dot(m.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  m.name,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(
                    size: 13.5,
                    color: m.id == activeId
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final title = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'MÁQUINAS',
        style: AppText.overline(
          color: Colors.white.withValues(alpha: 0.55),
          tracking: 0.14,
        ),
      ),
    );

    if (!scrollable) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [title, const SizedBox(height: 12), ...ordered.map(item)],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const SizedBox(height: 12),
          Expanded(
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: WidgetStatePropertyAll(
                  Colors.white.withValues(alpha: 0.18),
                ),
                thickness: const WidgetStatePropertyAll(8),
                radius: const Radius.circular(4),
              ),
              child: ListView(
                padding: const EdgeInsets.only(right: 4),
                children: ordered.map(item).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
