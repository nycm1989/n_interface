// dart
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Zona horaria de trabajo de toda la app: `America/Lima` (UTC−5, sin
/// horario de verano desde 1993).
///
/// El backend resuelve la zona una sola vez (`TIMEZONE` del `.env`, hoy
/// `America/Lima`) y de este lado hacemos lo mismo: un `DateTime` **naive**
/// (sin zona) dentro de la app siempre significa "reloj de pared de Lima", o
/// una fecha de calendario (sin hora), que nunca se convierte. Los instantes
/// absolutos sólo existen en la frontera con la API: al enviar como `Z`
/// (`toApiIso`) y al recibir con offset (`parseApiDateTime`).
const Duration _appUtcOffset = Duration(hours: -5);

/// Locale del dispositivo (p. ej. `en`, `es`) para formatear fechas: forma
/// nativa de Flutter, sin GetX. Reemplaza a `Get.locale?.languageCode`.
String get _languageCode {
  final String code =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return code.isEmpty ? 'en' : code;
}

/// `DateTime` naive con los campos de [dt] ya en hora de Lima.
/// Conversión interna de presentación: no consulta la zona del dispositivo.
DateTime _naive(DateTime dt) => DateTime(
  dt.year,
  dt.month,
  dt.day,
  dt.hour,
  dt.minute,
  dt.second,
  dt.millisecond,
  dt.microsecond,
);

/// "Ahora" en hora de Perú, sin zona: reemplaza a `DateTime.now()` en toda la
/// app para que "hoy", los filtros, los vencimientos y las fechas por
/// defecto no dependan de la zona del dispositivo.
///
/// Excepción: para marcas de unicidad (`millisecondsSinceEpoch`,
/// `microsecondsSinceEpoch`, tags de widgets) sigue siendo válido
/// `DateTime.now()` — son instantes y la zona no cambia el valor.
DateTime nowApp() => _naive(DateTime.now().toUtc().add(_appUtcOffset));


/// Entrada desde el back: devuelve siempre la hora de Perú, sin zona.
///
/// El back resuelve la zona una sola vez (`TIMEZONE` del `.env`, hoy
/// `America/Lima`) y entrega los instantes con su offset explícito, p. ej.
/// `2026-08-07T13:48:32-05:00` (o `…Z`, el mismo instante en UTC).
/// `DateTime.parse` normaliza ambos a UTC, y si se formateara con `toLocal()`
/// la hora terminaría dependiendo de la zona del dispositivo: dos usuarios
/// verían horas distintas para el mismo registro.
///
/// Por eso se convierte el instante al reloj de pared de Lima y se devuelve
/// naive: los formateadores (`toApp()`) lo dejan tal cual, así que la hora
/// mostrada es siempre la operacional y los formatos existentes siguen
/// funcionando sin cambios. Un string **sin** zona se toma tal cual (se asume
/// que el back ya mandó hora de Lima).
///
/// Para comparar contra `nowApp()` también funciona: los dos son naive-Lima.
// DateTime? parseApiDateTime(String? iso) {
//   final String? s = iso?.trim();
//   if (s == null || s.isEmpty) return null;
//   final DateTime? parsed = DateTime.tryParse(s);
//   if (parsed == null) return null;
//   return parsed.isUtc ? _naive(parsed.add(_appUtcOffset)) : parsed;
// }

extension DateTimeExtension on DateTime {
  /// Convierte a reloj de pared de Lima, sin zona: un instante `Z`/offset
  /// pasa a hora de Perú; un `DateTime` naive ya representa hora de Lima (o
  /// una fecha de calendario) y no se toca. Sustituye a `toLocal()` en toda
  /// la app: el resultado no depende de la zona del dispositivo.
  DateTime toApp() => isUtc ? _naive(add(_appUtcOffset)) : this;

  bool isEarlier({DateTime? dateTime, String? json}) {
    final now = toApp();

    if(dateTime != null) return dateTime.isBefore(now) || dateTime.isAtSameMomentAs(now);

    if (json != null){
      DateTime? dt  = .tryParse(json);
      if (dt != null) return dt.isBefore(now) || dt.isAtSameMomentAs(now);
    }

    return false;
  }

  bool isToday({required DateTime dateTime}) {
    final now = toApp();
    return dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day;
  }

  // Retorna una fecha formateada en la forma: 30/05/1989
  String get format => DateFormat("dd/MM/yyyy").format(toApp());

  /// ISO 8601 solo fecha (`yyyy-MM-dd`), p. ej. query strings y valores de filtro (sin hora).
  String get iso8601CalendarDate => DateFormat('yyyy-MM-dd').format(toApp());

  // Retorna una fecha formateada en la forma: 30/05/1989 15:30
  String get formatWithTime => DateFormat("dd/MM/yyyy HH:mm").format(toApp());

  /// Hora fon formato local
  String get toIso8601WithOffset => DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSxxx").format(this);

  /// Fecha larga localizada ("15 de julio de 2026" / "July 15, 2026"): cabecera de
  /// los grupos por día del timeline de precios.
  String get longDate => DateFormat.yMMMMd(_languageCode).format(toApp());

  String get eeeeddMMMMyyyy {
    final String date = DateFormat("EEEE dd 'de' MMMM yyyy", _languageCode).format(toApp());
    final List<String>list = date.split(" ");
    list[0] = list[0][0].toUpperCase() + list[0].substring(1);
    list[3] = list[3][0].toUpperCase() + list[3].substring(1);
    return list.join(" ");
  }

  String get eeeeddMMMM {
    final String date = DateFormat("EEEE, dd 'de' MMMM", _languageCode).format(toApp());
    final List<String>list = date.split(" ");
    list[0] = list[0][0].toUpperCase() + list[0].substring(1);
    list[3] = list[3][0].toUpperCase() + list[3].substring(1);
    return list.join(" ");
  }

  String get mMMMyyyy {
    final String date = DateFormat("MMMM yyyy", _languageCode).format(toApp());
    final List<String>list = date.split(" ");
    list[0] = list[0][0].toUpperCase() + list[0].substring(1);
    return list.join(" ");
  }

  String get dd => DateFormat("dd").format(toApp());

  String get eEE {
    final String day = DateFormat("EEE", _languageCode).format(toApp());
    return day[0].toUpperCase() + day.substring(1);
  }

  String get ddEEE {
    final String date = DateFormat("dd EEE", _languageCode).format(toApp());
    final List<String>list = date.split(" ");
    list[1] = list[1][0].toUpperCase() + list[1].substring(1);
    return "${list[0]} ${list[1]}";
  }

  String get hhMM  => DateFormat("hh:mm").format(toApp());
  String get hhMMss  => DateFormat("hh:mm:ss").format(toApp());
  String get hHmm  => DateFormat("HH:mm").format(toApp());
  String get hHmmss  => DateFormat("HH:mm:ss").format(toApp());

  String get mMMM {
    final m = DateFormat("MMMM", _languageCode).format(toApp());
    return m[0].toUpperCase() + m.substring(1);
  }

  String get eeee {
    final d = DateFormat("EEEE", _languageCode).format(toApp());
    return d[0].toUpperCase() + d.substring(1);
  }

  DateTime? paseOrNull(dynamic value) => DateFormat("dd/MM/yyyy").tryParse(value.toString());
}