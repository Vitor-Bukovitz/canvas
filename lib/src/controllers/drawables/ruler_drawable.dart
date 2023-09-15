import 'dart:ui';

import 'object_drawable.dart';

enum RulerSide {
  left,
  right,
}

/// Ruler Drawable
class RulerDrawable extends ObjectDrawable {
  /// The image to be drawn.
  final Image image;

  /// Whether the image is flipped or not.
  final bool flipped;

  /// The side to clip the drawing to.
  RulerSide side = RulerSide.left;

  /// Creates an [RulerDrawable] with the given [image].
  RulerDrawable({
    required this.image,
    required Offset position,
    double rotationAngle = 0,
    double scale = 1,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
    this.flipped = false,
  }) : super(
          position: position,
          rotationAngle: rotationAngle,
          scale: scale,
          assists: assists,
          assistPaints: assistPaints,
          hidden: hidden,
          locked: locked,
        );

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  RulerDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Image? image,
    bool? flipped,
    bool? locked,
  }) {
    return RulerDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: this.scale,
      image: image ?? this.image,
      flipped: flipped ?? this.flipped,
      locked: locked ?? this.locked,
    );
  }

  /// Draws the image on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    final scaledSize =
        Offset(image.width.toDouble(), image.height.toDouble()) * scale;
    final position = this.position.scale(flipped ? -1 : 1, 1);

    if (flipped) canvas.scale(-1, 1);

    // Draw the image onto the canvas.
    canvas.drawImageRect(
      image,
      Rect.fromPoints(
        Offset.zero,
        Offset(
          image.width.toDouble(),
          image.height.toDouble(),
        ),
      ),
      Rect.fromPoints(position - scaledSize / 2, position + scaledSize / 2),
      Paint(),
    );
  }

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    return Size(
      image.width * scale,
      image.height * scale,
    );
  }

  /// Set the side of the ruler that the point is on.
  void setSide(Offset point) {
    final rect = Rect.fromCenter(
      center: position,
      width: getSize().width,
      height: getSize().height,
    );

    if (point.dx < rect.left) {
      side = RulerSide.left;
    } else if (point.dx > rect.right) {
      side = RulerSide.right;
    }
  }
}
