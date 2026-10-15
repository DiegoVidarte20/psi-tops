import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../data/mock/database_data.dart';
import '../../../../data/mock/variables_data.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_data_table.dart';
import '../../../widgets/select_field.dart';

enum ConfigTab { variables, turnos, usuarios }

/// Pestañas "Variables por máquina", "Turnos" y "Usuarios".
class ConfigTables extends StatefulWidget {
  const ConfigTables({super.key, required this.tab});

  final ConfigTab tab;

  @override
  State<ConfigTables> createState() => _ConfigTablesState();
}

class _ConfigTablesState extends State<ConfigTables> {
  String _type = 'integrado';

  @override
  Widget build(BuildContext context) {
    final title = AppText.sans(size: 14, weight: FontWeight.w700);
    final cell = AppText.sans(size: 13);
    final bold = cell.copyWith(fontWeight: FontWeight.w600);
    final muted = cell.copyWith(color: AppColors.inkMuted);
    final mono = AppText.mono(size: 13);
    final monoSm = AppText.mono(size: 12);

    Widget t(String s, TextStyle st) => Text(s, softWrap: false, style: st);

    Widget section(Widget header, AppDataTable table) => AppCard(
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: const EdgeInsets.all(16), child: header),
          table,
        ],
      ),
    );

    switch (widget.tab) {
      case ConfigTab.variables:
        final vars = _type == 'integrado'
            ? integradoVariables
            : rompedoraVariables;
        return section(
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Text('Variables por tipo de máquina', style: title),
              SizedBox(
                width: 160,
                child: SelectField<String>(
                  compact: true,
                  value: _type,
                  options: const {
                    'integrado': 'Integrado',
                    'rompedora': 'Rompedora',
                  },
                  onChanged: (v) => setState(() => _type = v),
                ),
              ),
            ],
          ),
          AppDataTable(
            minWidth: 640,
            columns: const [
              AppTableColumn('Variable'),
              AppTableColumn('Tag PLC', flex: true),
              AppTableColumn('Tipo'),
              AppTableColumn('Registro'),
            ],
            rows: [
              for (final v in vars)
                AppTableRow([
                  t(v.name, bold),
                  t(v.tag, monoSm.copyWith(color: AppColors.inkMuted)),
                  t(v.type, monoSm),
                  t(v.sampling, muted),
                ]),
            ],
          ),
        );
      case ConfigTab.turnos:
        return section(
          Text('Turnos de producción', style: title),
          AppDataTable(
            minWidth: 560,
            columns: const [
              AppTableColumn('Turno'),
              AppTableColumn('Inicio'),
              AppTableColumn('Fin'),
              AppTableColumn('Reporte', flex: true),
              AppTableColumn('Estado'),
            ],
            rows: [
              for (final s in shiftConfig)
                AppTableRow([
                  t(s.name, bold),
                  t(s.start, mono),
                  t(s.end, mono),
                  t(s.report, muted),
                  const TablePill('Activo'),
                ]),
            ],
          ),
        );
      case ConfigTab.usuarios:
        return section(
          Text('Usuarios con acceso', style: title),
          AppDataTable(
            minWidth: 620,
            columns: const [
              AppTableColumn('Nombre'),
              AppTableColumn('Correo', flex: true),
              AppTableColumn('Rol'),
              AppTableColumn('Último acceso'),
            ],
            rows: [
              for (final u in users)
                AppTableRow([
                  t(u.name, bold),
                  t(u.email, muted),
                  t(u.role, cell),
                  t(u.lastAccess, monoSm.copyWith(color: AppColors.inkMuted)),
                ]),
            ],
          ),
        );
    }
  }
}
