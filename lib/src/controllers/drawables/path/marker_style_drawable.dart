import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/drawables/path/path_drawable.dart';
import 'package:flutter_painter/src/controllers/drawables/path/path_image_drawable.dart';
import 'dart:ui' as ui;

/// Free-style Drawable (hand scribble).
class MarkerStyleDrawable extends PathImageDrawable {
  /// Creates a [MarkerStyleDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  MarkerStyleDrawable({
    required super.path,
    List<double>? rotations,
    super.image,
    super.strokeWidth = 1,
    super.hidden = false,
    super.color,
    super.lastDrawnPathIndex = 0,
    super.previousImage,
  }) : super(
          imagePath: PathImage.marker,
          rotations: [
            ...?rotations,
            0,
          ],
        );

  @override
  PathDrawable copyWith({
    ui.Image? image,
    bool? hidden,
    List<Offset>? path,
    ui.Image? previousImage,
    int? lastDrawnPathIndex,
    Color? color,
    List<double>? rotations,
    double? strokeWidth,
  }) {
    return MarkerStyleDrawable(
      image: image ?? this.image,
      path: path ?? this.path,
      color: color ?? this.color,
      previousImage: previousImage ?? this.previousImage,
      lastDrawnPathIndex: lastDrawnPathIndex ?? this.lastDrawnPathIndex,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      rotations: rotations ?? this.rotations,
      hidden: hidden ?? this.hidden,
    );
  }

  @protected
  @override
  Paint get paint => Paint()..color = color;
}
