import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum StartAngleAlignment { start, center, end }
enum Direction { clockwise, counterClockwise }
enum Placement { inside, outside }

class ArcText extends StatelessWidget {
  const ArcText({
    Key key,
    @required this.radius,
    @required this.text,
    @required this.textStyle,
    this.startAngle = 0,
    this.startAngleAlignment = StartAngleAlignment.start,
    this.direction = Direction.clockwise,
    this.placement = Placement.outside,
  }) : super(key: key);

  /// Radius of the arc along which the text will be drawn.
  final double radius;

  /// Text to draw.
  final String text;

  /// TextStyle that will be applied to the text.
  final TextStyle textStyle;

  /// Initial angle (0 is top center, positive angle is clockwise).
  final double startAngle;

  /// Text alignment around [startAngle].
  ///
  /// - [StartAngleAlignment.start] – text will start from [startAngle].
  /// - [StartAngleAlignment.center] – text will be centered on [startAngle].
  /// - [StartAngleAlignment.end] – text will end on [startAngle].
  final StartAngleAlignment startAngleAlignment;

  /// Text direction.
  final Direction direction;

  /// Text placement relative to circle with the same [radius].
  final Placement placement;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _Painter(
          radius: radius,
          text: text,
          textStyle: textStyle,
          alignment: startAngleAlignment,
          initialAngle: startAngle,
          direction: direction,
          placement: placement,
        ),
      );
}

class _Painter extends CustomPainter {
  _Painter({
    @required num radius,
    @required this.text,
    @required this.textStyle,
    @required StartAngleAlignment alignment,
    @required double initialAngle,
    @required Direction direction,
    @required Placement placement,
  }) {
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

  @override
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
        return -_getFinalAngle() / 2;
      case StartAngleAlignment.end:
        return -_getFinalAngle();
    }
    throw ArgumentError('Unknown type: $alignment');
  }

  /// Calculates final angle the canvas will be rotated after all the text
  /// is drawn.
  double _getFinalAngle() {
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
  _LetterTranslation _getTranslation(String letter) {
    _textPainter.text = TextSpan(text: letter, style: textStyle);
    _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);

    final double d = _textPainter.width;
    final double alpha = 2 * math.asin(d / (2 * radius));
    return _LetterTranslation(d, alpha);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _LetterTranslation {
  _LetterTranslation(this.d, this.alpha);

  final double d;
  final double alpha;
}
