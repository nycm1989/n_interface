/// Extension on [Duration] that adds formatting and parsing helpers.
extension DurationExtension on Duration {
  /// Returns the duration as a zero-padded `HH:mm` string, e.g. `"02:05"`.
  String get format {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String hours = twoDigits(inHours);
    String minutes = twoDigits(inMinutes.remainder(60));

    return "$hours:$minutes";
  }

  /// Attempts to parse [value] as an `HH:mm` string and returns the resulting
  /// [Duration]. Returns `this` unchanged if parsing fails.
  Duration parseOrNull(dynamic value) {
    try {
      final parts = value.split(":");
      if (parts.length >= 2) {
        return Duration(
          hours   : .parse(parts[0]),
          minutes : .parse(parts[1]),
        );
      }
    } catch (_) {}

    return this;
  }
}