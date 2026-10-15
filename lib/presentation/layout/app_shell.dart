import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../routes/app_routes.dart';
import 'sidebar.dart';

/// Layout común de las 5 secciones (equivale a AppLayout.tsx).
///
/// - >= 1024 px (lg): sidebar fijo de 236 px a la izquierda.
/// - <  1024 px: header navy de 56 px con hamburguesa a la IZQUIERDA y
///   drawer que sale desde la izquierda (272 px, máx. 85 % del ancho).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentRoute =
        ModalRoute.of(context)?.settings.name ?? AppRoutes.plantView;
    final width = context.screenWidth;
    final content = _MainContent(child: child);

    if (width >= Breakpoints.lg) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 236,
              child: Sidebar(
                currentRoute: currentRoute,
                onNavigate: (r) => _go(context, currentRoute, r),
              ),
            ),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const _MobileHeader(),
      drawerScrimColor: Colors.black.withValues(alpha: 0.5),
      drawer: Builder(
        builder: (drawerContext) => Drawer(
          width: math.min(272, width * 0.85),
          backgroundColor: AppColors.navy,
          shape: const RoundedRectangleBorder(),
          child: Stack(
            children: [
              Positioned.fill(
                child: SafeArea(
                  right: false,
                  child: Sidebar(
                    currentRoute: currentRoute,
                    onNavigate: (r) =>
                        _go(drawerContext, currentRoute, r, fromDrawer: true),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 20 + MediaQuery.paddingOf(context).top,
                child: _IconSquare(
                  icon: LucideIcons.x,
                  size: 36,
                  tooltip: 'Cerrar menú',
                  onTap: () => Scaffold.of(drawerContext).closeDrawer(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: content,
    );
  }

  static void _go(
    BuildContext context,
    String current,
    String target, {
    bool fromDrawer = false,
  }) {
    if (current == target) {
      if (fromDrawer) Scaffold.of(context).closeDrawer();
      return;
    }
    Navigator.of(context).pushReplacementNamed(target);
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final h = context.isLg ? 32.0 : (context.isSm ? 24.0 : 16.0);
    final v = context.isLg ? 24.0 : 20.0;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1480),
          child: child,
        ),
      ),
    );
  }
}

class _MobileHeader extends StatelessWidget implements PreferredSizeWidget {
  const _MobileHeader();

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navy,
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.2,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  _IconSquare(
                    icon: LucideIcons.menu,
                    size: 40,
                    tooltip: 'Abrir menú',
                    onTap: () => Scaffold.of(context).openDrawer(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PLANTA TOPS',
                          style: AppText.overline(
                            size: 10,
                            color: Colors.white.withValues(alpha: 0.55),
                            tracking: 0.14,
                            height: 1.25,
                          ),
                        ),
                        Text(
                          'Monitoreo de producción',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.sans(
                            size: 15,
                            weight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconSquare extends StatefulWidget {
  const _IconSquare({
    required this.icon,
    required this.size,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final String tooltip;

  @override
  State<_IconSquare> createState() => _IconSquareState();
}

class _IconSquareState extends State<_IconSquare> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _hover ? AppColors.navy700 : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(widget.icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
