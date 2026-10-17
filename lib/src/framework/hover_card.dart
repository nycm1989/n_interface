import 'dart:async' show Timer;

import 'package:flutter/gestures.dart' show PointerEnterEvent, PointerExitEvent;
import 'package:flutter/material.dart';
import 'package:n_interface/n_interface.dart' show ContextExtension;

class NHoverCard extends StatefulWidget {
  final Widget child;
  final WidgetBuilder? contentBuilder;
  final VoidCallback? onTap;
  final Offset offset;

  const NHoverCard({
    super.key,
    required this.child,
    this.contentBuilder,
    this.onTap,
    this.offset = const Offset(0, -6),
  });

  @override
  State<NHoverCard> createState() => _NHoverCardState();
}

class _NHoverCardState extends State<NHoverCard> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _layerLink             = LayerLink();

  Timer? _hideTimer;
  bool _overTarget = false;
  bool _overCard   = false;

  void _show(PointerEnterEvent event) {
    _overTarget = true;
    _hideTimer?.cancel();
    if (widget.contentBuilder != null) _portal.show();
  }

  void _leaveTarget(PointerExitEvent event) {
    _overTarget = false;
    _scheduleHide();
  }

  void _enterCard(PointerEnterEvent event) {
    _overCard = true;
    _hideTimer?.cancel();
  }

  void _leaveCard(PointerExitEvent event) {
    _overCard = false;
    _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 90), () {
      if (!_overTarget && !_overCard) _portal.hide();
    });
  }

  void _onTap() {
    _portal.hide();
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
  OverlayPortal(
    controller: _portal,
    overlayChildBuilder: (overlayContext) =>
    Positioned(
      width: 240,
      child:
      CompositedTransformFollower(
        link            : _layerLink,
        showWhenUnlinked: false,
        targetAnchor    : Alignment.topCenter,
        followerAnchor  : Alignment.bottomCenter,
        offset          : widget.offset,
        child: MouseRegion(
          onEnter: _enterCard,
          onExit : _leaveCard,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 220),
              padding    : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color       : overlayContext.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border      : Border.all(color: overlayContext.dividerColor),
                boxShadow   : [
                  BoxShadow(
                    color     : Colors.black.withValues(alpha: 0.16),
                    blurRadius: 8,
                    offset    : const Offset(0, 3),
                  ),
                ],
              ),
              child: widget.contentBuilder?.call(overlayContext) ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    ),
    child: CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor : widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
        onEnter: _show,
        onExit : _leaveTarget,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap   : widget.onTap == null ? null : _onTap,
          child   : widget.child,
        ),
      ),
    ),
  );
}
