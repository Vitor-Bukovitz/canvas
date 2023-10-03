import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_svg/svg.dart';

enum PathImage {
  spray('assets/spray.svg'),
  marker('assets/marker.svg');

  const PathImage(this.path);

  final String path;
}

abstract class PathImageDrawable extends PathDrawable {
  final PathImage imagePath;
  final Color color;
  final List<double> rotations;

  ui.Image? image;

  PathImageDrawable({
    required super.path,
    required this.imagePath,
    required this.rotations,
    super.strokeWidth = 1,
    super.hidden = false,
    super.previousImage,
    super.lastDrawnPathIndex = 0,
    this.color = Colors.black,
    ui.Image? image,
  }) {
    if (image != null) {
      this.image = image;
    } else {
      _loadImage();
    }
  }

  @override
  PathDrawable copyWith({
    ui.Image? image,
    bool? hidden,
    List<Offset>? path,
    ui.Image? previousImage,
    int? lastDrawnPathIndex,
    List<double>? rotations,
    double? strokeWidth,
  });

  @override
  void draw(Canvas canvas, Size size) {
    final image = this.image;
    if (image == null) return;
    final newCanvas = super.startDrawing(canvas, size);
    print(path.length);
    // Draw image rotate to match the next path segment.
    for (int i = 1; i < path.length; i++) {
      // Calculate the unit vector of the path segment.
      final length = (path[i] - path[i - 1]);
      final xUnit = (length.dx / length.distance);
      final yUnit = (length.dy / length.distance);

      // Set roattion & scale
      final rotation = rotations[i - 1];
      final scaledSize =
          Offset(image.width.toDouble(), image.height.toDouble()) * strokeWidth;
      for (int j = 0; j < length.distance; j++) {
        final xCurrent = path[i - 1].dx + (j * xUnit);
        final yCurrent = path[i - 1].dy + (j * yUnit);
        final position = Offset(xCurrent, yCurrent);

        newCanvas.$1.save();
        newCanvas.$1.rotate(rotation);
        newCanvas.$1.drawImageRect(
          image,
          Rect.fromPoints(
            Offset.zero,
            Offset(
              image.width.toDouble(),
              image.height.toDouble(),
            ),
          ),
          Rect.fromPoints(
            position - scaledSize / 2,
            position + scaledSize / 2,
          ),
          Paint(),
        );
        newCanvas.$1.restore();
      }
    }
    super.endDrawing(canvas, size, newCanvas.$2);
  }

  Future<void> _loadImage() async {
    final svg = await vg.loadPicture(
      SvgAssetLoader(
        imagePath.path,
        packageName: 'flutter_painter',
      ),
      null,
    );
    image = await svg.picture.toImage(
      svg.size.width.toInt(),
      svg.size.height.toInt(),
    );
  }
}
