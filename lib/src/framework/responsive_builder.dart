import 'dart:async' show Future;
import 'package:flutter/material.dart';
import 'package:n_interface/src/enums/screen_type.dart' show ScreenType;
import 'package:n_interface/src/extenssions/box_constraints_extension.dart' show ScreenTypeExtension;


import 'async_loader.dart' show NAsyncLoader;

/// NResponsiveBuilder
///
/// Widget encargado de construir layouts responsivos basados en el tamaño disponible.
/// Internamente usa un LayoutBuilder para obtener las restricciones (`BoxConstraints`)
/// y determinar el tipo de pantalla (`ScreenType`) y orientación (`AxisData`).
///
/// También envuelve el contenido en un `NAsyncLoader`, permitiendo ejecutar lógica asíncrona
/// antes de renderizar el contenido principal.
class NResponsiveBuilder extends StatelessWidget {
  /// Punto de quiebre (breakpoint) en píxeles.
  ///
  /// Si el ancho disponible (`maxWidth`) es menor a este valor,
  /// el layout se considera tipo móvil (vertical).
  /// Si es mayor o igual, se considera tipo desktop/tablet (horizontal).
  final double breakSize;

  /// Callback opcional que se ejecuta antes de renderizar el contenido.
  ///
  /// Usualmente utilizado para cargar datos asincrónicos.
  /// Está controlado por el widget `NAsyncLoader`.
  final Future<void> Function()? onLoading;

  /// Callback opcional que se ejecuta cuando finaliza `onLoading`.
  ///
  /// Permite reaccionar al término de la carga (ej: ocultar splash, logs, etc).
  final Function()? onFinished;

  /// Función opcional que define el padding dinámicamente según el tipo de pantalla.
  ///
  /// Recibe un `ScreenType` (mobile, tablet, desktop) y retorna un `EdgeInsetsGeometry`.
  /// Si no se define, se usa `EdgeInsets.zero`.
  final EdgeInsetsGeometry Function(ScreenType screenType)? padding;

  /// Widget opcional que se muestra mientras `onLoading` está en ejecución.
  ///
  /// Por defecto, `NAsyncLoader` puede usar un indicador interno si este no se proporciona.
  final Widget? indicator;

  /// Función principal que construye el UI.
  ///
  /// Parámetros:
  /// - `screenType`: Tipo de pantalla calculado (mobile, tablet, desktop).
  /// - `size`: Restricciones actuales del layout (`BoxConstraints`).
  /// - `axis`: Configuración de orientación (`AxisData`) que indica:
  ///     - eje principal (horizontal/vertical)
  ///     - eje secundario
  ///     - si debe expandirse (`expand`)
  ///
  /// Este builder es el núcleo del widget y permite construir layouts adaptativos.
  final Widget Function(
    ScreenType screenType,
    BoxConstraints size,
    AxisData axis,
  ) builder;

  const NResponsiveBuilder({
    required this.builder,
    this.padding,
    this.breakSize = 650,
    this.onLoading,
    this.onFinished,
    this.indicator,
    super.key,
  });

  @override
  Widget build(BuildContext context) =>
  /// El widget se envuelve en `NAsyncLoader` para manejar estados de carga asincrónica.
  NAsyncLoader(
    onLoading  : onLoading,
    onFinished : onFinished,
    indicator  : indicator,
    child :
    /// LayoutBuilder permite acceder a las restricciones actuales del contenedor
    /// para construir UI responsiva.
    LayoutBuilder (
      builder : ( context, size ) =>
      /// Se aplica padding dinámico basado en el tipo de pantalla.
      Padding(
        padding : padding == null ? .zero : padding!(size.getScreenType),
        child   :
        /// Se ejecuta el builder principal pasando:
        /// - tipo de pantalla
        /// - tamaño disponible
        /// - configuración de ejes calculada
        builder.call(
          size.getScreenType,
          size,
          /// Se construye la configuración de ejes en base al breakpoint:
          /// - Vertical si es menor al breakpoint (mobile)
          /// - Horizontal si es mayor o igual (desktop/tablet)
          AxisData(
            main   : size.maxWidth <  breakSize ? .vertical   : .horizontal,
            second : size.maxWidth <  breakSize ? .horizontal : .vertical,
            expand : size.maxWidth >= breakSize
          )
        )
      )
    )
  );
}


/// AxisData
///
/// Estructura de datos que define cómo se organiza el layout en términos de ejes.
///
/// Se utiliza para abstraer la orientación del diseño sin acoplar directamente
/// la lógica al uso de `Row` o `Column`.
///
/// Propiedades:
/// - `main`: eje principal del layout (Axis.horizontal o Axis.vertical).
/// - `second`: eje secundario (el opuesto al principal).
/// - `expand`: indica si el layout debe expandirse (típicamente en desktop).
///
/// Ejemplo:
/// - Mobile:
///     main   = Axis.vertical
///     second = Axis.horizontal
///     expand = false
///
/// - Desktop:
///     main   = Axis.horizontal
///     second = Axis.vertical
///     expand = true
class AxisData {
  /// Eje principal sobre el cual se organiza el contenido.
  ///
  /// Define si el layout fluye horizontalmente (`Row`) o verticalmente (`Column`).
  final Axis main;

  /// Eje secundario, opuesto al eje principal.
  ///
  /// Se usa para layouts compuestos o alineaciones cruzadas.
  final Axis second;

  /// Indica si el layout debe ocupar todo el espacio disponible.
  ///
  /// Comúnmente `true` en desktop para layouts expandibles,
  /// y `false` en mobile donde el contenido suele ser más compacto.
  final bool expand;

  const AxisData({
    required this.main,
    required this.second,
    required this.expand,
  });
}