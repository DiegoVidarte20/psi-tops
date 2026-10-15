import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/state/plc_controller.dart';
import '../../../../data/models/plc.dart';
import '../../../widgets/app_button.dart';

/// Conectar / Conectando / Desconectar / Reintentar según el estado del PLC.
class PlcConnectionButton extends StatelessWidget {
  const PlcConnectionButton({
    super.key,
    required this.plcId,
    this.size = AppButtonSize.sm,
  });

  final String plcId;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final plc = PlcScope.of(context);
    final status = plc.runtime[plcId]!.status;
    final iconSize = size == AppButtonSize.sm ? 14.0 : 16.0;
    Icon icon(IconData d) => Icon(d, size: iconSize);

    return switch (status) {
      PlcStatus.connecting => AppButton(
        label: 'Conectando',
        size: size,
        variant: AppButtonVariant.outline,
        icon: SizedBox(
          width: iconSize,
          height: iconSize,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      PlcStatus.connected => AppButton(
        label: 'Desconectar',
        size: size,
        variant: AppButtonVariant.outline,
        icon: icon(LucideIcons.unplug),
        onPressed: () => plc.disconnect(plcId),
      ),
      PlcStatus.error => AppButton(
        label: 'Reintentar',
        size: size,
        variant: AppButtonVariant.outlineDanger,
        icon: icon(LucideIcons.rotateCw),
        onPressed: () => plc.connect(plcId),
      ),
      PlcStatus.disconnected => AppButton(
        label: 'Conectar',
        size: size,
        icon: icon(LucideIcons.plug),
        onPressed: () => plc.connect(plcId),
      ),
    };
  }
}
