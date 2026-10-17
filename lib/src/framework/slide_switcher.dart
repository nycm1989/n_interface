import 'package:flutter/material.dart'
    show
        AnimatedSwitcher,
        Animation,
        BuildContext,
        ClipRect,
        Curves,
        FadeTransition,
        KeyedSubtree,
        Offset,
        SlideTransition,
        State,
        StatefulWidget,
        StatelessWidget,
        Tween,
        ValueKey,
        Widget;

/// Anima el cambio de contenido de un stack navegable (pestañas, pasos de un
/// stepper, etc.) con un deslizamiento direccional combinado con desvanecido: el
/// contenido nuevo entra por el lado que marca el avance del índice y el viejo
/// sale hacia el opuesto (efecto carrusel). Es AGNÓSTICO al contenido: solo
/// recibe el índice del elemento activo y el widget ya construido. El estado del
/// contenido debe vivir fuera (controllers), porque la animación monta/desmonta.
class NSlideSwitcher extends StatefulWidget {
  /// Orden del elemento activo dentro de su lista visible. Su cambio dispara la
  /// animación; su sentido (mayor/menor) orienta el deslizamiento.
  final int currentIndex;

  /// Contenido ya construido para [currentIndex].
  final Widget child;

  const NSlideSwitcher({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  @override
  State<NSlideSwitcher> createState() => _NSlideSwitcherState();
}

/// Estado de la animación: recuerda el sentido del último cambio de índice para
/// decidir desde qué lado entra el contenido nuevo (y hacia cuál sale el viejo).
class _NSlideSwitcherState extends State<NSlideSwitcher> {
  /// `true` = avanza (índice mayor) → entra desde la derecha; `false` = retrocede
  /// → entra desde la izquierda. Arranca en `true` por defecto.
  bool _forward = true;

  /// Duración de la transición; alineada con el carrusel del header (220 ms).
  static const int _durationMs = 220;

  /// Recalcula el sentido comparando el índice nuevo contra el anterior.
  @override
  void didUpdateWidget(covariant NSlideSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _forward = widget.currentIndex > oldWidget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) => ClipRect(
        child: AnimatedSwitcher(
          duration          : const Duration(milliseconds: _durationMs),
          switchInCurve     : Curves.easeInOut,
          switchOutCurve    : Curves.easeInOut,
          transitionBuilder : (child, animation) => _DirectionalSlideFade(
            animation : animation,
            incoming  : child.key == ValueKey<int>(widget.currentIndex),
            forward   : _forward,
            child     : child,
          ),
          child: KeyedSubtree(
            key   : ValueKey<int>(widget.currentIndex),
            child : widget.child,
          ),
        ),
      );
}

/// Transición de un elemento: se desvanece mientras se desliza en horizontal. El
/// entrante llega desde el lado del avance; el saliente parte hacia el opuesto,
/// logrando el efecto carrusel. Usa la `animation` que ya trae la curva aplicada
/// por el [AnimatedSwitcher] (sin re-curvarla, para no duplicar el easing).
class _DirectionalSlideFade extends StatelessWidget {
  /// Progreso de la transición (entrante 0→1; saliente 1→0), ya curvado.
  final Animation<double> animation;

  /// `true` si este child es el contenido que entra; `false` si es el que sale.
  final bool incoming;

  /// Sentido del cambio de índice (avanza / retrocede).
  final bool forward;

  final Widget child;

  const _DirectionalSlideFade({
    required this.animation,
    required this.incoming,
    required this.forward,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(begin: _beginOffset, end: Offset.zero).animate(animation),
          child: child,
        ),
      );

  /// Punto de partida del deslizamiento (fracción del ancho): el entrante arranca
  /// en el lado del avance; el saliente, en el opuesto.
  Offset get _beginOffset => incoming
      ? Offset(forward ? 1.0 : -1.0, 0)
      : Offset(forward ? -1.0 : 1.0, 0);
}
