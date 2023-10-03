import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';

/// Free-style Drawable (hand scribble).
abstract class PathDrawable extends Drawable {
  /// List of points representing the path to draw.
  final List<Offset> _path;

  /// The stroke width the path will be drawn with.
  final double strokeWidth;

  /// The previous image to be drawn on.
  ui.Image? previousImage;
  int lastDrawnPathIndex;

  /// Creates a [PathDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [strokeWidth] if provided.
  PathDrawable({
    required List<Offset> path,
    this.previousImage,
    this.lastDrawnPathIndex = 0,
    super.hidden = false,
    this.strokeWidth = 1,
  }) : _path = path;

  /// Creates a copy of this but with the given fields replaced with the new values.
  PathDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    ui.Image? previousImage,
    int? lastDrawnPathIndex,
    double? strokeWidth,
  });

  @protected
  Paint get paint;

  List<Offset> get path =>
      (lastDrawnPathIndex > 0 && _path.length > lastDrawnPathIndex)
          ? _path.sublist(lastDrawnPathIndex)
          : _path;

  (Canvas, ui.PictureRecorder) startDrawing(Canvas canvas, Size size) {
    final image = previousImage;
    final recorder = ui.PictureRecorder();
    final recordCanvas = Canvas(recorder, Offset.zero & size);
    if (image != null) {
      recordCanvas.drawImage(image, Offset.zero, Paint());
    }
    return (recordCanvas, recorder);
  }

  void endDrawing(Canvas canvas, Size size, ui.PictureRecorder recorder) {
    final image = previousImage;
    if (path.length > 1) {
      final picture = recorder.endRecording();
      final pathsImage =
          picture.toImageSync(size.width.toInt(), size.height.toInt());
      previousImage = pathsImage;
      canvas.drawImage(pathsImage, Offset.zero, Paint());
    } else {
      if (image != null) {
        canvas.drawImage(image, Offset.zero, Paint());
      }
    }
    lastDrawnPathIndex = _path.length - 1;
    print(lastDrawnPathIndex);
  }

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
