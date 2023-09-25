import 'package:flutter/material.dart';

import 'path_drawable.dart';

/// Free-style Drawable (hand scribble).
class SmoothStyleDrawable extends PathDrawable {
  /// The color the path will be drawn with.
  final Color color;

  /// The stroke width the path will be drawn with.
  late List<double> strokeWidthList;

  /// Creates a [SmoothStyleDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  SmoothStyleDrawable({
    required List<Offset> path,
    double strokeWidth = 1,
    this.color = Colors.black,
    bool hidden = false,
  })  :
        // An empty path cannot be drawn, so it is an invalid argument.
        assert(path.isNotEmpty, 'The path cannot be an empty list'),

        // The line cannot have a non-positive stroke width.
        assert(strokeWidth > 0,
            'The stroke width cannot be less than or equal to 0'),
        super(path: path, strokeWidth: strokeWidth, hidden: hidden) {
    strokeWidthList = _generateStrokeWidthList();
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  SmoothStyleDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    Color? color,
    double? strokeWidth,
  }) {
    return SmoothStyleDrawable(
      path: path ?? this.path,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      hidden: hidden ?? this.hidden,
    );
  }

  @protected
  @override
  Paint get paint => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color
    ..strokeWidth = strokeWidth;

  List<double> _generateStrokeWidthList() {
    final List<double> strokeWidthList = [strokeWidth];
    for (int i = 1; i < path.length; i++) {
      final double distance = (path[i] - path[i - 1]).distance;
      final double lastStrokeWidth = strokeWidthList.length > i - 1
          ? strokeWidthList[i - 1]
          : this.strokeWidth;
      double strokeWidth = lastStrokeWidth;
      if (distance > 5 * lastStrokeWidth) {
        strokeWidth = lastStrokeWidth * 1.5;
      } else if (distance < 0.5 * lastStrokeWidth) {
        strokeWidth = lastStrokeWidth * 0.5;
      }
      strokeWidth = strokeWidth.clamp(strokeWidth / 2, strokeWidth * 3);
      strokeWidthList.add(strokeWidth);
    }
    return strokeWidthList;
  }
}
