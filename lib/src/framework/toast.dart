import 'package:flutter/material.dart' show BuildContext, Colors, Curves, Overlay;
import 'package:flutter_styled_toast/flutter_styled_toast.dart' show showToast;

class NToast {
  static void show( BuildContext context, {
    required String  message,
    bool isValid = true,
    bool center  = false
  }) {
    if (!context.mounted) return;
    if (Overlay.maybeOf(context, rootOverlay: true) == null) return;

    try {
      showToast(
        message,
        context   : context,
        animation : center ? .fade : .slideFromBottom,
        reverseAnimation : center ? .fade : .slideToBottom,
        backgroundColor  : isValid ? Colors.green.withValues(alpha: 0.7) : Colors.red.withValues(alpha: 0.7),
        animDuration     : const Duration(seconds: 1),
        duration  : const Duration(seconds: 4),
        curve     : Curves.elasticOut,
        reverseCurve     : Curves.elasticIn,
        position  : center ? .center : .bottom,
      );
    } catch (_) {
      return;
    }
  }
}
