/// Extension on [num] with string conversion helpers.
extension NumExtension on num {
  /// Returns `null` when the value is `0`; otherwise returns its string representation.
  String? clearString() => this == 0 ? null : toString();
}