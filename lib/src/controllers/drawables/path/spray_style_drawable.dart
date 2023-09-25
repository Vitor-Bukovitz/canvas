import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/drawables/path/path_drawable.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'package:flutter_painter/src/controllers/drawables/path/path_image_drawable.dart';
import 'dart:ui' as ui;

/// Free-style Drawable (hand scribble).
class SprayStyleDrawable extends PathImageDrawable {
  /// The color the path will be drawn with.
  final Color color;

  /// Creates a [SprayStyleDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  SprayStyleDrawable({
    required super.path,
    required super.image,
    List<double>? rotations,
    double strokeWidth = 1,
    this.color = Colors.black,
    bool hidden = false,
  }) : super(
          rotations: [
            ...?rotations,
            vector_math.radians(Random().nextDouble() * 360),
          ],
        );

  @override
  PathDrawable copyWith({
    ui.Image? image,
    bool? hidden,
    List<Offset>? path,
    Color? color,
    List<double>? rotations,
    double? strokeWidth,
  }) {
    return SprayStyleDrawable(
      image: image ?? super.image,
      path: path ?? this.path,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      rotations: rotations ?? this.rotations,
      hidden: hidden ?? this.hidden,
    );
  }

  @protected
  @override
  Paint get paint => Paint()..color = color;
}
