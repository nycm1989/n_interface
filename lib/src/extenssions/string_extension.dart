/// Extension on [String] with string conversion helpers.
extension StringExtension on String {
  /// Returns `null` when the string is `"0"`, `"0.00"`, or empty;
  /// otherwise returns the string itself.
  String? clearString() => this == "0" ||this == "0.00" || this == "" ? null : toString();
}