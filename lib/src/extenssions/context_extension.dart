import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

/// Extension on [BuildContext] that exposes commonly used layout values
/// and theme colors as convenient shorthand getters.
extension ContextExtension on BuildContext{

  /// Top padding consumed by the system UI (status bar, notch, etc.).
  double get topSize => MediaQuery.of(this).padding.top;

  /// Extra top inset required on macOS when the window uses full-size content
  /// view: reserves space for the traffic-light buttons drawn over the content.
  /// Returns 28 on macOS and 0 on every other platform.
  double get trafficLightTopInset => defaultTargetPlatform == TargetPlatform.macOS ? 28 : 0;

  /// Bottom padding consumed by the system UI (home indicator, navigation bar).
  double get bottomSize => MediaQuery.of(this).padding.bottom;

  /// Pops the current route if the navigator can go back.
  void pop() {
    if(Navigator.canPop(this)) Navigator.of(this).pop();
  }

  /// Scaffold background color from the current theme.
  Color get primaryColor      => Theme.of(this).scaffoldBackgroundColor;
  /// Divider color from the current theme.
  Color get dividerColor      => Theme.of(this).dividerColor;
  /// Main divider color mapped to [ColorScheme.tertiaryFixed].
  Color get mainDividerColor  => Theme.of(this).colorScheme.tertiaryFixed;
  /// Default text color mapped to [ColorScheme.onSurface].
  Color get textColor         => Theme.of(this).colorScheme.onSurface;
  /// Bold/emphasized text color mapped to [ColorScheme.onTertiary].
  Color get textBoldColor     => Theme.of(this).colorScheme.onTertiary;
  /// Muted text color mapped to [ColorScheme.onSurfaceVariant].
  Color get textMutedColor    => Theme.of(this).colorScheme.onSurfaceVariant;
  /// Faint/hint text color mapped to [ColorScheme.outline].
  Color get textFaintColor    => Theme.of(this).colorScheme.outline;
  /// Primary brand color mapped to [ColorScheme.primary].
  Color get mainColor         => Theme.of(this).colorScheme.primary;
  /// Soft variant of the primary color mapped to [ColorScheme.primaryContainer].
  Color get mainSoftColor     => Theme.of(this).colorScheme.primaryContainer;
  /// Success state color mapped to [ColorScheme.secondaryFixed].
  Color get successColor      => Theme.of(this).colorScheme.secondaryFixed;
  /// Warning state color (amber 600).
  Color get warningColor      => Colors.amber.shade600;
  /// Error state color (red 600).
  Color get errorColor        => Colors.red.shade600;
  /// Danger/critical color mapped to [ColorScheme.error].
  Color get dangerColor       => Theme.of(this).colorScheme.error;
  /// Border color mapped to [ColorScheme.onPrimaryFixed].
  Color get borderColor       => Theme.of(this).colorScheme.onPrimaryFixed;
  /// Card surface color mapped to [ColorScheme.tertiary].
  Color get cardColor         => Theme.of(this).colorScheme.tertiary;
  /// Background color mapped to [ThemeData.cardColor].
  Color get backgroundColor   => Theme.of(this).cardColor;
  /// Disabled element color from the current theme.
  Color get disabledColor     => Theme.of(this).disabledColor;
  /// Hover/over state color mapped to [ColorScheme.onPrimaryFixedVariant].
  Color get overedColor       => Theme.of(this).colorScheme.onPrimaryFixedVariant;
  /// Grey card surface color mapped to [ColorScheme.onPrimaryFixedVariant].
  Color get greyCard          => Theme.of(this).colorScheme.onPrimaryFixedVariant;
}
