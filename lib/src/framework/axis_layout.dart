import 'package:flutter/material.dart';
import 'package:n_interface/src/extenssions/context_extension.dart' show ContextExtension;

import 'flexible_box.dart' show NFlexibleBox;
import 'text.dart' show NText;

/// Este widget cambia entre [Column] y [Row] dependiendo al [axis]
/// Si [axis] es horizontal es un [Row]
/// Si [axis] es vertical es un [Column]
class NAxisLayout extends StatelessWidget {
  final Axis axis;
  final Widget child;
  final Widget? action;
  final String? title;
  final TextOverflow? overflow;
  final double? width;
  final double? height;
  final FontWeight? weight;
  final bool isRequired;
  final Alignment? alignment;
  final EdgeInsetsGeometry? margin;

  const NAxisLayout({
    required this.axis,
    required this.child,
    this.action,
    this.title,
    this.width,
    this.height,
    this.overflow,
    this.isRequired = false,
    this.alignment,
    this.margin,
    this.weight,
    super.key
  });

  @override
  Widget build(BuildContext context) =>
  Container(
    margin  : margin ?? .zero,
    height  : height,
    child   :
    Column(
      mainAxisSize      : .min,
      crossAxisAlignment: .end,
      spacing           : 5,
      children          : [
        if(axis == .horizontal) ?action,
        Flex(
          direction           : axis,
          mainAxisSize        : .min,
          crossAxisAlignment  : axis == .horizontal ? .center : .start,
          spacing             : axis == .horizontal ? 10 : 0,
          children            : [
            if(title != null)
            NFlexibleBox(
              expandWhen: axis == .horizontal,
              child     :
              SizedBox(
                width: axis == .vertical ? width : null,
                child:
                Row(
                  spacing : 5,
                  children: [
                    if(isRequired)
                    NText(
                      context : context,
                      text    : "*",
                      weight  : weight ?? .w400,
                      color   : context.mainColor
                    ),
                    Expanded(
                      child:
                      Padding(
                        padding : const .only(bottom: 5),
                        child   :
                        NText(
                          context : context,
                          text    : title!,
                          weight  : weight ?? .w400,
                          overflow: overflow ?? .clip,
                          // Con ellipsis el título se limita a 1 línea (no envuelve ni
                          // crece en altura); sin ella, comportamiento original.
                          maxLines: overflow == TextOverflow.ellipsis ? 1 : null,
                        ),
                      ),
                    ),
                    if(axis == .vertical) ?action,
                  ],
                ),
              ),
            ),
            NFlexibleBox(
              expandWhen: axis == .horizontal,
              child     :
              Align(
                alignment : width != null ? .centerLeft : .center,
                child     :
                Container(
                  width     : width,
                  alignment : alignment,
                  child     : child
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}