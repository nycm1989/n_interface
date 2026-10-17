import 'package:flutter/material.dart';
import 'package:n_interface/n_interface.dart' show ContextExtension;

class NTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final Color? color;
  final Color? textColor;
  final double fontSize;

  const NTooltip({
    this.message = "",
    this.fontSize = 12,
    required this.child,
    this.color,
    this.textColor,
    super.key
  });

  @override
  Widget build(BuildContext context) =>
  message.isEmpty
  ? child
  : Tooltip(
    message   : message,
    margin    : const .only(top: 5),
    textAlign : .center,
    textStyle :
    TextStyle(
      overflow    : .clip,
      fontFamily  : "Poppins",
      fontSize    : fontSize,
      color       : textColor ?? Colors.white
    ),
    decoration:
    BoxDecoration(
      color         : color ?? context.mainColor,
      borderRadius  : .circular(5),
      boxShadow     : [const BoxShadow(color: Colors.white30, blurRadius: 2)]
    ),
    child: child,
  );

}