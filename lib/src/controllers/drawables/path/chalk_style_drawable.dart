import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';

/// Free-style Drawable (hand scribble).
class ChalkStyleDrawable extends PathDrawable {
  /// The color the path will be drawn with.
  final Color color;

  /// The previous image to be drawn on.
  ui.Image? previousImage;
  int lastDrawnPathIndex = 0;

  /// Creates a [ChalkStyleDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  ChalkStyleDrawable({
    required List<Offset> path,
    this.previousImage,
    this.lastDrawnPathIndex = 0,
    Map<Offset, List<Rect>>? rectMap,
    double strokeWidth = 1,
    this.color = Colors.black,
    bool hidden = false,
  })  :
        // An empty path cannot be drawn, so it is an invalid argument.
        assert(path.isNotEmpty, 'The path cannot be an empty list'),

        // The line cannot have a non-positive stroke width.
        assert(strokeWidth > 0,
            'The stroke width cannot be less than or equal to 0'),
        super(path: path, strokeWidth: strokeWidth, hidden: hidden);

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  ChalkStyleDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    ui.Image? previousImage,
    int? lastDrawnPathIndex,
    Color? color,
    double? strokeWidth,
  }) {
    return ChalkStyleDrawable(
      path: path ?? this.path,
      previousImage: previousImage ?? this.previousImage,
      lastDrawnPathIndex: lastDrawnPathIndex ?? this.lastDrawnPathIndex,
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
    ..color = Colors.black
    ..strokeWidth = strokeWidth;

  @override
  void draw(Canvas canvas, Size size) {
    final image = previousImage;
    final pathList = path.sublist(lastDrawnPathIndex);
    if (pathList.length > 1) {
      final recorder = ui.PictureRecorder();
      final recordCanvas = Canvas(recorder, Offset.zero & size);
      final rectMap = _generateRectList();
      if (image != null) {
        recordCanvas.drawImage(image, Offset.zero, Paint());
      }
      for (int i = 1; i < pathList.length; i++) {
        final pathStart = pathList[i - 1];
        final clipRectList = rectMap[pathStart] ?? [Rect.zero];
        recordCanvas.drawPoints(
          ui.PointMode.points,
          clipRectList.map((e) => e.center).toList(growable: false),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.square
            ..strokeJoin = StrokeJoin.miter
            ..color = Colors.black
            ..strokeWidth = strokeWidth,
        );
      }
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
    lastDrawnPathIndex = path.length - 1;
  }

  Map<Offset, List<Rect>> _generateRectList() {
    Map<Offset, List<Rect>> rectMap = {};
    for (int i = 1; i < path.length; i++) {
      final pathStart = path[i - 1];
      final pathEnd = path[i];
      if (rectMap[pathStart] == null) {
        // Chalk effect
        final length = pathEnd - pathStart;
        final xUnit = length.dx / length.distance;
        final yUnit = length.dy / length.distance;

        List<Rect> clipList = [];
        for (int j = 0; j < length.distance; j++) {
          final random = Random();
          final xCurrent = pathStart.dx + (j * xUnit);
          final yCurrent = pathStart.dy + (j * yUnit);
          final xRandom = xCurrent + (random.nextDouble() - 0.5) * 5.0 * 1.2;
          final yRandom = yCurrent + (random.nextDouble() - 0.5) * 5.0 * 1.2;
          final rect = Rect.fromPoints(
            Offset(xRandom, yRandom),
            Offset(
              xRandom + (random.nextDouble() * 2 + 2),
              yRandom + (random.nextDouble() + 1),
            ),
          );
          clipList.add(rect);
        }
        rectMap[pathStart] = clipList;
      }
    }
    return rectMap;
  }
}
