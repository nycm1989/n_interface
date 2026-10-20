
import 'package:flutter/material.dart';
import 'package:n_interface/n_interface.dart' show ContextExtension, NErrorHandler, NText;
import 'package:n_interface/src/painters/check_painter.dart' show CheckPainter;
import 'package:n_interface/src/painters/radio_painer.dart' show RadioPainter;

import 'async_loader.dart' show NAsyncLoader;

class NCheck extends StatefulWidget {
  final bool          value;
  final bool          isRadio;
  final bool          readOnly;
  final bool          blocked;
  final String      ? title;
  final String      ? text;
  final Alignment   ? alignment;
  final double      ? width;
  final double        size;
  final int?          maxLines;
  final TextOverflow? overflow;
  final GestureTapCallback? onCheck;
  final EdgeInsetsGeometry? margin;

  const NCheck({
    super.key,
    required this.value,
    this.isRadio  = false,
    this.readOnly = false,
    this.blocked = false,
    this.alignment,
    this.width,
    this.size = 12,
    this.maxLines,
    this.overflow,
    this.title,
    this.text,
    this.onCheck,
    this.margin,
  });

  @override
  State<NCheck> createState() => _NCheckAnimatedShapeState();
}

class _NCheckAnimatedShapeState extends State<NCheck> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _progress;
  Animation<Color?>? _colorAnimation;

  final Color disabledColor = const Color(0xFF9C9C9C);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller = AnimationController(
        vsync   : this,
        duration: const Duration(milliseconds: 400),
      );

      _progress = CurvedAnimation(
        parent: _controller!,
        curve : Curves.easeInOut
      );

      _colorAnimation = ColorTween(
        begin : context.borderColor,
        end   : context.mainColor
      ).animate(_progress!);

      if (widget.value) _controller?.value = 1.0;

      setState(() {});
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant NCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) widget.value ? _controller?.forward() : _controller?.reverse();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment : widget.alignment,
      width     : widget.width,
      margin    : widget.margin ?? .zero,
      child     :
      NErrorHandler(
        builder:(context) =>
        MouseRegion(
          cursor  :
          widget.blocked  ? SystemMouseCursors.forbidden :
          widget.readOnly ? MouseCursor.defer :
          SystemMouseCursors.click,
          child:
          Row(
            crossAxisAlignment  : .start,
            spacing             : 10,
            mainAxisSize        : .min,
            children            : [
              if(_controller != null && _progress != null && _colorAnimation != null)
              AnimatedBuilder(
                animation : _controller!,
                builder   : (context, _) =>
                SizedBox.square(
                  dimension : 20,
                  child     :
                  NAsyncLoader(
                    onTap     : widget.readOnly || widget.blocked? null : widget.onCheck,
                    indicator :
                    Padding(
                      padding : const .all(2),
                      child   :
                      CircularProgressIndicator(
                        color: context.mainColor,
                        strokeWidth: 2,
                      ),
                    ),
                    child:
                    CustomPaint(
                      size    : const .square(20),
                      painter :
                      widget.isRadio
                      ? RadioPainter(
                        progress        : _progress!.value,
                        color           : widget.blocked ? disabledColor : _colorAnimation!.value ?? context.borderColor,
                        borderColor     : widget.readOnly || widget.blocked ? disabledColor : widget.value ? context.borderColor : disabledColor,
                        backgroundColor : widget.onCheck == null ? const Color(0xFFdbdbdb) : context.primaryColor
                      )
                      : CheckPainter(
                        progress        : _progress!.value,
                        color           : widget.blocked ? disabledColor : _colorAnimation!.value ?? context.borderColor,
                        borderColor     : widget.readOnly || widget.blocked ? disabledColor : widget.value ? context.borderColor : disabledColor,
                        backgroundColor : widget.onCheck == null ? const Color(0xFFdbdbdb): context.primaryColor
                      )
                    ),
                  ),
                )
              ),
              if(widget.title != null || widget.text != null)
              Flexible(
                child:
                Column(
                  crossAxisAlignment  : .start,
                  mainAxisSize        : .min,
                  children            : [
                    if(widget.title != null)
                    NText(
                      text    : widget.title!,
                      weight  : .w500,
                      overflow: widget.overflow ?? .clip,
                      maxLines: widget.maxLines,
                      size    : widget.size,
                    ),
                    if(widget.text != null)
                    Flexible(
                      child:
                      NText(
                        text    : widget.text!,
                        overflow: widget.overflow ?? .clip,
                        maxLines: widget.maxLines,
                        size    : widget.size,
                      )
                    )
                  ]
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
