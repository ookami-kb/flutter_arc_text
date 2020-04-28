import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum StartAngleAlignment { start, center, end }

class ArcText extends StatelessWidget {
  const ArcText({
    Key key,
    @required this.radius,
    @required this.text,
    @required this.textStyle,
    this.startAngle = 0,
    this.startAngleAlignment = StartAngleAlignment.start,
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
  /// - [StartAngleAlignment.start] – text will start from [startAngle]
  /// - [StartAngleAlignment.center] – text will be centered on [startAngle]
  /// - [StartAngleAlignment.end] – text will end on [startAngle]
  final StartAngleAlignment startAngleAlignment;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _Painter(
          radius,
          text,
          textStyle,
          startAngleAlignment,
          startAngle,
        ),
      );
}

class _Painter extends CustomPainter {
  _Painter(
    this.radius,
    this.text,
    this.textStyle,
    this.alignment,
    this.initialAngle,
  );

  final num radius;
  final String text;
  final double initialAngle;
  final TextStyle textStyle;
  final StartAngleAlignment alignment;

  final _textPainter = TextPainter(textDirection: TextDirection.ltr);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2 - radius);

    final angleWithAlignment = initialAngle + _getAlignmentOffset();
    if (angleWithAlignment != 0) {
      final d = 2 * radius * math.sin(angleWithAlignment / 2);
      canvas.rotate(angleWithAlignment / 2);
      canvas.translate(d, 0);
    }
    _drawText(canvas, angleWithAlignment);
  }

  double _getAlignmentOffset() {
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

  void _drawText(Canvas canvas, double initialAngle) {
    double angle = initialAngle;
    for (int i = 0; i < text.length; i++) {
      final translation = _getTranslation(text[i]);
      canvas.rotate((angle + translation.alpha) / 2);
      _textPainter.paint(canvas, Offset(0, -_textPainter.height));
      canvas.translate(translation.d, 0);
      angle = translation.alpha;
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
