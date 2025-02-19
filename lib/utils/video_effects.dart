import 'package:flutter/material.dart';
class VideoEffects {
  /// Rotates the matrix by a given angle (in radians) around the Z-axis
  static Matrix4 rotate(double angle) {
    return Matrix4.rotationZ(angle);
  }

  /// Flips the matrix horizontally or vertically based on the parameters
  static Matrix4 flip({bool horizontal = true, bool vertical = false}) {
    return Matrix4.identity()
      ..scale(horizontal ? -1.0 : 1.0, vertical ? -1.0 : 1.0, 1.0);
  }

  /// Scales the matrix by a given factor
  static Matrix4 scale(double scale) {
    assert(scale > 0, 'Scale must be greater than zero');
    return Matrix4.identity()..scale(scale);
  }

  /// Translates the matrix by the specified x, y, and optional z values
  static Matrix4 translate(double x, double y, [double z = 0.0]) {
    return Matrix4.identity()..translate(x, y, z);
  }

  /// Combines multiple transformations into one matrix
  static Matrix4 combine({
    double rotationAngle = 0.0,
    bool flipHorizontal = false,
    bool flipVertical = false,
    double scaleFactor = 1.0,
    double translateX = 0.0,
    double translateY = 0.0,
  }) {
    return Matrix4.identity()
      ..translate(translateX, translateY)
      ..multiply(Matrix4.rotationZ(rotationAngle))
      ..scale(flipHorizontal ? -1.0 : 1.0, flipVertical ? -1.0 : 1.0)
      ..scale(scaleFactor);
  }
}
