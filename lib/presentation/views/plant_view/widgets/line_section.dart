import 'package:flutter/material.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/format.dart';
import '../../../../data/models/machine.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/responsive_grid.dart';
import 'machine_card.dart';

class LineSection extends StatelessWidget {
  const LineSection({
    super.key,
    required this.line,
    required this.machines,
    required this.tick,
  });

  final ProductionLine line;
  final List<Machine> machines;
  final int tick;

  @override
  Widget build(BuildContext context) {
    final production = machines.fold<double>(0, (s, m) => s + m.production);
    final loneLast = machines.length % 4 == 1;
    // grid-cols-1 · sm:grid-cols-2 · xl:grid-cols-4
    final columns = context.isXl ? 4 : (context.isSm ? 2 : 1);

    return AppCard(
      padding: EdgeInsets.all(context.isSm ? 18 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 16,
            runSpacing: 4,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 12,
                runSpacing: 2,
                children: [
                  Text(
                    line.name,
                    style: AppText.sans(size: 17, weight: FontWeight.w700),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      line.summary,
                      style: AppText.sans(
                        size: 12.5,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text.rich(
                  TextSpan(
                    style: AppText.mono(size: 12.5, color: AppColors.inkMuted),
                    children: [
                      const TextSpan(text: 'Producción turno: '),
                      TextSpan(
                        text: '${formatNumber(production)} m',
                        style: AppText.mono(
                          size: 12.5,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ResponsiveGrid(
            columns: columns,
            gap: 12,
            // La máquina "sola" al final ocupa todo el ancho (col-span-2 / col-span-4).
            span: (i) => loneLast && i == machines.length - 1 ? columns : 1,
            children: [
              for (var i = 0; i < machines.length; i++)
                MachineCard(
                  machine: machines[i],
                  tick: tick,
                  seed: line.id * 10 + i,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
