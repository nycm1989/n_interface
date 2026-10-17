// ignore_for_file: library_private_types_in_public_api

import 'dart:async' show FutureOr;
import 'package:n_interface/n_interface.dart' show ContextExtension, NTooltip, NText, NFlexibleBox, NErrorHandler;

import 'async_loader.dart' show NAsyncLoader, NAsyncLoaderState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dotted_decoration/dotted_decoration.dart' show DottedDecoration, Shape;

enum ButtonType{
  normal,
  red,
  flat,
  white,
  dashed
}

class NButton extends StatefulWidget {

  /// Al establecer un valor nulo a [onTap] la lògica
  /// cambia para que el boton se bloquee
  final FutureOr<void> Function()? onTap;

  final Future<void> Function()? onLoading;

  /// Activa la decoración selección del botón
  final bool isSelected;

  /// Altera el orden de los elementos del boton
  final bool turned;

  /// Texto que aparece en el boton
  final String text;

  /// Mensaje al pasar el mouse por encima
  final String? tooltip;

  /// Al establecer un valor no nulo a [readOnlyTooltip] la lògica
  /// cambia para que el boton se bloquee y muestre el mensaje de
  /// bloqueo al pasar el mouse por encima
  final String? readOnlyTooltip;

  /// Ruta de un Asset para mostrar
  final String? asset;

  /// Ruta de un Asset para mostrar al pasar el mouse por encima
  final String? overAsset;

  /// Ruta de un Asset para mostrar cuando el botón está deshabilitado
  final String? disableAsset;

  /// Ruta de un Asset para mostrar cuando el estado de el botón es seleccionado
  final String? selectedAsset;

  /// Tamaño del texto y del ìcono
  final double size;

  /// Espaciado externo del botòn
  final EdgeInsetsGeometry?  margin;

  /// Espaciado interno del botòn
  final EdgeInsetsGeometry?  padding;

  /// Color del texto
  final Color? color;

  /// Color del texto
  final Color? highlightColor;

  /// Color del texto al pasar el mouse por encima
  final Color? overColor;

  /// Alineamiento del texto
  final TextAlign? textAlign;

  /// Alineamiento del texto
  final TextOverflow? textOverflow;

  /// Ancho del botón
  final double? width;

  /// Alto del botón
  final double? height;

  /// Muestra la decoración del borde del botón
  final bool showBorder;

  /// Muestra la sombra del botón
  final bool shadow;

  /// Reemplaza el indicador de carga que se muestra mientras corre un [onTap]
  /// asíncrono. Sin definir se usa el `CircularProgressIndicator` de siempre.
  final Widget? indicator;

  /// Tipo del botón privado declarado en los constructores
  final ButtonType type;

  const NButton({
    this.onTap,
    this.onLoading,
    this.type           = .normal,
    this.isSelected  = false,
    this.color,
    this.highlightColor,
    this.overColor,
    this.text           = "",
    this.asset,
    this.overAsset,
    this.disableAsset,
    this.selectedAsset,
    this.size           = 12,
    this.indicator,
    this.margin,
    this.padding,
    this.showBorder     = true,
    this.shadow         = true,
    this.turned         = false,
    this.textAlign,
    this.textOverflow,
    this.tooltip,
    this.readOnlyTooltip,
    this.width,
    this.height,
    super.key
  });

  const NButton.red({
    this.onTap,
    this.onLoading,
    this.text           = "",
    this.asset,
    this.overAsset,
    this.disableAsset,
    this.selectedAsset,
    this.size           = 12,
    this.indicator,
    this.margin,
    this.padding,
    this.showBorder     = true,
    this.shadow         = true,
    this.turned         = false,
    this.textAlign,
    this.textOverflow,
    this.tooltip,
    this.readOnlyTooltip,
    this.width,
    this.height,
    super.key
  }) :
  isSelected  = false,
  type       = .red,
  color       = null,
  highlightColor  = null,
  overColor   = null;


  const NButton.flat({
    this.onTap,
    this.onLoading,
    this.text           = "",
    this.asset,
    this.overAsset,
    this.disableAsset,
    this.selectedAsset,
    this.size           = 12,
    this.indicator,
    this.margin,
    this.padding,
    this.turned         = false,
    this.textAlign,
    this.textOverflow,
    this.tooltip,
    this.readOnlyTooltip,
    this.color,
    this.overColor,
    this.width,
    this.height,
    super.key
  }) :
  isSelected  = false,
  showBorder  = false,
  shadow      = false,
  highlightColor  = null,
  type       = .flat;

  const NButton.white({
    this.onTap,
    this.onLoading,
    this.isSelected     = false,
    this.text           = "",
    this.asset,
    this.overAsset,
    this.disableAsset,
    this.selectedAsset,
    this.size           = 12,
    this.indicator,
    this.margin,
    this.padding,
    this.showBorder     = true,
    this.highlightColor,
    this.shadow         = true,
    this.turned         = false,
    this.textAlign,
    this.textOverflow,
    this.tooltip,
    this.readOnlyTooltip,
    this.width,
    this.height,
    super.key
  }) :
  type     = .white,
  color     = null,
  overColor = null;

  const NButton.dashed({
    this.onTap,
    this.onLoading,
    this.text           = "",
    this.asset,
    this.overAsset,
    this.disableAsset,
    this.selectedAsset,
    this.size           = 12,
    this.indicator,
    this.margin,
    this.padding,
    this.showBorder     = false,
    this.shadow         = false,
    this.turned         = false,
    this.textAlign,
    this.textOverflow,
    this.tooltip,
    this.readOnlyTooltip,
    this.width,
    this.height,
    super.key
  }) :
  isSelected  = false,
  type       = .dashed,
  color       = null,
  highlightColor  = null,
  overColor   = null;

  @override
  State<NButton> createState() => NButtonState();
}

class NButtonState extends State<NButton> {
  final GlobalKey<NAsyncLoaderState> loaderKey = GlobalKey<NAsyncLoaderState>();

  BoxShape shape = .rectangle;
  bool isOver = false;

  /// Ejecuta el [NButton.onTap] como si se hubiera presionado el botón,
  /// reutilizando su indicador de carga interno. Sirve para dispararlo desde el
  /// teclado (Enter en un text field) sin duplicar la lógica async en el call
  /// site. No hace nada si el botón no tiene `onTap` o ya está en loading.
  Future<void> submit() async {
    final loaderState = loaderKey.currentState;
    if (loaderState != null) await loaderState.trigger();
  }

  List<BoxShadow> _shadow(bool enable) => [BoxShadow(
    color     : enable ? Colors.black26 : Colors.transparent,
    offset    : const Offset(0, 2),
    blurRadius: 2,
  )];

  BoxDecoration buttonWhiteDecoration({
    required bool isCircle,
    required bool shadow,
    required bool showBorder,
    required bool isSelected,
    required Color highlightColor,
  }) =>
  BoxDecoration(
    color       : isSelected ? highlightColor : Colors.white,
    border      : showBorder ? .all(color: highlightColor) : null,
    borderRadius: isCircle ? null : BorderRadius.circular(10),
    shape       : isCircle ? .circle : .rectangle,
    boxShadow   : shadow ? _shadow(shadow) : null
  );

  BoxDecoration buttonDisableDecoration({
    required bool isCircle,
    required bool shadow,
    required bool showBorder
  }) =>
  BoxDecoration(
    color       : const Color(0xFFdbdbdb),
    border      : .all(color: const Color(0xFFdbdbdb)),
    borderRadius: isCircle ? null : .circular(10),
    shape       : isCircle ? .circle : .rectangle,
    boxShadow   : shadow ? _shadow(false) : null
  );

  Decoration buttonDashedDecoration() =>
  DottedDecoration(
    color        : context.borderColor.withValues(alpha: 0.5),
    shape        : Shape.box,
    borderRadius : BorderRadius.circular(10),
    dash         : const [3, 3],
  );

  BoxDecoration buttonDecoration({
    required bool shadow,
    required bool isOver,
    required bool isCircle,
    required bool showBorder,
    bool isRed = false
  }) =>
  BoxDecoration(
    color       : isRed
    ? isOver ? const Color(0xFFfd171f) : Colors.red.shade900
    : isOver ? context.overedColor : context.mainColor,
    border      : showBorder ? .all(color: isOver ? context.overedColor : context.mainColor) : null,
    borderRadius: isCircle ? null : .circular(10),
    shape       : isCircle ? .circle : .rectangle,
    boxShadow   : shadow ? _shadow(isOver) : null
  );

  @override
  void initState() {
    super.initState();
    shape = widget.asset != null && widget.text.isEmpty ? .circle : .rectangle;
  }

  @override
  Widget build(BuildContext _) =>
  NTooltip(
    message : widget.readOnlyTooltip ?? widget.tooltip ?? "",
    color   : widget.readOnlyTooltip != null ? Colors.red.shade600 : null,
    child   :
    _Button(
      widget            : widget,
      decoration        :
      widget.type == .normal ? buttonDecoration(isOver: false, isCircle: widget.text.isEmpty, showBorder: true, shadow: true):
      widget.type == .red    ? buttonDecoration(isRed: true, isOver: false, isCircle: widget.text.isEmpty, showBorder: true, shadow: true) :
      widget.type == .white  ? buttonWhiteDecoration(isCircle: widget.text.isEmpty, shadow: widget.shadow, showBorder: widget.showBorder, isSelected: widget.isSelected, highlightColor: widget.highlightColor ?? context.mainColor) :
      widget.type == .dashed ? buttonDashedDecoration() : null,
      disableDecoration :
      widget.type == .normal ? buttonDisableDecoration(isCircle: widget.text.isEmpty, showBorder: true, shadow: true):
      widget.type == .red    ? buttonDisableDecoration(isCircle: widget.text.isEmpty, showBorder: true, shadow: true) :
      widget.type == .white  ? buttonDisableDecoration (isCircle: widget.text.isEmpty, showBorder: widget.showBorder, shadow: widget.shadow) :
      widget.type == .dashed ? buttonDashedDecoration() : null,
      overDecoration    :
      widget.type == .normal ? buttonDecoration(isOver: true,  isCircle: widget.text.isEmpty, showBorder: true, shadow: true):
      widget.type == .red    ? buttonDecoration(isRed: true, isOver: true,  isCircle: widget.text.isEmpty, showBorder: true, shadow: true) :
      widget.type == .white  ? buttonWhiteDecoration(isCircle: widget.text.isEmpty, shadow: widget.shadow, showBorder: widget.showBorder, isSelected: true, highlightColor: widget.highlightColor ?? context.mainColor) :
      widget.type == .dashed ? buttonDashedDecoration() : null,
      isOver            : isOver,
      disableColor      :
      widget.type == .normal ? Colors.grey:
      widget.type == .red    ? Colors.grey :
      widget.type == .flat   ? Colors.grey :
      widget.type == .white  ? Colors.white :
      widget.type == .dashed ? Colors.grey : null,
      overColor         :
      widget.type == .normal ? Colors.white:
      widget.type == .red    ? Colors.white :
      widget.type == .flat   ? widget.overColor  ?? const Color(0xff1B5E20) :
      widget.type == .white  ? Colors.white :
      widget.type == .dashed ? Colors.black87 : null,
      color             :
      widget.type == .normal ? Colors.white:
      widget.type == .red    ? Colors.white :
      widget.type == .flat   ? widget.color      ?? context.mainColor :
      widget.type == .white  ? widget.isSelected ? Colors.white : widget.highlightColor ?? context.mainColor :
      widget.type == .dashed ? Colors.grey : null,
      loaderKey         : loaderKey,
      onEnter           : (_)=> setState(() => isOver = true),
      onExit            : (_)=> setState(() => isOver = false),
    )
  );
}



class _Button extends StatelessWidget {
  final NButton widget;
  final Decoration? decoration;
  final Decoration? disableDecoration;
  final Decoration? overDecoration;
  final Color? disableColor;
  final Color? overColor;
  final Color? color;
  final bool isOver;
  final GlobalKey<NAsyncLoaderState> loaderKey;
  final PointerEnterEventListener ? onEnter;
  final PointerExitEventListener  ? onExit;

  const _Button({
    required this.widget,
    required this.decoration,
    required this.disableDecoration,
    required this.overDecoration,
    required this.isOver,
    required this.loaderKey,
    required this.onEnter,
    required this.onExit,
    required this.disableColor,
    required this.overColor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) =>
  NErrorHandler(
    builder: (context) =>
    AnimatedContainer(
      duration    : const Duration(milliseconds: 150),
      constraints : const BoxConstraints( minHeight: 30, minWidth: 30, ),
      decoration: widget.readOnlyTooltip != null || widget.onTap == null
      ? disableDecoration
      : isOver ? overDecoration : decoration,
      width     : widget.width  ?? (widget.asset != null && widget.text.isEmpty ? widget.size + 12 : null),
      height    : widget.height ?? (widget.asset != null && widget.text.isEmpty ? widget.size + 12 : null),
      margin    : widget.margin,
      alignment : .center,
      child     :
      widget.type == .dashed
      ? SizedBox.expand(
        child: NAsyncLoader(
          key       : loaderKey,
          onLoading : widget.onLoading,
          onTap     : widget.readOnlyTooltip != null ? null : widget.onTap,
          onEnter   : onEnter,
          onExit    : onExit,
          indicator :
          widget.indicator ??
          SizedBox.square(
            dimension : widget.size + 6,
            child     :
            CircularProgressIndicator(
              strokeWidth : 1,
              color       : widget.onTap == null ? disableColor : isOver ? overColor : color,
            )
          ),
          child     :
          Container(
            padding : widget.padding ?? (widget.asset != null && widget.text.isEmpty ? const .all(5) : const .symmetric(vertical: 3, horizontal: 6)),
            color   : Colors.transparent,
            child   :
            Row(
              mainAxisSize: widget.width == null ? .min : .max,
              mainAxisAlignment: (widget.textAlign == null || widget.textAlign == .center) ? .center : .start,
              spacing   : 5,
              children  : [
                if(!widget.turned)
                if(widget.asset != null)
                _Asset(
                  widget: widget,
                  isOver: isOver
                ),
                if(widget.text.isNotEmpty)
                (widget.textAlign == null || widget.textAlign == .center)
                ? Flexible(
                  child     :
                  NText(
                    weight    : .w400,
                    text      : widget.text,
                    overflow  : widget.textOverflow ?? .ellipsis,
                    align     : widget.textAlign    ?? .center,
                    color     : widget.onTap == null ? disableColor : isOver ? overColor : color,
                    size      : widget.size,
                  ),
                )
                : NFlexibleBox(
                  expandWhen: widget.width != null,
                  child     :
                  NText(
                    weight    : .w400,
                    text      : widget.text,
                    overflow  : widget.textOverflow ?? .ellipsis,
                    align     : widget.textAlign    ?? .center,
                    color     : widget.onTap == null ? disableColor : isOver ? overColor : color,
                    size      : widget.size,
                  ),
                ),
                if(widget.turned)
                if(widget.asset != null)
                _Asset(
                  widget: widget,
                  isOver: isOver
                )
              ],
            ),
          ),
        ),
      )
      : NAsyncLoader(
        key       : loaderKey,
        onTap     : widget.readOnlyTooltip != null ? null : widget.onTap,
        onEnter   : onEnter,
        onExit    : onExit,
        indicator :
        widget.indicator ??
        SizedBox.square(
          dimension : widget.size + 6,
          child     :
          CircularProgressIndicator(
            strokeWidth : 1,
            color       : widget.onTap == null ? disableColor : isOver ? overColor : color,
          )
        ),
        child     :
        Container(
          padding : widget.padding ?? (widget.asset != null && widget.text.isEmpty ? const .all(5) : const .symmetric(vertical: 3, horizontal: 6)),
          color   : Colors.transparent,
          child   :
          Row(
            mainAxisSize: widget.width == null ? .min : .max,
            mainAxisAlignment: (widget.textAlign == null || widget.textAlign == .center) ? .center : .start,
            spacing   : 5,
            children  : [
              if(!widget.turned)
              if(widget.asset != null)
              _Asset(
                widget: widget,
                isOver: isOver
              ),
              if(widget.text.isNotEmpty)
              (widget.textAlign == null || widget.textAlign == .center)
              ? Flexible(
                child     :
                NText(
                  weight    : .w400,
                  text      : widget.text,
                  overflow  : widget.textOverflow ?? .ellipsis,
                  align     : widget.textAlign    ?? .center,
                  color     : widget.onTap == null ? disableColor : isOver ? overColor : color,
                  size      : widget.size,
                ),
              )
              : NFlexibleBox(
                expandWhen: widget.width != null,
                child     :
                NText(
                  weight    : .w400,
                  text      : widget.text,
                  overflow  : widget.textOverflow ?? .ellipsis,
                  align     : widget.textAlign    ?? .center,
                  color     : widget.onTap == null ? disableColor : isOver ? overColor : color,
                  size      : widget.size,
                ),
              ),
              if(widget.turned)
              if(widget.asset != null)
              _Asset(
                widget: widget,
                isOver: isOver
              )
            ],
          ),
        ),
      ),
    ),
  );
}

class _Asset extends StatelessWidget {
  const _Asset({
    required this.widget,
    required this.isOver,
  });

  final NButton widget;
  final bool isOver;

  @override
  Widget build(BuildContext context) =>
  SizedBox.square(
    dimension : widget.size,
    child     :
    Image.asset(
      widget.onTap == null
      ? widget.disableAsset ?? widget.asset!
      : isOver
        ? widget.overAsset ?? widget.asset!
        // Seleccionado y hover comparten fondo (ambos pintan highlightColor), así
        // que comparten fallback: sin él, el ícono queda verde sobre verde.
        : widget.isSelected ? (widget.selectedAsset ?? widget.overAsset ?? widget.asset!) : widget.asset!,
      fit   : .contain,
      // width : widget.size,
      // height: widget.size,
    )
  );
}
