import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/drawables/path/path_drawable.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'package:flutter_painter/src/controllers/drawables/path/path_image_drawable.dart';

/// Free-style Drawable (hand scribble).
class SprayStyleDrawable extends PathImageDrawable {
  /// Creates a [SprayStyleDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  SprayStyleDrawable({
    required super.path,
    super.image,
    super.strokeWidth = 1,
    super.hidden = false,
    super.color,
    super.lastDrawnPathIndex = 0,
    super.previousImage,
    List<double>? rotations,
  }) : super(
          imagePath: PathImage.spray,
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
    ui.Image? previousImage,
    int? lastDrawnPathIndex,
    double? strokeWidth,
  }) {
    return SprayStyleDrawable(
      image: image ?? this.image,
      path: path ?? this.path,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      previousImage: previousImage ?? this.previousImage,
      lastDrawnPathIndex: lastDrawnPathIndex ?? this.lastDrawnPathIndex,
      rotations: rotations ?? this.rotations,
      hidden: hidden ?? this.hidden,
    );
  }

  @protected
  @override
  Paint get paint => Paint()..color = color;
}
