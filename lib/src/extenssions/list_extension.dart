/// Extension on [List] with convenience search and cleanup helpers.
extension ListExtension<E> on List<E> {
  /// Returns the first element that satisfies [test], or `null` if none match.
  E? singleWhereOrNull(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Removes all elements that are `null`, empty strings `""`, or empty lists `[]`,
  /// then returns the mutated list.
  List<E> removeEmpty() {
    removeWhere((e) => [null, "", []].contains(e));
    return this;
  }
}

/// Extension on [List] of numeric values with min/max helpers.
extension ListNumExtension<T extends num> on List<T> {
  /// Returns the smallest value in the list, or `0` when the list is empty.
  T get getMin => isEmpty ? (0 as T) : reduce((a, b) => a < b ? a : b);
  /// Returns the largest value in the list, or `0` when the list is empty.
  T get getMax => isEmpty ? (0 as T) : reduce((a, b) => a > b ? a : b);
}
