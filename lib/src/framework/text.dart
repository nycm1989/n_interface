import 'package:flutter/material.dart';
import 'package:n_interface/n_interface.dart' show ContextExtension;

enum _Type{
  normal,
  bold,
  button
}

class NText extends StatelessWidget {
  final String                text;
  final double                size;
  final FontWeight            weight;
  final Color               ? color;
  final TextAlign           ? align;
  final TextOverflow        ? overflow;
  final EdgeInsetsGeometry  ? margin;
  final Shadow              ? shadow;
  final FontStyle           ? style;
  final TextDecoration      ? decoration;
  final double              ? decorationThickness;
  final int                 ? maxLines;

  final _Type _type;

  const NText({
    required this.text,
    this.size   = 12,
    this.weight = .w300,
    this.color,
    this.align,
    this.margin,
    this.overflow,
    this.shadow,
    this.style,
    this.decoration,
    this.decorationThickness,
    this.maxLines,
    super.key,
  }) : _type = .normal;

  const NText.bold({
    required this.text,
    this.size     = 12,
    this.color,
    this.margin,
    this.align,
    this.overflow,
    this.shadow,
    this.style,
    this.decoration,
    this.decorationThickness,
    this.maxLines,
    super.key
  }):
  _type   = .bold,
  weight  = .w500;

  const NText.button({
    required this.text,
    this.size     = 12,
    this.margin,
    this.align,
    this.overflow,
    this.shadow,
    this.style,
    this.color,
    this.decoration,
    this.decorationThickness,
    this.maxLines,
    super.key
  }):
  _type   = .button,
  weight  = .w500;

  @override
  Widget build(BuildContext context) =>
  Padding(
    padding : margin ?? .zero,
    child   :
    Text(
      text,
      textAlign : align,
      overflow  : overflow,
      maxLines  : maxLines,
      style     :
      TextStyle(
        color     : color ?? (
          _type == .normal  ? context.textColor     :
          _type == .bold    ? context.textBoldColor :
          _type == .button  ? context.mainColor     :
          null
        ),
        fontStyle : style,
        fontSize  : size,
        fontWeight: weight,
        decoration: decoration,
        decorationThickness: decorationThickness,
        shadows   : shadow == null ? null : [shadow!]
      ),
    )
  );
}
