/// Extension on `Map<String, dynamic>` with cleanup helpers.
extension MapDynamicExtension on Map<String, dynamic> {
  /// Removes entries whose value is `null`, an empty string, an empty collection,
  /// or one of the reserved audit keys (`"created_by"`, `"created_at"`).
  /// Returns the mutated map.
  Map<String, dynamic> clearEmpty() {
    removeWhere((key, value) =>
      value == null ||
      value == "" ||
      (value is List && value.isEmpty) ||
      (value is Map && value.isEmpty) ||
      (value is String && value == "created_by") ||
      (value is String && value == "created_at")
    );
    return this;
  }
}

/// Extension on `Map<String, String>` with cleanup helpers.
extension MapStringExtension on Map<String, String> {
  /// Removes entries whose value is an empty string or an empty collection.
  /// Returns the mutated map.
  Map<String, String> clearEmpty() {
    removeWhere((key, value) =>
      value == "" ||
      (value is List && value.isEmpty) ||
      (value is Map && value.isEmpty)
    );
    return this;
  }
}