import 'package:flutter/material.dart';
import 'package:n_interface/n_interface.dart' show ContextExtension, NText;
import 'package:n_interface/src/painters/arrow_painter.dart' show ArrowPainter;
import 'async_loader.dart' show NAsyncLoader;

class NAccordionController extends ChangeNotifier {
  bool isExpanded = false;
  bool isAnimated = true;

  void changeExpandedStatus(bool isExpanded) {
    this.isExpanded = isExpanded;
    notifyListeners();
  }

  void changeAnimatedStatus(bool isAnimated) {
    this.isAnimated = isAnimated;
    notifyListeners();
  }
}

class NAccordion extends StatefulWidget {
  final NAccordionController?  controller;
  final String                title;
  final String?               titleAsset;
  final Color?                titleColor;
  final FontWeight?           titleWeight;
  final bool                  readOnly;
  final bool                  isRequired;
  final bool                  haveDecoration;
  /// Si `true`, el acordeón se renderiza ya abierto desde el primer frame
  /// (sin necesidad de que el usuario haga click). Útil para forzar la
  /// expansión de la primera sección de una lista, por ejemplo.
  final bool                  initiallyOpen;
  final List<Widget>          children;
  final List<Widget>          headers;
  final List<Widget>          tags;
  final double                spacing;
  final double              ? width;
  final EdgeInsetsGeometry  ? margin;
  final EdgeInsetsGeometry  ? padding;
  final Future<void> Function()? onExpand;

  const NAccordion({
    super.key,
    required this.title,
    this.controller,
    this.titleAsset,
    this.onExpand,
    this.children       = const [],
    this.titleColor,
    this.titleWeight,
    this.width,
    this.readOnly       = false,
    this.isRequired     = false,
    this.haveDecoration = false,
    this.initiallyOpen  = false,
    this.spacing        = 0,
    this.margin,
    this.padding,
    this.headers = const [],
    this.tags = const [],
  });

  @override
  State<NAccordion> createState() => _AccordionState();
}

class _AccordionState extends State<NAccordion> {
  late bool _isOpen = widget.initiallyOpen;
  late bool _show   = widget.initiallyOpen;

  Future<void> _toggle() async {
    setState(() => _isOpen = !_isOpen);
    widget.controller?.changeExpandedStatus(_isOpen);
    if(widget.onExpand == null){
      setState(() => _show = true);
    } else {
      await Future.delayed(const Duration(milliseconds: 300), () => setState(() => _show = true));
    }
  }

  BoxDecoration _decoration(BuildContext context) => BoxDecoration(
    border      : .all( color: context.dividerColor ),
    borderRadius: .circular(5)
  );

  @override
  Widget build(BuildContext context) =>
  Container(
    margin: widget.margin,
    width : widget.width,
    child :
    Column(
      spacing             : widget.spacing,
      mainAxisSize        : .min,
      crossAxisAlignment  : .start,
      children            : [
        GestureDetector(
          onTap: () async =>  await _toggle(),
          child:
          MouseRegion(
            cursor  : SystemMouseCursors.click,
            child   :
            Container(
              padding   : widget.padding,
              decoration: widget.haveDecoration ? _decoration(context) : const BoxDecoration(),
              child     :
              Row(
                spacing   : 8,
                children  : [
                  Expanded(
                    child:
                    Row(
                      spacing : 2,
                      children: [
                        if(widget.isRequired)
                        NText(
                          text      : "*",
                          weight    : .w500,
                          overflow  : .clip,
                          color     : context.mainColor,
                          margin    : const .symmetric(vertical: 5),
                        ),

                        if(widget.titleAsset != null)
                        Padding(
                          padding : const .only(right: 3),
                          child   :
                          Image.asset(
                            widget.titleAsset!,
                            width : 18,
                            height: 18,
                          )
                        ),

                        Flexible(
                          child:
                          NText(
                            text      : widget.title,
                            weight    : widget.titleWeight ?? .w500,
                            overflow  : .clip,
                            color     : widget.titleColor??context.textBoldColor,
                            margin    : const .symmetric(vertical: 5),
                          ),
                        ),
                        if(widget.tags.isNotEmpty)
                        Row(
                          mainAxisSize  : .min,
                          children      : widget.tags,
                        ),
                      ],
                    ),
                  ),
                  if(widget.headers.isNotEmpty)
                  Row(
                    mainAxisSize      : .min,
                    mainAxisAlignment : .end,
                    children          : widget.headers,
                  ),
                  AnimatedRotation(
                    turns     : widget.readOnly ? 0 : (widget.controller?.isExpanded ??_isOpen) ? 0.5 : 0,
                    duration  : const Duration(milliseconds: 300),
                    child     :
                    SizedBox.square(
                      dimension : 20,
                      child     :
                      CustomPaint(
                        painter:
                        ArrowPainter(
                          color: widget.readOnly ? const Color(0xFF9c9c9c) : context.textBoldColor
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if(widget.readOnly == false)
        AnimatedCrossFade(
          firstChild      : Container(),
          crossFadeState  : (widget.controller?.isExpanded ?? _isOpen) ? .showSecond : .showFirst,
          duration        : Duration(milliseconds: (widget.controller?.isAnimated ?? true) ? 300 : 1),
          alignment       : .topLeft,
          secondChild     :
          Container(
            width       : widget.width?? .infinity,
            padding     : widget.padding,
            decoration  : widget.haveDecoration ? _decoration(context) : const BoxDecoration(),
            child       :
            widget.onExpand == null
            ? Column(
              crossAxisAlignment: .start,
              children          : widget.children,
            )
            : (widget.controller?.isExpanded ?? _show)
              ? NAsyncLoader(
                onLoading : widget.onExpand != null
                  ? () async => widget.onExpand!.call()
                  : null,
                child     :
                Column(
                  crossAxisAlignment: .start,
                  children          : widget.children,
                )
              )
              : const SizedBox(height: 20)
          ),
        )
      ],
    ),
  );
}