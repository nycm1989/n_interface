import 'package:flutter/material.dart' show BoxConstraints;
import 'package:n_interface/src/enums/screen_type.dart' show NScreenType;

/// Extension on [BoxConstraints] to determine the current [NScreenType]
/// based on the available maximum width.
extension NScreenTypeExtension on BoxConstraints{
  /// Returns the [NScreenType] that matches the current maximum width:
  /// mobile (≤ 600), tablet (601–1024), or desktop (> 1024).
  NScreenType get getNScreenType =>
  maxWidth <= 600                     ? .mobile  :
  maxWidth > 600 && maxWidth <= 1024  ? .tablet  :
  /* ----- Another screen size ----- */ .desktop;
}
