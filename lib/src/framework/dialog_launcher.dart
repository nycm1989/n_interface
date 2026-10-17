import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:n_interface/src/extenssions/context_extension.dart' show ContextExtension;
import 'package:n_interface/src/framework/responsive_builder.dart' show NResponsiveBuilder;
import 'package:n_interface/src/framework/text.dart' show NText;

class CreateDialog {
  static Future<void>? make( BuildContext context, {
    Future<void> Function()? onLoading,
    String title    = "",
    required Widget child,
    double? modalHeight,
    double? dialogHeight,
    double maxWidth = 600,
    VoidCallback? onDismissed,
    /// Tema opcional aplicado al diálogo y a su contenido.
    ThemeData? theme,
  }) {
    final GlobalKey<_DragToDismissState> dragKey = GlobalKey<_DragToDismissState>();
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque : false,
        barrierDismissible : true,
        pageBuilder : (context, _, _) =>
        Theme(
          data  : theme ?? Theme.of(context),
          child :
        Scaffold(
          backgroundColor : Colors.transparent,
          body :
          _DialogSurface(
            dragKey     : dragKey,
            title : title,
            maxWidth    : maxWidth,
            onDismissed : onDismissed,
            child : child,
          )
        )
        )
      )
    );
  }
}

/// Contenido de la ruta del diálogo: el velo de fondo desenfocado y el
/// diálogo centrado (o abajo, en mobile).
///
/// Es stateful porque el velo tiene su propia animación, que en mobile
/// se desvanece **antes** de que el diálogo se deslice hacia afuera.
/// Así el blur no queda "colgado" mientras la hoja se retira.
class _DialogSurface extends StatefulWidget {
  final GlobalKey<_DragToDismissState> dragKey;
  final String title;
  final double maxWidth;
  final Widget child;
  final VoidCallback? onDismissed;

  const _DialogSurface({
    required this.dragKey,
    required this.title,
    required this.maxWidth,
    required this.child,
    this.onDismissed,
  });

  @override
  State<_DialogSurface> createState() => _DialogSurfaceState();
}

class _DialogSurfaceState extends State<_DialogSurface> with SingleTickerProviderStateMixin {
  static const double    _sigma = 4;
  static const double    _veilAlpha    = 0.15;
  static const Duration  _blurDuration = Duration(milliseconds: 120);

  /// Arranca en 1 para que el velo ya esté presente al abrir; el cierre
  /// lo lleva a 0 con [fadeOutVeil].
  late final AnimationController _veil = AnimationController(
    vsync    : this,
    duration : _blurDuration,
    value    : 1,
  );

  /// Attenúa el velo de fondo. Va antes de la animación de salida del
  /// diálogo en mobile.
  Future<void> fadeOutVeil() async {
    if(_veil.isAnimating) return;
    try {
      await _veil.reverse().orCancel;
    } on TickerCanceled {
      return;
    }
  }

  /// Cierra la ruta del diálogo y avisa al llamador.
  void _close() {
    Navigator.of(context).pop();
    widget.onDismissed?.call();
  }

  @override
  void dispose() {
    _veil.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
  NResponsiveBuilder(
    builder : (screenType, size, axis) {
      return Stack(
        children : [
          Positioned.fill(
            child :
            GestureDetector(
              onTap : () {
                final _DragToDismissState? state = widget.dragKey.currentState;
                if (state == null) {
                  _close();
                } else {
                  state.animatedDismiss();
                }
              },
              child :
              AnimatedBuilder(
                animation : _veil,
                builder   : (_, _) => BackdropFilter(
                  filter : ImageFilter.blur(sigmaX: _sigma * _veil.value, sigmaY: _sigma * _veil.value),
                  child  : Container(
                    color : Colors.black.withValues(alpha: _veilAlpha * _veil.value),
                  ),
                ),
              )
            )
          ),
          Align(
            alignment : screenType == .mobile ? .bottomCenter : .center,
            child     :
            _DragToDismiss(
              title     : widget.title,
              key  : widget.dragKey,
              enabled   : screenType == .mobile,
              onBeforeDismiss : fadeOutVeil,
              onDismiss : _close,
              size : size,
              maxWidth  : widget.maxWidth,
              child     : widget.child,
            )
          )
        ],
      );
    }
  );
}

/// Envuelve el contenido permitiendo cerrar el diálogo con un gesto
/// de arrastre hacia abajo (como un BottomSheet).
///
/// El contenido baja siguiendo el dedo/mouse y al soltarlo se anima
/// hacia afuera de la pantalla y se cierra, o vuelve a su posición
/// si no se superó el umbral.
class _DragToDismiss extends StatefulWidget {
  final String title;

  /// Indica si el gesto está activo (solo cuando el contenedor está abajo).
  final bool enabled;

  /// Se ejecuta antes de la animación de salida, para que el velo de fondo
  /// pueda desvanecerse primero. En desktop no se usa.
  final Future<void> Function()? onBeforeDismiss;

  /// Se invoca cuando el gesto supera el umbral y debe cerrarse.
  final VoidCallback onDismiss;

  /// Contenido arrastrable.
  final Widget child;

  final double maxWidth;

  final BoxConstraints size;

  const _DragToDismiss({
    super.key,
    required this.title,
    required this.enabled,
    this.onBeforeDismiss,
    required this.onDismiss,
    required this.child,
    required this.maxWidth,
    required this.size,
  });

  @override
  State<_DragToDismiss> createState() => _DragToDismissState();
}

class _DragToDismissState extends State<_DragToDismiss> with SingleTickerProviderStateMixin {
  static const double _dismissThreshold  = 120;
  static const double _velocityThreshold = 800;
  static const Duration _duration = Duration(milliseconds: 220);

  /// Proporción de la pantalla que ocupa el diálogo como máximo en mobile.
  /// Deja libre el borde superior para que se lea como hoja y no como
  /// pantalla completa.
  static const double _maxHeightRatio = 0.9;

  late final AnimationController _controller;
  Tween<double>? _tween;
  double _dragOffset = 0;

  /// Evita que un segundo toque (o un gesto mientras se cierra) dispare
  /// otra cadena de animación.
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addListener(_onAnimation);

    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback(_animateIn);
    }
  }

  /// Anima la entrada: el contenedor desliza desde abajo hasta su posición
  /// (mismo movimiento que el gesto, pero en reversa).
  void _animateIn(Duration timeStamp) {
    if (!mounted) return;
    final double height = MediaQuery.of(context).size.height;
    _dragOffset = height;
    setState(() {});
    _animateTo(height, 0);
  }

  /// Cierra el diálogo. En mobile el orden es: primero se desvanece el
  /// velo de fondo y después el contenido se desliza hacia abajo.
  Future<void> animatedDismiss() async {
    if(_dismissing) return;

    if(!widget.enabled) {
      widget.onDismiss();
      return;
    }

    _dismissing = true;

    await widget.onBeforeDismiss?.call();
    if (!mounted) return;

    final double height = MediaQuery.of(context).size.height;
    _animateTo(_dragOffset, height,
      onComplete : widget.onDismiss,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAnimation() {
    final Tween<double>? tween = _tween;
    if (tween == null) return;
    setState(() {
      _dragOffset = tween.evaluate(_controller);
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _dismissing) return;
    _controller.stop();
    setState(() {
      _dragOffset = math.max(0, _dragOffset + details.delta.dy);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!widget.enabled || _dismissing) return;

    final bool shouldDismiss =
      (details.primaryVelocity ?? 0) > _velocityThreshold ||
      _dragOffset                  > _dismissThreshold;

    if (shouldDismiss) {
      animatedDismiss();
    } else {
      _animateTo(_dragOffset, 0);
    }
  }

  void _animateTo(double from, double to, {
    VoidCallback? onComplete,
  }) {
    _tween = Tween<double>(begin: from, end: to);
    _controller
      ..stop()
      ..forward(from: 0)
        .then((_) => onComplete?.call());
  }

  @override
  Widget build(BuildContext context) =>
  GestureDetector(
    onVerticalDragUpdate : widget.enabled ? _onVerticalDragUpdate : null,
    onVerticalDragEnd    : widget.enabled ? _onVerticalDragEnd : null,
    child :
    Transform.translate(
      offset : Offset(0, _dragOffset),
      child  :
      Container(
        margin : widget.enabled ? null : .all(20),
        // width       : screenType == .mobile ? size.maxWidth : maxWidth,
        constraints :
        BoxConstraints(
          maxWidth  : widget.enabled ? widget.size.maxWidth : widget.maxWidth,
          maxHeight : widget.enabled
          ? widget.size.maxHeight * _maxHeightRatio
          : widget.size.maxHeight - context.topSize
        ),
        // height      : 200,
        decoration :
        BoxDecoration(
          borderRadius : widget.enabled ? null : .circular(10),
          border : widget.enabled
          ? Border(top: BorderSide(width: 2, color: context.borderColor))
          : .all(width: 2, color: context.borderColor),
          color  : context.primaryColor
        ),
        child :
        Column(
          mainAxisSize : .min,
          children     : [
            if(widget.enabled)
            Container(
              margin     : .symmetric(vertical: 7),
              width : 130,
              height     : 2,
              decoration :
              BoxDecoration(
                color : context.mainColor,
                borderRadius : .circular(2.5)
              ),
            ),
            Container(
              padding : const .symmetric(horizontal: 5, vertical: 5),
              // decoration: BoxDecoration(
              //   border: Border(bottom: BorderSide(color: context.dividerColor))
              // ),
              child :
              Row(
                spacing  : 5,
                children : [
                  Expanded(
                    child :
                    NText(
                      margin  : const .only(left: 5),
                      text    : widget.title,
                      size    : 16,
                    )
                  ),
                  InkWell(
                    onTap : animatedDismiss,
                    child :
                    Padding(
                      padding : const .all(3),
                      child   : Icon(Icons.close),
                    )
                  )
                ],
              ),
            ),
            Flexible(
              child : widget.child
            ),
          ],
        )
      )
    )
  );
}