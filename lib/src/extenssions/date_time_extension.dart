import 'dart:ui';

import 'package:intl/intl.dart';

/// Device locale language code, resolved without depending on any state-management package.
class _DeviceLocale {
  static String get languageCode => PlatformDispatcher.instance.locale.languageCode;
}

/// Extension on [DateTime] that adds formatting helpers and comparison utilities.
extension DateTimeExtension on DateTime {
  /// Returns `true` when [dateTime] or the date parsed from [json] is before
  /// or at the same moment as this instance (converted to local time).
  bool isEarlier({DateTime? dateTime, String? json}) {
    final DateTime now = toLocal();

    if(dateTime != null) return dateTime.isBefore(now) || dateTime.isAtSameMomentAs(now);

    if (json != null){
      DateTime? dt = .tryParse(json);
      if (dt != null) return dt.isBefore(now) || dt.isAtSameMomentAs(now);
    }

    return false;
  }

  /// Returns `true` when [dateTime] falls on the same calendar day as this instance.
  bool isToday({required DateTime dateTime}) {
    final DateTime now = toLocal();
    return dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day;
  }

  /// Date formatted as `dd/MM/yyyy` (e.g. `30/05/1989`).
  String get format => DateFormat("dd/MM/yyyy").format(toLocal());

  /// Date formatted as ISO 8601 calendar date `yyyy-MM-dd` (no time component),
  /// suitable for query strings and filter values.
  String get iso8601CalendarDate => DateFormat('yyyy-MM-dd').format(toLocal());

  /// Date and time formatted as `dd/MM/yyyy HH:mm` (e.g. `30/05/1989 15:30`).
  String get formatWithTime => DateFormat("dd/MM/yyyy HH:mm").format(toLocal());

  /// Full weekday + date + month + year in the device locale,
  /// e.g. `"Monday 30 de May 1989"`, with the weekday and month capitalized.
  String get eeeeddMMMMyyyy {
    final String date = DateFormat("EEEE dd 'de' MMMM yyyy", _DeviceLocale.languageCode).format(toLocal());
    final List<String>list = date.split(" ");
    list[0] = list[0][0].toUpperCase() + list[0].substring(1);
    list[3] = list[3][0].toUpperCase() + list[3].substring(1);
    return list.join(" ");
  }

  /// Full weekday + day + month in the device locale,
  /// e.g. `"Monday, 30 de May"`, with the weekday and month capitalized.
  String get eeeeddMMMM {
    final String date = DateFormat("EEEE, dd 'de' MMMM", _DeviceLocale.languageCode).format(toLocal());
    final List<String>list = date.split(" ");
    list[0] = list[0][0].toUpperCase() + list[0].substring(1);
    list[3] = list[3][0].toUpperCase() + list[3].substring(1);
    return list.join(" ");
  }

  /// Full month name + year in the device locale, with the month capitalized,
  /// e.g. `"May 1989"`.
  String get mMMMyyyy {
    final String date = DateFormat("MMMM yyyy", _DeviceLocale.languageCode).format(toLocal());
    final List<String>list = date.split(" ");
    list[0] = list[0][0].toUpperCase() + list[0].substring(1);
    return list.join(" ");
  }

  /// Zero-padded day of the month, e.g. `"05"`.
  String get dd => DateFormat("dd").format(toLocal());

  /// Abbreviated weekday name capitalized in the device locale, e.g. `"Mon"`.
  String get eEE {
    final String day = DateFormat("EEE", _DeviceLocale.languageCode).format(toLocal());
    return day[0].toUpperCase() + day.substring(1);
  }

  /// Day number followed by abbreviated weekday in the device locale,
  /// e.g. `"30 Mon"`.
  String get ddEEE {
    final String date = DateFormat("dd EEE", _DeviceLocale.languageCode).format(toLocal());
    final List<String>list = date.split(" ");
    list[1] = list[1][0].toUpperCase() + list[1].substring(1);
    return "${list[0]} ${list[1]}";
  }

  /// Time formatted as 12-hour `hh:mm`, e.g. `"03:45"`.
  String get hhMM  => DateFormat("hh:mm").format(toLocal());

  /// Time formatted as 24-hour `HH:mm`, e.g. `"15:45"`.
  String get hHmm  => DateFormat("HH:mm").format(toLocal());

  /// Full month name capitalized in the device locale, e.g. `"May"`.
  String get mMMM {
    final String m = DateFormat("MMMM", _DeviceLocale.languageCode).format(toLocal());
    return m[0].toUpperCase() + m.substring(1);
  }

  /// Full weekday name capitalized in the device locale, e.g. `"Monday"`.
  String get eeee {
    final String d = DateFormat("EEEE", _DeviceLocale.languageCode).format(toLocal());
    return d[0].toUpperCase() + d.substring(1);
  }

  /// Attempts to parse [value] as a `dd/MM/yyyy` date; returns `null` on failure.
  DateTime? paseOrNull(dynamic value) => DateFormat("dd/MM/yyyy").tryParse(value.toString());
}