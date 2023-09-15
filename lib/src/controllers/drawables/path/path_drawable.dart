import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter_extensions.dart';
import 'package:flutter_painter/src/controllers/drawables/path/smooth_style_drawable.dart';

import '../drawable.dart';

/// Free-style Drawable (hand scribble).
abstract class PathDrawable extends Drawable {
  /// List of points representing the path to draw.
  final List<Offset> path;

  /// The stroke width the path will be drawn with.
  final double strokeWidth;

  /// Creates a [PathDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [strokeWidth] if provided.
  PathDrawable({
    required this.path,
    this.strokeWidth = 1,
    bool hidden = false,
  })  :
        // An empty path cannot be drawn, so it is an invalid argument.
        assert(path.isNotEmpty, 'The path cannot be an empty list'),

        // The line cannot have a non-positive stroke width.
        assert(strokeWidth > 0,
            'The stroke width cannot be less than or equal to 0'),
        super(hidden: hidden);

  /// Creates a copy of this but with the given fields replaced with the new values.
  PathDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    double? strokeWidth,
  });

  @protected
  Paint get paint;

  /// Draws the free-style [path] on the provided [canvas] of size [size].
  @override
  void draw(Canvas canvas, Size size) {
    // Draw the path on the canvas
    final currentDrawable = this;
    for (int i = 1; i < path.length; i++) {
      canvas.drawPath(
        Path()
          ..moveTo(path[i - 1].dx, path[i - 1].dy)
          ..lineTo(path[i].dx, path[i].dy),
        paint.copyWith(
          strokeWidth: currentDrawable is SmoothStyleDrawable
              ? currentDrawable.strokeWidthList[i]
              : strokeWidth,
          blendMode: BlendMode.src,
        ),
      );
    }
  }
}
