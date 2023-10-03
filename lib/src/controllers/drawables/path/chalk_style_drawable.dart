import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';

/// Free-style Drawable (hand scribble).
class ChalkStyleDrawable extends PathDrawable {
  /// The color the path will be drawn with.
  final Color color;

  /// Creates a [ChalkStyleDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  ChalkStyleDrawable({
    required super.path,
    super.strokeWidth = 1,
    super.hidden = false,
    super.previousImage,
    super.lastDrawnPathIndex = 0,
    this.color = Colors.black,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  ChalkStyleDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    int? lastDrawnPathIndex,
    ui.Image? previousImage,
    Color? color,
    double? strokeWidth,
  }) {
    return ChalkStyleDrawable(
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
    ..color = Colors.black;

  @override
  void draw(Canvas canvas, Size size) {
    final rectMap = _generateRectList();
    for (int i = 1; i < path.length; i++) {
      final pathStart = path[i - 1];
      final clipRectList = rectMap[pathStart] ?? [Rect.zero];
      canvas.drawPoints(
        ui.PointMode.points,
        clipRectList.map((e) => e.center).toList(growable: false),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.square
          ..strokeJoin = StrokeJoin.miter
          ..color = Colors.black
          ..strokeWidth = 3.75 * (strokeWidth * 0.1),
      );
    }
  }

  Map<Offset, List<Rect>> _generateRectList() {
    Map<Offset, List<Rect>> rectMap = {};
    for (int i = 1; i < path.length; i++) {
      final pathStart = path[i - 1];
      final pathEnd = path[i];

      // Chalk effect
      final length = pathEnd - pathStart;
      final xUnit = (length.dx / length.distance);
      final yUnit = (length.dy / length.distance);

      List<Rect> clipList = [];
      for (int j = 0; j < length.distance; j++) {
        final random = Random();
        final xCurrent = pathStart.dx + (j * xUnit);
        final yCurrent = pathStart.dy + (j * yUnit);
        // from 2 to 25
        final xRandom = xCurrent + (random.nextDouble() - 0.5) * 5.0 * 1.2;
        final yRandom = yCurrent + (random.nextDouble() - 0.5) * 5.0 * 1.2;
        final rect = Rect.fromPoints(
          Offset(
            xRandom,
            yRandom,
          ),
          Offset(
            xRandom + (random.nextDouble() * strokeWidth + 2),
            yRandom + (random.nextDouble() * strokeWidth + 1),
          ),
        );
        clipList.add(rect);
      }
      rectMap[pathStart] = clipList;
    }
    return rectMap;
  }
}
