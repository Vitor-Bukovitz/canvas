import 'dart:ui';

import 'package:flutter_painter/flutter_painter.dart';

abstract class PathImageDrawable extends PathDrawable {
  final Image image;
  final List<double> rotations;

  PathImageDrawable({
    required this.image,
    required super.path,
    required this.rotations,
    super.strokeWidth = 1,
    bool hidden = false,
  })  :
        // An empty path cannot be drawn, so it is an invalid argument.
        assert(path.isNotEmpty, 'The path cannot be an empty list'),

        // The line cannot have a non-positive stroke width.
        assert(strokeWidth > 0,
            'The stroke width cannot be less than or equal to 0'),
        super(hidden: hidden);

  @override
  PathDrawable copyWith({
    Image? image,
    bool? hidden,
    List<Offset>? path,
    List<double>? rotations,
    double? strokeWidth,
  });

  @override
  void draw(Canvas canvas, Size size) {
    // Draw image rotate to match the next path segment.
    final currentDrawable = this;
    for (int i = 1; i < path.length; i++) {
      final origin = Offset(path[i - 1].dx, path[i - 1].dy);
      final rotation = rotations[i - 1];
      const offset = Offset(-10, -10);
      canvas.save();
      canvas.translate(origin.dx, origin.dy);
      canvas.rotate(rotation);
      canvas.drawImage(
        currentDrawable.image,
        offset,
        Paint(),
      );
      canvas.restore();
    }
  }
}
