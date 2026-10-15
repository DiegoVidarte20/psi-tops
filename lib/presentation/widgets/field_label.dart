import 'package:flutter/material.dart';
import '../../core/theme/app_text.dart';

/// `.field-label` (11px, semibold, mayúsculas, tracking 0.08em) + mb-1.5.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.bottom = 6});

  final String text;
  final double bottom;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: bottom),
    child: Text(text.toUpperCase(), style: AppText.overline()),
  );
}
