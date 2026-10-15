import 'package:flutter/material.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_text.dart';
import '../../../widgets/app_card.dart';

class ClockBox extends StatelessWidget {
  const ClockBox({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label.toUpperCase(), style: AppText.overline()),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              softWrap: false,
              style: AppText.mono(
                size: context.isSm ? 19 : 16,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
