import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/models/machine.dart';

class StatusColors {
  final Color soft;
  final Color strong;
  final Color dot;
  const StatusColors(this.soft, this.strong, this.dot);

  static StatusColors of(MachineStatus s) => switch (s) {
    MachineStatus.run => const StatusColors(
      AppColors.runSoft,
      AppColors.runStrong,
      AppColors.run,
    ),
    MachineStatus.pause => const StatusColors(
      AppColors.pauseSoft,
      AppColors.pauseStrong,
      AppColors.pause,
    ),
    MachineStatus.stop => const StatusColors(
      AppColors.stopSoft,
      AppColors.stopStrong,
      AppColors.stop,
    ),
    MachineStatus.offline => const StatusColors(
      AppColors.offlineSoft,
      AppColors.offlineStrong,
      AppColors.offline,
    ),
  };
}

enum BadgeSize { sm, md }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.label,
    this.size = BadgeSize.sm,
  });

  final MachineStatus status;
  final String? label;
  final BadgeSize size;

  @override
  Widget build(BuildContext context) {
    final c = StatusColors.of(status);
    final sm = size == BadgeSize.sm;
    return Container(
      padding: sm
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.soft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c.dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label ?? status.label,
            maxLines: 1,
            softWrap: false,
            style: AppText.sans(
              size: sm ? 11.5 : 13,
              weight: FontWeight.w600,
              color: c.strong,
            ),
          ),
        ],
      ),
    );
  }
}
