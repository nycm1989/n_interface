import 'package:flutter/material.dart';

/// Este widget se encarga de obtener el error de su widget hijo
/// - [child] es el widget hijo
/// - [onError] es el hijo que muestra si ocurre un error
class NErrorHandler extends StatelessWidget {

  /// widget hijo por defecto
  final Widget Function(BuildContext context) builder;

  /// Hijo que retorna el widget en caso de que ocurra un error
  final Widget Function(BuildContext context, Object error, StackTrace? stackTrace)? onError;

  const NErrorHandler({
    super.key,
    required this.builder,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return builder(context);
    } catch (error, stackTrace) {
      if (onError != null) return onError!(context, error, stackTrace);
      return Center(
        child:
        Text(
          "$error",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }
}