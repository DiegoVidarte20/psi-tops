import 'package:flutter/material.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/format.dart';
import '../../../../data/mock/history_data.dart';
import '../../../widgets/app_card.dart';

/// "Horas trabajo vs pausa por turno · rango".
class ShiftHoursPanel extends StatelessWidget {
  const ShiftHoursPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(context.isSm ? 18 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Horas trabajo vs pausa por turno · rango',
            style: AppText.sans(size: 15, weight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < historyShiftHours.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _ShiftBar(s: historyShiftHours[i]),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 4,
            children: const [
              _Key(color: AppColors.run, label: 'Horas trabajo'),
              _Key(color: AppColors.pause, label: 'Horas pausa'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShiftBar extends StatelessWidget {
  const _ShiftBar({required this.s});

  final ShiftHours s;

  @override
  Widget build(BuildContext context) {
    final workFlex = (s.work * 10).round();
    final pauseFlex = (s.pause * 10).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          children: [
            Text(
              s.label,
              style: AppText.sans(size: 13, weight: FontWeight.w600),
            ),
            Text(
              '${formatNumber(s.work, 1)} h / ${formatNumber(s.pause, 1)} h',
              style: AppText.mono(size: 13, color: AppColors.inkMuted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 10,
            child: Row(
              // stretch: sin esto las barras miden 0 px de alto
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: workFlex,
                  child: const ColoredBox(color: AppColors.run),
                ),
                Expanded(
                  flex: pauseFlex,
                  child: const ColoredBox(color: AppColors.pause),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: AppText.sans(size: 12.5, color: AppColors.inkMuted)),
    ],
  );
}
