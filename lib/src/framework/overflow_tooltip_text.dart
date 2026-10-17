import 'package:flutter/material.dart';
import 'package:n_interface/n_interface.dart' show ContextExtension;
import 'package:n_interface/src/framework/tooltip.dart' show NTooltip;

/// Muestra [label] en una sola línea con elipsis. El [NTooltip] con el texto
/// completo solo se aplica cuando la cadena no cabe en el ancho disponible
/// (evita tooltips redundantes en etiquetas cortas como “Asesor asignado”).
class NOverflowTooltipText extends StatelessWidget {
  const NOverflowTooltipText({
    super.key,
    required this.label,
    this.color,
    this.tooltipLabel,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w300,
  });

  final String     label;
  final Color    ? color;
  final String   ? tooltipLabel;
  final double     fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color     : color ?? context.textColor,
      fontSize  : fontSize,
      fontWeight: fontWeight,
    );
    final textWidget = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    return LayoutBuilder(
      builder: (ctx, constraints) {
        if (constraints.maxWidth <= 0 || !constraints.maxWidth.isFinite) {
          return textWidget;
        }
        final tp = TextPainter(
          text: TextSpan(text: label, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = tp.didExceedMaxLines;
        if (!overflows) {
          return textWidget;
        }
        return NTooltip(
          message: tooltipLabel ?? label,
          child: textWidget,
        );
      },
    );
  }
}
