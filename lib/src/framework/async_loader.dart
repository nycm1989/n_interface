import 'dart:async' show StreamController, FutureOr;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PointerEnterEventListener, PointerExitEventListener;

/// NAsyncLoader
///
/// Widget stateful que maneja flujos asíncronos y renderiza UI en función
/// del estado de carga. Permite:
/// - Ejecutar una carga inicial (`onLoading`) al montar el widget
/// - Ejecutar acciones asíncronas al hacer tap (`onTap`)
/// - Mostrar un indicador de carga personalizado (`indicator`)
/// - Escuchar eventos de hover (`onEnter`, `onExit`)
///
/// Internamente utiliza un StreamController para emitir estados de carga
/// y un StreamBuilder para reconstruir la UI.
class NAsyncLoader extends StatefulWidget {

  /// Callback opcional que se ejecuta automáticamente al iniciar el widget.
  /// Usado para cargas iniciales (ej: fetch de datos).
  final Future<void> Function()? onLoading;

  /// Callback opcional que se ejecuta al hacer tap sobre el widget.
  /// Puede ser síncrono o asíncrono.
  final FutureOr<void> Function()? onTap;

  /// Callback opcional que se ejecuta cuando termina cualquier proceso async
  /// (onLoading o onTap).
  final Function()? onFinished;

  /// Callback opcional que se dispara cuando el cursor entra en el widget.
  final PointerEnterEventListener? onEnter;

  /// Callback opcional que se dispara cuando el cursor sale del widget.
  final PointerExitEventListener? onExit;

  /// Widget principal que se muestra cuando NO está en estado de carga.
  final Widget child;

  /// Widget opcional que se muestra durante el estado de carga.
  /// Si no se define, se usa un CircularProgressIndicator por defecto.
  final Widget? indicator;

  const NAsyncLoader({
    this.onLoading,
    this.onFinished,
    this.onTap,
    this.onEnter,
    this.onExit,
    required this.child,
    this.indicator,
    super.key
  });

  @override
  State<NAsyncLoader> createState() => NAsyncLoaderState();
}

/// Estado interno encargado de gestionar el ciclo de vida del loading
/// y la comunicación con el StreamBuilder.
class NAsyncLoaderState extends State<NAsyncLoader> {
  /// Controlador de stream que emite el estado de carga (true = loading).
  StreamController<bool>? streamController;

  /// Cierra el stream y limpia el estado interno.
  void close() {
    streamController?.close();
    if (mounted) {
      setState(() => streamController = null);
    } else {
      streamController = null;
    }
  }

  /// Ejecuta la carga inicial si `onLoading` está definido.
  /// Activa el estado de loading y lo desactiva al finalizar.
  Future<void> startLoading() async {
    if (widget.onLoading == null) {
      close();
      return;
    }

    if (streamController != null) return;

    streamController = StreamController<bool>();
    if (mounted) {
      setState(() => streamController?.add(true));
    } else {
      streamController?.add(true);
    }

    try {
      await Future(widget.onLoading!);
    } catch (error, stackTrace) {
      debugPrint("$error\n\n$stackTrace");
    } finally {
      close();
      widget.onFinished?.call();
    }
  }

  /// Maneja el evento de tap. Ejecuta lógica async si aplica
  /// y controla el estado de loading durante la ejecución.
  Future<void> onTap(ConnectionState connectionState) async {
    if (connectionState == ConnectionState.none) {
      if (widget.onTap is Future<void> Function()) {
        streamController = StreamController<bool>();
        setState(() => streamController?.add(true));
        await Future.value(widget.onTap!())
        .whenComplete(() {
          streamController?.close();
          if (mounted) {
            setState(() => streamController = null);
          } else {
            streamController = null;
          }
        })
        .then((value) {
          streamController?.close();
          if (mounted) {
            setState(() => streamController = null);
          } else {
            streamController = null;
          }
          widget.onFinished?.call();
        });
      } else {
        streamController?.close();
        streamController = null;
        widget.onTap?.call();
        widget.onFinished?.call();
      }
    }
  }

  /// `true` mientras hay un proceso asíncrono en curso.
  bool get isLoading => streamController != null;

  /// Dispara [NAsyncLoader.onTap] desde fuera del widget (por ejemplo, al
  /// presionar Enter en un text field) para reutilizar el loading del tap real
  /// en vez de duplicar esa lógica en el call site. Se ignora si ya hay un
  /// proceso en curso, igual que un segundo tap.
  Future<void> trigger() async {
    if (isLoading) return;
    await onTap(ConnectionState.none);
  }

  /// Inicializa el widget y dispara la carga inicial.
  @override
  void initState() {
    super.initState();
    startLoading();
  }

  /// Libera recursos cerrando el stream.
  @override
  void dispose() {
    super.dispose();
    streamController?.close();
  }

  /// Método llamado en hot reload. Asegura que el stream no quede abierto.
  @override
  void reassemble() {
    super.reassemble();
    streamController?.close();
  }

  /// Construye la UI en función del estado del stream:
  /// - Sin conexión: muestra `child`
  /// - En loading: muestra `indicator` o uno por defecto
  ///
  /// También maneja interacción (tap y hover).
  @override
  Widget build(BuildContext context) =>
  MouseRegion(
    cursor  : widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer, // MouseCursor.uncontrolled,
    onEnter : widget.onTap != null ? widget.onEnter : null,
    onExit  : widget.onTap != null ? widget.onExit  : null,
    child   :
    StreamBuilder<bool>(
      stream : streamController?.stream,
      builder: (context, snapshot) =>
      GestureDetector(
        behavior : widget.onTap != null ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
        onTap    : widget.onTap == null ? null : () => onTap(snapshot.connectionState),
        child    : snapshot.connectionState == ConnectionState.none
        ? widget.child
        : widget.indicator ?? Container(
          height    : 60,
          alignment : Alignment.center,
          child     :
          const SizedBox.square(
            dimension : 40,
            child     : CircularProgressIndicator(strokeWidth: 1),
          ),
        ),
      ),
    ),
  );
}
