import 'package:flutter/material.dart' show AnimatedContainer, BorderRadius, BoxShadow, BoxDecoration, BuildContext, Color, Colors, Container, EdgeInsets, EdgeInsetsGeometry, Expanded, FontWeight, GestureDetector, GestureTapCallback, Image, InkWell, ListView, Material, MaterialType, MouseCursor, MouseRegion, NeverScrollableScrollPhysics, Offset, Overlay, OverlayEntry, Positioned, RenderBox, Row, Size, SizedBox, Stack, State, StatefulWidget, SystemMouseCursors, TextOverflow, Widget;
import 'package:n_interface/src/extenssions/context_extension.dart' show ContextExtension;
import 'text.dart' show NText;
import 'tooltip.dart' show NTooltip;

/// Alignment of the submenu relative to its trigger button.
enum NSubMenuAlignment {
  /// Menu opens to the upper-left of the trigger.
  topLeft,
  /// Menu opens to the upper-right of the trigger.
  topRight,
  /// Menu opens to the lower-left of the trigger.
  bottomLeft,
  /// Menu opens to the lower-right of the trigger.
  bottomRight,
}

/// Widget de submenú contextual (dropdown).
class NSubMenu extends StatefulWidget {
  final String  asset;
  final String? oversset;
  final String? disableAsset;
  final bool    enabled;
  final double  dimension;
  final double  menuWidth;
  final EdgeInsetsGeometry margin;
  final NSubMenuAlignment  alignment;
  final List<NSubMenuItem> items;

  const NSubMenu({
    required this.asset,
    this.oversset,
    this.disableAsset,
    this.enabled   = true,
    this.dimension = 25,
    this.menuWidth = 200,
    this.margin    = const EdgeInsets.all(2),
    required this.alignment,
    required this.items,
    super.key
  });

  @override
  State<NSubMenu> createState() => _NSubMenuState();
}

class _NSubMenuState extends State<NSubMenu> {
  bool          isOver = false;
  late Offset menuOffset;
  OverlayEntry? _overlayEntry;

  /// Abre el menú desplegable.
  void _openNDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Cierra el menú desplegable.
  void _closeNDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Calcula las coordenadas de posición del menú en pantalla.
  void _checkSize() {
    late final Offset offset = (context.findRenderObject() as RenderBox?)?.localToGlobal(.zero) ?? .zero;
    late final Size size     = (context.findRenderObject() as RenderBox?)?.size ?? .zero;

    menuOffset =
    widget.alignment == .topLeft      ? Offset(offset.dx - widget.menuWidth,  offset.dy + size.height) :
    widget.alignment == .topRight     ? Offset(offset.dx + size.width,        offset.dy + size.height) :
    widget.alignment == .bottomLeft   ? Offset(offset.dx - widget.menuWidth,  offset.dy - size.height) :
    widget.alignment == .bottomRight  ? Offset(offset.dx + size.width,        offset.dy - size.height) :
    const Offset(0, 0);
  }

  /// Crea y configura la estructura visual del OverlayEntry.
  OverlayEntry _createOverlayEntry() {
    _checkSize();
    return OverlayEntry(
      builder : (context) =>
      Stack(
        children : [
          Positioned.fill(
            child :
            GestureDetector(
              behavior : .translucent,
              onTap    : _closeNDropdown,
              child    : const SizedBox.expand(),
            ),
          ),
          Positioned(
            top   : menuOffset.dy,
            left  : menuOffset.dx,
            child :
            Material(
              type  : MaterialType.transparency,
              child :
              Container(
                decoration : BoxDecoration(
                  color : Colors.white,
                  borderRadius : BorderRadius.circular(10),
                  boxShadow    : [
                    BoxShadow(
                      color  : Colors.black.withValues(alpha: 0.08),
                      blurRadius   : 20,
                      spreadRadius : 2,
                      offset : const Offset(0, 8),
                    ),
                    BoxShadow(
                      color : Colors.black.withValues(alpha: 0.04),
                      blurRadius : 6,
                      offset     : const Offset(0, 2),
                    ),
                  ],
                ),
                padding    : const EdgeInsets.symmetric(
                  vertical   : 6,
                  horizontal : 6,
                ),
                width : widget.menuWidth,
                child :
                ListView.builder(
                  shrinkWrap  : true,
                  padding     : EdgeInsets.zero,
                  physics     : const NeverScrollableScrollPhysics(),
                  itemCount   : widget.items.length,
                  itemBuilder : (context, index) =>
                  _NSubMenuItem(
                    asset   : widget.items[index].asset,
                    text    : widget.items[index].text,
                    color   : widget.items[index].color,
                    tooltip : widget.items[index].tooltip,
                    onTap   : widget.items[index].onTap,
                    onHide  : _closeNDropdown,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _closeNDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
  MouseRegion(
    cursor  : widget.enabled ? SystemMouseCursors.click: MouseCursor.defer,
    onEnter : widget.enabled ? (_) => setState(() => isOver = true ) : null,
    onExit  : widget.enabled ? (_) => setState(() => isOver = false) : null,
    child   :
    InkWell(
      onTap : () => _overlayEntry == null ? _openNDropdown() : _closeNDropdown(),
      child :
      Container(
        width  : widget.dimension,
        height : widget.dimension,
        color  : Colors.transparent,
        margin : widget.margin,
        child  :
        Image.asset(
          !widget.enabled
          ? (widget.disableAsset ?? widget.asset)
          : isOver
            ? (widget.oversset ?? widget.asset)
            : widget.asset
        ),
      ),
    )
  );
}

/// Configuración de una opción del menú.
class NSubMenuItem {
  final String? asset;
  final String? text;
  final Color?  color;
  final String? tooltip;
  final GestureTapCallback onTap;

  const NSubMenuItem({
    this.asset,
    this.text,
    this.color,
    this.tooltip,
    required this.onTap,
  });
}

/// Ítem clickable del menú.
class _NSubMenuItem extends StatefulWidget {
  final String? asset;
  final String? text;
  final Color?  color;
  final String? tooltip;
  final GestureTapCallback onTap;
  final GestureTapCallback onHide;

  const _NSubMenuItem({
    this.asset,
    this.text,
    this.color,
    this.tooltip,
    required this.onTap,
    required this.onHide,
  });

  @override
  State<_NSubMenuItem> createState() => _NSubMenuItemState();
}

class _NSubMenuItemState extends State<_NSubMenuItem> {
  bool isOver = false;

  @override
  Widget build(BuildContext context) =>
  MouseRegion(
    cursor  : SystemMouseCursors.click,
    onEnter : (_) => setState(() => isOver = true ),
    onExit  : (_) => setState(() => isOver = false),
    child   :
    NTooltip(
      message : widget.tooltip ?? "",
      child   :
      GestureDetector(
        onTap : () {
          widget.onTap.call();
          widget.onHide.call();
        },
        child :
        AnimatedContainer(
          duration   : const Duration(milliseconds: 100),
          height     : 36,
          margin     : const EdgeInsets.symmetric(
            vertical   : 2,
            horizontal : 4,
          ),
          padding    : const EdgeInsets.symmetric(horizontal: 12),
          decoration : BoxDecoration(
            color : isOver ? (widget.color ?? context.textColor).withValues(alpha: 0.06) : Colors.transparent,
            borderRadius : BorderRadius.circular(8),
          ),
          child :
          Row(
            spacing  : 12,
            children : [
              if(widget.asset != null)
              Image.asset(
                widget.asset!,
                width  : 16,
                height : 16,
              ),
              if(widget.text  != null)
              Expanded(
                child :
                NText(
                  text     : widget.text!,
                  color    : widget.color ?? context.textColor,
                  size     : 13,
                  weight   : isOver ? FontWeight.w500 : FontWeight.w400,
                  overflow : TextOverflow.ellipsis,
                  maxLines : 1,
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}
