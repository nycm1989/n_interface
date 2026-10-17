import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:n_interface/src/extenssions/context_extension.dart' show ContextExtension;
import 'text.dart';


class NSwitcher extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final bool    value;
  final bool    divider;
  final bool    animate;
  final String? detail;
  final List<IconData> icons;
  final List<String>   texts;
  final double  height;
  final Function(bool)?     onChanged;
  // Cuando se define, el indicador (thumb) usa este color en ambos estados
  // — para selectores segmentados como el idioma. Null conserva el estilo por
  // defecto (verde solo en `true`, blanco en `false`).
  final Color? indicatorColor;

  const NSwitcher({
    this.margin,
    this.icons   = const [],
    this.texts   = const [],
    required this.value,
    this.divider = false,
    this.animate = true,
    this.height  = 30,
    this.detail,
    this.onChanged,
    this.indicatorColor,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding    : margin ?? .zero,
      decoration : divider
      ? BoxDecoration(
        border : Border(
          bottom : BorderSide(color: Theme.of(context).dividerColor)
        )
      )
      : null,
      child :
      Row(
        mainAxisAlignment : .spaceBetween,
        mainAxisSize : detail == null ? .min : .max,
        children     : [
          if(detail != null)
          Expanded(
            child :
            Text(detail!)
          ),
          Padding(
            padding : const EdgeInsets.only(left: 5),
            child   :
            AnimatedToggleSwitch<bool>.dual(
              first  : false,
              second : true,
              textBuilder : texts.isEmpty
              ? null
              : (value) => NText(
                context : context,
                text    : value ? texts.first : texts.last,
                size    : 10,
                color   : Colors.grey,
                // weight  : .bold
              ),
              loadingIconBuilder : (context, global) =>
              SizedBox.square(
                dimension : height - 7,
                child     :
                CircularProgressIndicator(
                  // padding     : const EdgeInsets.all(2),
                  strokeWidth : 1,
                  color : global.current ? context.primaryColor : context.mainColor,
                ),
              ),
              animationDuration : animate ? const Duration(milliseconds: 500) : .zero,
              styleBuilder : (value) =>
              ToggleStyle(
                borderColor : context.primaryColor,
                backgroundColor    : onChanged == null ? context.overedColor : value ? context.cardColor : const Color(0xFFc5c5c5),
                indicatorColor     : onChanged == null ? const Color(0xFFc5c5c5) : indicatorColor ?? (value ? context.mainColor : context.primaryColor),
                indicatorBoxShadow : [const BoxShadow(
                  color : Colors.black54,
                  blurRadius : 3
                )]
              ),
              iconBuilder  : (_) {
                if (icons.length == 2 && texts.isEmpty) {
                  return Icon( !value ? icons.first : icons.last );
                }
                if (texts.length == 2 && icons.isEmpty) {
                  return NText(
                    context : context,
                    text    : !value ? texts.first : texts.last,
                    size    : 10,
                    weight  : .w500,
                    // Con indicador de color fijo el thumb es blanco en ambos estados.
                    color : indicatorColor != null ? context.primaryColor : value ? context.primaryColor : context.textColor
                  );
                }
                return SizedBox.shrink();
              },
              spacing : 4,
              height  : height,
              borderWidth   : 1.2,
              indicatorSize : .fromWidth(height - 2),
              // values         : const [false, true],
              current   : value,
              onChanged : onChanged == null ? null : (bool e) => onChanged?.call(e),
            ),
          ),
        ],
      ),
    );
  }
}