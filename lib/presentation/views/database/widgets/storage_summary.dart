import 'package:flutter/material.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_toast.dart';
import '../../../widgets/responsive_grid.dart';

enum _Tone { plain, ok, alert }

/// Retención · Registro de datos · Reportes programados.
class StorageSummary extends StatelessWidget {
  const StorageSummary({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card(String title, List<Widget> children) => AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppText.sans(size: 13.5, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );

    return ResponsiveGrid(
      columns: context.isMd ? 3 : 1,
      gap: 16,
      children: [
        card('Retención y almacenamiento', [
          const _Row('Política de retención', '5 años'),
          const _Row('Dato más antiguo', '03/02/2026'),
          const _Row('Espacio usado', '38,4 GB de 500 GB'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 6,
                color: AppColors.lineSoft,
                alignment: Alignment.centerLeft,
                child: const FractionallySizedBox(
                  widthFactor: 0.077,
                  heightFactor: 1,
                  child: ColoredBox(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const _Row('Proyección a 5 años', '≈ 290 GB'),
          const _Row('Respaldo diario', 'OK · 02:00', _Tone.ok),
        ]),
        card('Registro de datos', const [
          _Row('Velocidades y estado', 'cada 10 s'),
          _Row('Horas, producción, horómetro', 'cada 1 min + cierre de turno'),
          _Row('Cambio de estado', 'por evento'),
          _Row('Registros / día', '≈ 190 000'),
          _Row('PLC sin comunicación', '1 · Rompedora 5B', _Tone.alert),
        ]),
        card('Reportes programados', [
          const _Row('Cierre de turno · Excel', '06:05 · 14:05 · 22:05'),
          const _Row('Resumen diario gerencia · PDF', '07:00 por correo'),
          const _Row('Consolidado mensual · Excel', 'día 1 · 08:00'),
          const SizedBox(height: 12),
          const Spacer(),
          AppButton(
            label: 'Nuevo reporte programado',
            size: AppButtonSize.sm,
            variant: AppButtonVariant.outline,
            expand: true,
            onPressed: () => AppToast.info(
              context,
              'Nuevo reporte programado',
              description: 'Configure frecuencia, formato y destinatarios.',
            ),
          ),
        ]),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, [this.tone = _Tone.plain]);

  final String label;
  final String value;
  final _Tone tone;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppText.sans(size: 12, color: AppColors.inkMuted),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppText.mono(
              size: 12,
              weight: FontWeight.w500,
              color: switch (tone) {
                _Tone.ok => AppColors.run,
                _Tone.alert => AppColors.stop,
                _Tone.plain => AppColors.ink,
              },
            ),
          ),
        ),
      ],
    ),
  );
}
