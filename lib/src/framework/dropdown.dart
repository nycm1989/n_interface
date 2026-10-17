import 'package:flutter/material.dart';
import 'package:n_interface/src/extenssions/context_extension.dart' show ContextExtension;

import 'text.dart' show NText;
import 'async_loader.dart' show NAsyncLoader;
import 'axis_layout.dart' show NAxisLayout;
import 'text_field.dart' show NTextController;

class NDropdown<T> extends NAxisLayout {
  NDropdown({
    NTextController? controller,
    ValueChanged<String>? onChanged,
    Future<void> Function()? onLoading,
    Function()? onFinished,
    super.axis  = .vertical,
    super.isRequired = false,
    super.action,
    super.title,
    super.weight,
    super.overflow,
    super.width,
    super.height,
    super.margin,
    super.key,
    bool arrow  = true,
    String? text,
    String? hint,
    String? errorText,
    TextAlign? align,
    Color? color,
    String? asset,
    double? assetSize,
    EdgeInsetsGeometry? assetPadding,
    double size = 12,
    bool enable = true,
    bool readOnly    = false,
    bool error  = false,
    EdgeInsetsGeometry? padding,
    List<T>? items,
    EdgeInsetsGeometry? itemPadding,
    double? menuWidth,
    double? menuMaxHeight = 300,
    Widget? menuButton,
    double? headerHeight,
    BoxDecoration? headerDecoration,
    Function(T item, int index)? onSelection,
    Widget Function(T item, int index)? itemBuilder,
    Widget? child,
  }) : super(
    child :
    _NDropdown<T>(
      controller  : controller,
      onLoading   : onLoading,
      onFinished  : onFinished,
      onChanged   : onChanged,
      text   : text,
      arrow  : arrow,
      hint   : hint,
      errorText   : errorText,
      size   : size,
      asset  : asset,
      assetSize   : assetSize,
      assetPadding     : assetPadding,
      align  : align,
      weight : weight,
      color  : color,
      enable : enable,
      readOnly    : readOnly,
      error  : error,
      padding     : padding,
      margin : margin,
      items  : items,
      itemPadding : itemPadding,
      menuWidth   : menuWidth,
      menuMaxHeight    : menuMaxHeight,
      menuButton  : menuButton,
      headerHeight     : headerHeight,
      headerDecoration : headerDecoration,
      onSelection : onSelection,
      itemBuilder : itemBuilder,
      child  : child,
    ),
  );
}

class NDropdownScope extends InheritedWidget {
  final VoidCallback close;

  const NDropdownScope({
    required this.close,
    required super.child,
    super.key,
  });

  static NDropdownScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NDropdownScope>();
  }

  @override
  bool updateShouldNotify(NDropdownScope oldWidget) => false;
}

class _NDropdown<T> extends StatefulWidget {
  final NTextController? controller;
  final Future<void> Function()?     onLoading;
  final Function()? onFinished;
  final ValueChanged<String>? onChanged;
  final bool   arrow;
  final bool   enable;
  final bool   readOnly;
  final bool   error;
  final String?     asset;
  final double?     assetSize;
  final EdgeInsetsGeometry?   assetPadding;
  final Color? color;
  final double size;
  final FontWeight? weight;
  final String?     text;
  final TextAlign?  align;
  final String?     hint;
  final String?     errorText;
  final EdgeInsetsGeometry?   padding;
  final EdgeInsetsGeometry?   margin;
  final double?     menuWidth;
  final double?     menuMaxHeight;
  final Widget?     menuButton;
  final double?     headerHeight;
  final BoxDecoration?   headerDecoration;
  final Widget?     child;
  final List<T>?    items;
  final EdgeInsetsGeometry?   itemPadding;
  final Function(T item, int index)? onSelection;
  final Widget Function(T item, int index)? itemBuilder;

  const _NDropdown({
    super.key,
    required this.controller,
    required this.onLoading,
    required this.onFinished,
    required this.onChanged,
    required this.text,
    required this.arrow,
    required this.align,
    required this.weight,
    required this.color,
    required this.asset,
    required this.assetSize,
    required this.assetPadding,
    required this.enable,
    required this.readOnly,
    required this.error,
    required this.size,
    required this.hint,
    required this.errorText,
    required this.padding,
    required this.margin,
    required this.child,
    required this.items,
    required this.itemPadding,
    required this.menuButton,
    required this.menuWidth,
    required this.menuMaxHeight,
    required this.headerHeight,
    required this.headerDecoration,
    required this.onSelection,
    required this.itemBuilder,
  });

  @override
  State<_NDropdown<T>> createState() => __NDropdownState<T>();
}

class __NDropdownState<T> extends State<_NDropdown<T>> {
  final ScrollController scrollController = ScrollController();
  final OverlayPortalController _portal   = OverlayPortalController();
  // final LayerLink _link = LayerLink();
  final GlobalKey anchorKey = GlobalKey();
  // Declared here (not inside overlayChildBuilder) so it never changes between
  // builds — a new GlobalKey each rebuild would destroy and recreate the entire
  // overlay subtree (including any stateful child like SingleDatePicker).
  final GlobalKey _menuKey = GlobalKey();
  ValueNotifier<double>   overflow = ValueNotifier<double>(0);
  ValueNotifier<double?>  height   = ValueNotifier<double?>(null);
  ValueNotifier<double>   menuStartPoint = ValueNotifier<double>(0);

  NTextController? inputController;
  bool isExpanded = false;
  bool isOver     = false;

  @override
  void initState() {
    if (widget.onChanged != null || widget.controller == null) inputController = NTextController();
    super.initState();
  }

  void _toggle() async {
    if (!isExpanded && widget.onLoading != null) {
      await widget.onLoading!();
      if (!mounted) return;
    }
    setState(() {
      isExpanded = !isExpanded;
      isExpanded ? _portal.show() : _portal.hide();
    });
  }

  @override
  void dispose() {
    inputController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _NDropdown<T> oldWidget) {
    if(oldWidget.items != widget.items) setState(() {});
    if(oldWidget.child.hashCode != widget.child.hashCode) setState(() {});
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) =>
  OverlayPortal(
    controller : _portal,
    overlayChildBuilder : (context) {

      final RenderBox? box  = anchorKey.currentContext?.findRenderObject() as RenderBox?;
      final Offset offset   = box?.localToGlobal(Offset.zero) ?? Offset.zero;
      final Size targetSize = box?.size ?? Size.zero;

      final double menuWidth = widget.menuWidth ?? targetSize.width;
      menuStartPoint.value   = offset.dx - (menuWidth / 2) + (targetSize.width / 2);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final double buttomHeight = box?.size.height ?? 0;
        final double menuHeight   = _menuKey.currentContext?.size?.height ?? 0;
        final double widgetHeight = buttomHeight + menuHeight + 20;
        final double menuWidthOverflow = menuStartPoint.value + menuWidth - MediaQuery.of(context).size.width + 20;

        menuHeight + 20 > MediaQuery.of(context).size.height
          ? (height.value = MediaQuery.of(context).size.height - 20, overflow.value = 0)
          : (height.value = null, overflow.value = MediaQuery.of(context).size.height - (widgetHeight + offset.dy));

        if(menuWidthOverflow > 0) menuStartPoint.value = menuStartPoint.value - menuWidthOverflow;
      });

      return Stack(
        children : [
          Positioned.fill(
            child :
            GestureDetector(
              behavior : .translucent,
              onTap    : _toggle,
              child    : const SizedBox.expand(),
            ),
          ),
          ValueListenableBuilder<double?>(
            valueListenable : menuStartPoint,
            builder : (_, startPoint, _) =>
            ValueListenableBuilder<double?>(
              valueListenable : height,
              builder : (_, height, _) =>
              ValueListenableBuilder<double>(
                valueListenable : overflow,
                builder : (_, overflow, _) =>
                Positioned(
                  left   : startPoint,
                  top    : height != null ? 10 : offset.dy + targetSize.height + (overflow.isNegative ? overflow - 20 : 0),
                  width  : menuWidth,
                  height : height,
                  child  :
                  Material(
                    borderRadius : .circular(8),
                    elevation    : 4,
                    color : context.backgroundColor,
                    child :
                    Container(
                      key   : _menuKey,
                      clipBehavior : .hardEdge,
                      decoration   : BoxDecoration(borderRadius: .circular(10)),
                      child : NDropdownScope(
                        close : _toggle,
                        child : widget.child ??
                        Container(
                          height : height,
                          constraints : widget.menuMaxHeight != null && height == null ? BoxConstraints(maxHeight: widget.menuMaxHeight!) : null,
                          child  :
                          Scrollbar(
                            thumbVisibility : true,
                            controller : scrollController,
                            child :
                            ListView(
                              controller : scrollController,
                              physics    : const ClampingScrollPhysics(),
                              padding    : .zero,
                              shrinkWrap : true,
                              children   : widget.items!.asMap().entries.map((e) =>
                                _ItemContainer(
                                  index : e.key,
                                  item  : e.value,
                                  itemPadding : widget.itemPadding,
                                  onSelection : widget.onSelection,
                                  itemBuilder : widget.itemBuilder!,
                                  onClose     : _toggle,
                                ),
                              ).toList()
                            ),
                          ),
                        ),
                      )
                    )
                  )
                )
              )
            )
          )
        ]
      );
    },
    child :
    Column(
      crossAxisAlignment : CrossAxisAlignment.start,
      children : [
        Container(
          key   : anchorKey,
          margin     : widget.margin,
          padding    : .only(
            top    : 5,
            bottom : 5,
            left   : 10,
            right  : widget.readOnly ? 10 : widget.arrow ? 5 : 10,
          ),
          decoration : widget.headerDecoration ?? BoxDecoration(
            color  : widget.enable || widget.controller != null ? context.primaryColor : context.disabledColor,
            borderRadius : .circular(10),
            border :
            Border.all(
              width : 0.7,
              color : widget.error
                ? Colors.red
                : isOver ? context.dividerColor : context.cardColor
            ),
            boxShadow    : widget.enable ? isOver ? const [BoxShadow(color: Colors.black12, blurRadius: 1)] : null : null
          ),
          child :
          MouseRegion(
            cursor  : SystemMouseCursors.click,
            onEnter : (event) => setState(() => isOver = true  ),
            onExit  : (event) => setState(() => isOver = false ),
            child   :
            GestureDetector(
              onTap : widget.enable && !widget.readOnly ? _toggle : null,
              child :
              Row(
                children : [
                  Expanded(
                    child : widget.onChanged != null
                    ? TextFormField(
                        controller  : widget.controller ?? inputController,
                        selectAllOnFocus  : true,
                        onChanged   : widget.onChanged,
                        onTap : () {
                          if(!isExpanded) _portal.show();
                        },
                        textInputAction   : .send,
                        textAlignVertical : .center,
                        cursorWidth : 0.5,
                        decoration  :
                        const InputDecoration(
                          errorStyle     : TextStyle(height: 0),
                          counterText    : "",
                          errorMaxLines  : 0,
                          isDense   : true,
                          isCollapsed    : true,
                          contentPadding : .symmetric( vertical: 12, horizontal: 16 ),
                          fillColor : Colors.white,
                          border    : OutlineInputBorder(borderSide: .new(color: Colors.transparent)),
                          errorBorder    : OutlineInputBorder(borderSide: .new(color: Colors.transparent)),
                          enabledBorder  : OutlineInputBorder(borderSide: .new(color: Colors.transparent)),
                          focusedBorder  : OutlineInputBorder(borderSide: .new(color: Colors.transparent)),
                          disabledBorder : OutlineInputBorder(borderSide: .new(color: Colors.transparent)),
                          focusedErrorBorder    : OutlineInputBorder(borderSide: .new(color: Colors.transparent)),
                          suffixIconConstraints : BoxConstraints( maxHeight : 30, minHeight : 30 ),
                          prefixIconConstraints : BoxConstraints( maxHeight : 30, minHeight : 30 ),
                        ),
                      )
                    : widget.menuButton ??
                      NText(
                        text    : widget.text ?? widget.hint ?? '',
                        size    : widget.size,
                      ),
                  ),
                  NAsyncLoader(
                    onLoading  : widget.onLoading,
                    onFinished : widget.onFinished,
                    indicator  :
                    Padding(
                      padding : .all(4.5),
                      child   :
                      SizedBox.square(
                        dimension : widget.assetSize ?? 15,
                        child     : const CircularProgressIndicator(strokeWidth: 1)
                      )
                    ),
                    child :
                    widget.readOnly
                    ? const SizedBox(height: 24)
                    : widget.arrow
                      ? AnimatedRotation(
                        turns    : isExpanded ? 0.5 : 0,
                        duration : const Duration(milliseconds: 200),
                        child    :
                        Container(
                          alignment : .center,
                          width     : 24,
                          height    : 24,
                          child     :
                          widget.asset != null
                          ? Image.asset(widget.asset!,
                            width  : 13,
                            height : 13,
                          )
                          : const Icon(Icons.arrow_drop_down, size: 20),
                        )
                      )
                      : const SizedBox(height: 24)
                  )
                ]
              )
            )
          ),
        ),
        if(widget.error)
        if((widget.errorText ?? "").isNotEmpty)
        Padding(
          padding : const EdgeInsets.only(left: 10, top: 4),
          child   :
          Text(
            widget.errorText!,
            style : const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      ],
    )
  );
}

class _ItemContainer<T> extends StatefulWidget {
  final int index;
  final T item;
  final EdgeInsetsGeometry? itemPadding;
  final VoidCallback onClose;
  final Function(T item, int index)? onSelection;
  final Widget Function(T item, int index) itemBuilder;

  const _ItemContainer({
    required this.index,
    required this.item,
    required this.itemPadding,
    required this.onClose,
    required this.onSelection,
    required this.itemBuilder,
  });

  @override
  State<_ItemContainer<T>> createState() => _ItemContainerState<T>();
}

class _ItemContainerState<T> extends State<_ItemContainer<T>> {
  bool isOver = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior : .opaque,
      cursor  : SystemMouseCursors.click,
      onEnter : (event) => setState(() => isOver = true  ),
      onExit  : (event) => setState(() => isOver = false ),
      child   :
      GestureDetector(
        behavior : .opaque,
        onTap    : () {
          widget.onSelection?.call(widget.item, widget.index);
          widget.onClose();
        },
        child    :
        Container(
          color   : isOver ? context.cardColor.withValues(alpha: 0.5) : context.primaryColor,
          padding : widget.itemPadding ?? const EdgeInsets.all(10),
          child   : widget.itemBuilder(widget.item, widget.index),
        ),
      ),
    );
  }
}
