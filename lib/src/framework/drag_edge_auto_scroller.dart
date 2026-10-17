import 'dart:async' show Timer;

import 'package:flutter/gestures.dart' show GestureBinding, PointerDownEvent, PointerEvent, PointerMoveEvent;
import 'package:flutter/material.dart';

/// Duración de cada paso del desplazamiento automático (~60 fps).
const Duration _tickDuration = Duration(milliseconds: 16);

/// Porción de segundo que representa un paso, para convertir la velocidad
/// configurada (píxeles por segundo) en el avance de un solo paso.
const double _tickSeconds = 0.016;

/// Holgura vertical antes de considerar que el puntero abandonó el área.
const double _verticalTolerance = 60;

/// Desplaza automáticamente un scroll horizontal mientras se arrastra un
/// elemento y el puntero se acerca a los bordes del área envuelta.
///
/// Resuelve el caso de un kanban con más columnas de las que caben en
/// pantalla: durante el arrastre el puntero está tomado por el elemento, así
/// que ningún gesto de scroll queda disponible para alcanzar las columnas que
/// están fuera de vista.
///
/// Observa los eventos crudos del puntero con un [Listener], por lo que no
/// compite en la arena de gestos: los gestos del contenido envuelto (arrastre
/// del elemento, scroll por arrastre del fondo, rueda del mouse, barra de
/// scroll) siguen funcionando sin cambios.
class NDragEdgeAutoScroller extends StatefulWidget {
  /// Controlador del scroll horizontal que se desplaza automáticamente.
  final ScrollController controller;

  /// Bandera de arrastre activo. El dueño la levanta al iniciar el arrastre;
  /// este widget la baja al soltar el puntero, porque el elemento arrastrado
  /// puede desmontarse (listas que reciclan sus ítems) y dejar de notificar
  /// el final del arrastre.
  final ValueNotifier<bool> isDragging;

  /// Contenido envuelto, normalmente el área desplazable completa.
  final Widget child;

  /// Ancho de la zona sensible en cada borde del área.
  final double edgeSize;

  /// Velocidad al entrar en la zona sensible, en píxeles por segundo.
  final double minVelocity;

  /// Velocidad pegado al borde, en píxeles por segundo.
  final double maxVelocity;

  const NDragEdgeAutoScroller({
    super.key,
    required this.controller,
    required this.isDragging,
    required this.child,
    this.edgeSize    = 110,
    this.minVelocity = 220,
    this.maxVelocity = 1400,
  });

  @override
  State<NDragEdgeAutoScroller> createState() {
    return _NDragEdgeAutoScrollerState();
  }
}

class _NDragEdgeAutoScrollerState extends State<NDragEdgeAutoScroller> {
  Timer?            _ticker;
  PointerMoveEvent? _lastPointerMove;
  double            _velocity = 0;

  @override
  void initState() {
    super.initState();
    widget.isDragging.addListener(_handleDragFlagChanged);
  }

  @override
  void didUpdateWidget(covariant NDragEdgeAutoScroller oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isDragging != widget.isDragging) {
      oldWidget.isDragging.removeListener(_handleDragFlagChanged);
      widget.isDragging.addListener(_handleDragFlagChanged);
    }
  }

  @override
  void dispose() {
    widget.isDragging.removeListener(_handleDragFlagChanged);
    _stop();
    super.dispose();
  }

  /// Detiene el desplazamiento cuando el dueño baja la bandera de arrastre.
  void _handleDragFlagChanged() {
    if (!widget.isDragging.value) {
      _stop();
    }
  }

  /// Limpia el estado heredado antes de que empiece un gesto nuevo, para que
  /// una bandera que quedó levantada no active el desplazamiento por error.
  void _handlePointerDown(PointerDownEvent event) {
    _stop();
    widget.isDragging.value = false;
  }

  /// Reevalúa dirección y velocidad en cada movimiento del puntero.
  void _handlePointerMove(PointerMoveEvent event) {
    if (!widget.isDragging.value) {
      _stop();
      return;
    }

    _lastPointerMove = event;
    _updateVelocity(event.position);
  }

  /// Detiene el desplazamiento al soltar o cancelar el puntero.
  void _handlePointerRelease(PointerEvent event) {
    _stop();
    widget.isDragging.value = false;
  }

  /// Calcula hacia qué lado y a qué velocidad debe desplazarse el área según
  /// la cercanía del puntero a cada borde. Detiene el desplazamiento si el
  /// puntero está lejos de ambos bordes o si salió del área verticalmente.
  void _updateVelocity(Offset globalPosition) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;

    if (box == null || !box.hasSize) {
      _stop();
      return;
    }

    final Offset localPosition = box.globalToLocal(globalPosition);

    if (localPosition.dy < -_verticalTolerance ||
        localPosition.dy > box.size.height + _verticalTolerance) {
      _stop();
      return;
    }

    final double distanceToLeft  = localPosition.dx;
    final double distanceToRight = box.size.width - localPosition.dx;

    if (distanceToLeft < widget.edgeSize && distanceToLeft <= distanceToRight) {
      _velocity = -_velocityFor(distanceToLeft);
    } else if (distanceToRight < widget.edgeSize) {
      _velocity = _velocityFor(distanceToRight);
    } else {
      _stop();
      return;
    }

    _start();
  }

  /// Traduce la distancia al borde en velocidad: suave al entrar en la zona
  /// sensible y máxima pegado al borde (o ya fuera del área).
  double _velocityFor(double distanceToEdge) {
    final double proximity =
        1 - (distanceToEdge.clamp(0, widget.edgeSize) / widget.edgeSize);

    return widget.minVelocity +
        (widget.maxVelocity - widget.minVelocity) * proximity * proximity;
  }

  /// Arranca el desplazamiento periódico si todavía no está corriendo.
  void _start() {
    _ticker ??= Timer.periodic(_tickDuration, _onTick);
  }

  /// Detiene el desplazamiento y limpia la velocidad acumulada.
  void _stop() {
    _ticker?.cancel();
    _ticker   = null;
    _velocity = 0;
  }

  /// Avanza el scroll un paso, sin pasarse de los extremos, y avisa al
  /// arrastre en curso del contenido que quedó bajo el puntero.
  void _onTick(Timer timer) {
    if (!widget.isDragging.value || widget.controller.positions.length != 1) {
      _stop();
      return;
    }

    final ScrollPosition position = widget.controller.position;
    final double target = (position.pixels + _velocity * _tickSeconds)
        .clamp(position.minScrollExtent, position.maxScrollExtent);

    if (target == position.pixels) {
      return;
    }

    position.jumpTo(target);
    _notifyDragTargets();
  }

  /// Reenvía la última posición del puntero como un movimiento de delta cero.
  /// El arrastre solo recalcula su destino cuando el puntero se mueve, así que
  /// sin este aviso el contenido se desplazaría por debajo sin actualizar el
  /// destino resaltado ni el lugar donde caería el elemento soltado.
  void _notifyDragTargets() {
    if (_lastPointerMove == null) {
      return;
    }

    GestureBinding.instance.handlePointerEvent(
      _lastPointerMove!.copyWith(
        delta      : Offset.zero,
        synthesized: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown  : _handlePointerDown,
      onPointerMove  : _handlePointerMove,
      onPointerUp    : _handlePointerRelease,
      onPointerCancel: _handlePointerRelease,
      child          : widget.child,
    );
  }
}
