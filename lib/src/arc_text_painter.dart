import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_arc_text/src/enums.dart';

class ArcTextPainter {
  ArcTextPainter({
    @required num radius,
    @required this.text,
    @required this.textStyle,
    StartAngleAlignment alignment = StartAngleAlignment.start,
    double initialAngle = 0,
    Direction direction = Direction.clockwise,
    Placement placement = Placement.outside,
  })  : assert(radius != null, 'radius should not be null'),
        assert(text != null, 'text should not be null'),
        assert(textStyle != null, 'textStyle should not be null'),
        assert(alignment != null, 'alignment should not be null'),
        assert(initialAngle != null, 'initialAngle should not be null'),
        assert(direction != null, 'direction should not be null'),
        assert(placement != null, 'placement should not be null') {
    _textPainter.text = TextSpan(text: text, style: textStyle);
    _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);

    switch (placement) {
      case Placement.inside:
        this.radius = radius;
        break;
      case Placement.outside:
        this.radius = radius + _textPainter.height;
        break;
    }

    switch (direction) {
      case Direction.clockwise:
        angleWithAlignment = initialAngle + _getAlignmentOffset(alignment);
        angleMultiplier = 1;
        heightOffset = -this.radius;
        break;
      case Direction.counterClockwise:
        angleWithAlignment =
            initialAngle - _getAlignmentOffset(alignment) + math.pi;
        angleMultiplier = -1;
        heightOffset = this.radius - _textPainter.height;
        break;
    }
  }

  final String text;
  final TextStyle textStyle;
  num radius;
  int angleMultiplier;
  double heightOffset;
  double angleWithAlignment;

  final _textPainter = TextPainter(textDirection: TextDirection.ltr);

  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(angleWithAlignment);
    _drawText(canvas, angleMultiplier, heightOffset);
    canvas.restore();
  }

  double _getAlignmentOffset(StartAngleAlignment alignment) {
    switch (alignment) {
      case StartAngleAlignment.start:
        return 0;
      case StartAngleAlignment.center:
        return -getFinalAngle() / 2;
      case StartAngleAlignment.end:
        return -getFinalAngle();
    }
    throw ArgumentError('Unknown type: $alignment');
  }

  /// Calculates final angle the canvas will be rotated after all the text
  /// is drawn.
  double getFinalAngle() {
    double finalRotation = 0;
    for (int i = 0; i < text.length; i++) {
      final translation = _getTranslation(text[i]);
      finalRotation += translation.alpha;
    }
    return finalRotation;
  }

  void _drawText(Canvas canvas, int angleMultiplier, double heightOffset) {
    for (int i = 0; i < text.length; i++) {
      final translation = _getTranslation(text[i]);
      final halfAngleOffset = translation.alpha / 2 * angleMultiplier;
      canvas.rotate(halfAngleOffset);
      _textPainter.paint(canvas, Offset(-translation.d / 2, heightOffset));
      canvas.rotate(halfAngleOffset);
    }
  }

  /// Calculates width and central angle for the provided [letter].
  LetterTranslation _getTranslation(String letter) {
    _textPainter.text = TextSpan(text: letter, style: textStyle);
    _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);

    final double d = _textPainter.width;
    final double alpha = 2 * math.asin(d / (2 * radius));
    return LetterTranslation(d, alpha);
  }
}

class LetterTranslation {
  LetterTranslation(this.d, this.alpha);

  final double d;
  final double alpha;
}
