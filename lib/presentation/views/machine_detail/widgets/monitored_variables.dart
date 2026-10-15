import 'package:flutter/material.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../data/mock/variables_data.dart';
import '../../../../data/models/machine.dart';
import '../../../widgets/app_card.dart';

/// "Variables monitoreadas" (tags del DB_DATA del PLC).
class MonitoredVariables extends StatelessWidget {
  const MonitoredVariables({super.key, required this.machine});

  final Machine machine;

  @override
  Widget build(BuildContext context) {
    final vars = machine.type == MachineType.integrado
        ? integradoVariables
        : rompedoraVariables;
    return AppCard(
      padding: EdgeInsets.all(context.isSm ? 18 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Variables monitoreadas',
            style: AppText.sans(size: 15, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final v in vars)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.lineSoft)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(v.name, style: AppText.sans(size: 12.5)),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      v.tag,
                      textAlign: TextAlign.right,
                      style: AppText.mono(
                        size: 11.5,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Origen: ${machine.plc} · lectura 1 s · retención 5 años',
            style: AppText.sans(size: 12, color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}
