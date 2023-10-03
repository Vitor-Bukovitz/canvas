import 'package:flutter/material.dart';
import 'path_drawable.dart';
import 'dart:ui' as ui;

/// Free-style Erase Drawable .
class EraseDrawable extends PathDrawable {
  /// Creates a [EraseDrawable] to erase [path].
  ///
  /// The path will be erased with the passed [strokeWidth] if provided.
  EraseDrawable({
    required super.path,
    super.strokeWidth = 1,
    super.lastDrawnPathIndex = 0,
    super.previousImage,
    super.hidden = false,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  EraseDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    int? lastDrawnPathIndex,
    ui.Image? previousImage,
    double? strokeWidth,
  }) {
    return EraseDrawable(
      path: path ?? this.path,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      lastDrawnPathIndex: lastDrawnPathIndex ?? this.lastDrawnPathIndex,
      previousImage: previousImage ?? this.previousImage,
      hidden: hidden ?? this.hidden,
    );
  }

  @protected
  @override
  Paint get paint => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..blendMode = BlendMode.clear
    ..strokeWidth = strokeWidth;

  /// Compares two [EraseDrawable]s for equality.
  // @override
  // bool operator ==(Object other) {
  //   return other is EraseDrawable &&
  //       super == other &&
  //       other.strokeWidth == strokeWidth &&
  //       ListEquality().equals(other.path, path);
  // }

  // @override
  // int get hashCode => hashValues(hidden, hashList(path), strokeWidth);
}
