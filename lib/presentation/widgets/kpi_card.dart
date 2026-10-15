import 'package:flutter/material.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import 'app_card.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.sub,
    this.valueColor = AppColors.ink,
    this.subColor = AppColors.inkMuted,
    this.valueSize,
  });

  final String label;
  final String value;
  final String? unit;
  final String? sub;
  final Color valueColor;
  final Color subColor;

  /// Tamaño del valor en web (en móvil se resta 2 px). Por defecto 30/26.
  final double? valueSize;

  @override
  Widget build(BuildContext context) {
    final sm = context.isSm;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 112),
      child: AppCard(
        padding: EdgeInsets.all(sm ? 18 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: AppText.overline(height: 1.25)),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: AppText.mono(
                      size: valueSize != null
                          ? (sm ? valueSize! : valueSize! - 2)
                          : (sm ? 30 : 26),
                      weight: FontWeight.w600,
                      color: valueColor,
                      height: 1,
                    ),
                  ),
                  if (unit != null) ...[
                    TextSpan(text: ' ', style: AppText.mono(size: 13)),
                    TextSpan(
                      text: unit,
                      style: AppText.mono(size: 13, color: AppColors.inkFaint),
                    ),
                  ],
                ],
              ),
            ),
            if (sub != null && sub!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                sub!,
                style: AppText.sans(size: 12, color: subColor, height: 1.375),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
