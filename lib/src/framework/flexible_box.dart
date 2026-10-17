import 'package:flutter/material.dart';

/// Cambia entre un [Expanded] y un [Flexible] dependiendo a [expandWhen]
/// - Cuando es true se expande al widget padre como un [Expanded]
/// - Cuando es false se contrae al widget hijo como un [Flexible]
class NFlexibleBox extends Flexible {
  /// FlexFit.tight -> Expanded
  /// FlexFit.loose -> flexible
  NFlexibleBox({
    super.key,
    required Widget child,
    required bool   expandWhen,
    int flex = 1,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Color? color,
  }) : super (
    flex  : expandWhen ? flex : 0,
    fit   : expandWhen ? .tight : .loose,
    child :
    Container(
      color   : color,
      margin  : margin,
      padding : padding,
      width   : expandWhen ? null : width,
      height  : expandWhen ? null : height,
      child   : child,
    )
  );
}