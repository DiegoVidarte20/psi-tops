import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/state/plc_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../data/models/plc.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/text_input_field.dart';
import 'plc_connection_button.dart';

Color plcDotColor(PlcStatus s) => switch (s) {
  PlcStatus.connected => AppColors.run,
  PlcStatus.connecting => AppColors.pause,
  PlcStatus.error => AppColors.stop,
  PlcStatus.disconnected => AppColors.offline.withValues(alpha: 0.6),
};

Color plcTextColor(PlcStatus s) => switch (s) {
  PlcStatus.connected => AppColors.runStrong,
  PlcStatus.connecting => AppColors.pauseStrong,
  PlcStatus.error => AppColors.stop,
  PlcStatus.disconnected => AppColors.inkMuted,
};

enum _Filter {
  all('Todos'),
  connected('Conectados'),
  disconnected('Sin conexión');

  const _Filter(this.label);
  final String label;
}

/// "PLC en red": buscador, filtro y lista con botón de conexión.
class PlcList extends StatefulWidget {
  const PlcList({super.key, required this.selectedId, required this.onSelect});

  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  State<PlcList> createState() => _PlcListState();
}

class _PlcListState extends State<PlcList> {
  String _query = '';
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final plc = PlcScope.of(context);
    final q = _query.trim().toLowerCase();
    final visible = plc.devices.where((d) {
      final s = plc.runtime[d.id]!.status;
      if (_filter == _Filter.connected && s != PlcStatus.connected) {
        return false;
      }
      if (_filter == _Filter.disconnected && s == PlcStatus.connected) {
        return false;
      }
      return q.isEmpty ||
          '${d.name} ${d.ip} ${d.model}'.toLowerCase().contains(q);
    }).toList();

    return AppCard(
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        'PLC en red',
                        style: AppText.sans(size: 15, weight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '192.168.10.0/24',
                      style: AppText.mono(size: 12, color: AppColors.inkMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextInputField(
                  hint: 'Buscar PLC o dirección IP…',
                  prefixIcon: LucideIcons.search,
                  height: 36,
                  fontSize: 13,
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      for (final f in _Filter.values) ...[
                        if (f != _Filter.all) const SizedBox(width: 4),
                        Expanded(
                          child: _Segment(
                            label: f.label,
                            active: _filter == f,
                            onTap: () => setState(() => _filter = f),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.line),
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) Container(height: 1, color: AppColors.lineSoft),
            _PlcRow(
              device: visible[i],
              active: visible[i].id == widget.selectedId,
              onTap: () => widget.onSelect(visible[i].id),
            ),
          ],
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Text(
                'Ningún PLC coincide con el filtro.',
                textAlign: TextAlign.center,
                style: AppText.sans(size: 13, color: AppColors.inkMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlcRow extends StatelessWidget {
  const _PlcRow({
    required this.device,
    required this.active,
    required this.onTap,
  });

  final PlcDevice device;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = PlcScope.of(context).runtime[device.id]!;
    final status = r.status == PlcStatus.connected && r.latency != null
        ? '${r.status.label} · ${r.latency} ms'
        : r.status.label;
    return Container(
      decoration: BoxDecoration(
        color: active ? AppColors.primarySoft.withValues(alpha: 0.7) : null,
        border: Border(
          left: BorderSide(
            color: active ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(13, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Semantics(
                button: true,
                selected: active,
                label: 'Ver ${device.name}',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: plcDotColor(r.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Flexible(
                                  child: Text(
                                    device.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.sans(
                                      size: 14,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    status,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.sans(
                                      size: 11.5,
                                      weight: FontWeight.w500,
                                      color: plcTextColor(r.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${device.ip} · ${device.model.replaceFirst('Siemens ', '')}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.mono(
                                size: 11.5,
                                color: AppColors.inkMuted,
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
          const SizedBox(width: 12),
          PlcConnectionButton(plcId: device.id),
        ],
      ),
    );
  }
}

class _Segment extends StatefulWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_Segment> createState() => _SegmentState();
}

class _SegmentState extends State<_Segment> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        button: true,
        selected: a,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 28,
            decoration: BoxDecoration(
              color: a ? AppColors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              boxShadow: a
                  ? const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.label,
                  softWrap: false,
                  style: AppText.sans(
                    size: 12,
                    weight: FontWeight.w600,
                    color: a || _hover ? AppColors.ink : AppColors.inkMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
