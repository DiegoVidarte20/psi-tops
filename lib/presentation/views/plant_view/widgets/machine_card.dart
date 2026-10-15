import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/format.dart';
import '../../../../data/models/machine.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/status_badge.dart';

class MachineCard extends StatefulWidget {
  const MachineCard({
    super.key,
    required this.machine,
    required this.tick,
    required this.seed,
  });

  final Machine machine;
  final int tick;
  final int seed;

  @override
  State<MachineCard> createState() => _MachineCardState();
}

class _MachineCardState extends State<MachineCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.machine;
    return Semantics(
      button: true,
      label: 'Ver detalle de ${m.name}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(
            context,
          ).pushReplacementNamed(AppRoutes.machine(m.id)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _hover ? AppColors.white : AppColors.surface,
              border: Border.all(
                color: _hover
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.line,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado: nombre + tipo + badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.sans(
                              size: 14.5,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m.type.name.toUpperCase(),
                            style: AppText.overline(size: 10.5, tracking: 0.12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(status: m.status),
                  ],
                ),
                const SizedBox(height: 12),
                // Métricas
                for (var i = 0; i < m.metrics.length; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  _MetricRow(
                    metric: m.metrics[i],
                    status: m.status,
                    tick: widget.tick,
                    seed: widget.seed,
                  ),
                ],
                const Spacer(),
                // Pie: horómetro + última lectura
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.line)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: AppText.sans(
                                size: 11.5,
                                color: AppColors.inkMuted,
                              ),
                              children: [
                                const TextSpan(text: 'Horómetro '),
                                TextSpan(
                                  text: formatNumber(m.horometro, 1),
                                  style: AppText.mono(
                                    size: 11.5,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                                const TextSpan(text: ' h'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          m.lastSeen,
                          softWrap: false,
                          style: AppText.sans(
                            size: 11.5,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.metric,
    required this.status,
    required this.tick,
    required this.seed,
  });

  final MachineMetric metric;
  final MachineStatus status;
  final int tick;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final value = metric.liveValue(status, tick, seed);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            metric.label,
            style: AppText.sans(size: 13, color: AppColors.inkMuted),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          formatNumber(value, metric.decimals),
          style: AppText.mono(
            size: 15,
            weight: FontWeight.w500,
            color: metric.value == 0 ? AppColors.inkFaint : AppColors.ink,
          ),
        ),
        if (metric.unit.isNotEmpty) ...[
          const SizedBox(width: 6),
          SizedBox(
            width: 36,
            child: Text(
              metric.unit,
              softWrap: false,
              style: AppText.mono(size: 11.5, color: AppColors.inkFaint),
            ),
          ),
        ],
      ],
    );
  }
}
