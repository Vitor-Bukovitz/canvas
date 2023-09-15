import 'dart:math';
import 'dart:ui';

extension OffsetExtension on Offset {
  Offset rotate(
    double angle, {
    Offset? origin,
  }) {
    final cosTheta = cos(angle);
    final sinTheta = sin(angle);
    final originX = origin?.dx ?? 0;
    final originY = origin?.dy ?? 0;
    final x = dx - originX;
    final y = dy - originY;
    final rotatedX = x * cosTheta - y * sinTheta;
    final rotatedY = x * sinTheta + y * cosTheta;
    return Offset(rotatedX + originX, rotatedY + originY);
  }
}
