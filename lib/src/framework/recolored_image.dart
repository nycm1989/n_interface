import 'package:flutter/material.dart';
import 'package:n_interface/n_interface.dart' show NErrorHandler;

class NRecoloredImage extends StatelessWidget {
  final String    asset;
  final Color?    color;
  final BlendMode blendMode;
  final double?   width;
  final double?   height;

  const NRecoloredImage({
    super.key,
    required this.asset,
    required this.color,
    this.blendMode = .srcATop,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) =>
  NErrorHandler(builder: (context) =>
    color != null
    ? ColorFiltered(
      colorFilter : .mode(color!, blendMode),
      child       :
      Image.asset(
        asset,
        width : width,
        height: height,
      ),
    )
    : Image.asset(
      asset,
      width : width,
      height: height,
    )
  );
}