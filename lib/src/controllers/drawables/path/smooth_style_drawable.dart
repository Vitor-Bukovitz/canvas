import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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
    required super.path,
    super.strokeWidth = 1,
    super.hidden = false,
    super.lastDrawnPathIndex = 0,
    super.previousImage,
    this.color = Colors.black,
  }) {
    strokeWidthList = _generateStrokeWidthList();
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  SmoothStyleDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    int? lastDrawnPathIndex,
    ui.Image? previousImage,
    Color? color,
    double? strokeWidth,
  }) {
    return SmoothStyleDrawable(
      path: path ?? this.path,
      color: color ?? this.color,
      previousImage: previousImage ?? this.previousImage,
      lastDrawnPathIndex: lastDrawnPathIndex ?? this.lastDrawnPathIndex,
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
