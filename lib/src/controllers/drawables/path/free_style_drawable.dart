import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'path_drawable.dart';

/// Free-style Drawable (hand scribble).
class FreeStyleDrawable extends PathDrawable {
  /// The color the path will be drawn with.
  final Color color;

  /// Creates a [FreeStyleDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  FreeStyleDrawable({
    required super.path,
    super.strokeWidth = 1,
    super.hidden = false,
    super.lastDrawnPathIndex = 0,
    super.previousImage,
    this.color = Colors.black,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  FreeStyleDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    ui.Image? previousImage,
    int? lastDrawnPathIndex,
    Color? color,
    double? strokeWidth,
  }) {
    return FreeStyleDrawable(
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
}
