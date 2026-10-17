import 'package:flutter/material.dart';
import 'package:n_interface/n_interface.dart' show NText, ContextExtension;

class NSlider extends StatefulWidget {
  final num min;
  final num max;
  final num initialValue;
  final String title;
  final String indicator;
  final double? width;
  final bool enabled;
  final Function(int value) onChanged;

  const NSlider({
    super.key,
    this.min          = 0,
    this.max          = 100,
    int? initialValue,
    this.title        = "",
    this.indicator    = "",
    this.width,
    this.enabled      = true,
    required this.onChanged
  }) : initialValue = initialValue ?? min;

  @override
  State<NSlider> createState() => _NSliderState();
}

class _NSliderState extends State<NSlider> {
  late num _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) =>
  Container(
    width   : widget.width,
    padding : const .only(bottom: 10),
    child   :
    Column(
      spacing : 10,
      children: [
        Padding(
          padding : const .symmetric(horizontal: 8),
          child   :
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              NText(
                text    : widget.title
              ),
              if(widget.indicator.isNotEmpty)
              Flexible(
                child:
                NText(
                  color   : context.dividerColor,
                  text    : widget.indicator
                ),
              ),
            ]
          ),
        ),
        SliderTheme(
          data:
          SliderTheme.of(context).copyWith(
            activeTrackColor    : context.mainColor,
            inactiveTrackColor  : context.disabledColor,
            thumbColor          : context.mainColor,
            overlayShape        : .noOverlay,
            thumbShape          : const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child:
          Slider(
            value : _value.toDouble(),
            min   : widget.min.toDouble(),
            max   : widget.max.toDouble(),
            onChanged: widget.enabled
            ? (val) {
                setState(() => _value = val.toInt() );
                widget.onChanged.call(val.toInt());
              }
            : null,
          ),
        ),
      ],
    ),
  );
}
