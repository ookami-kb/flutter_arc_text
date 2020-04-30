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
    this.clockwise = true,
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

  /// Text direction
  final bool clockwise;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _Painter(
          radius,
          text,
          textStyle,
          startAngleAlignment,
          startAngle,
          clockwise,
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
    this.clockwise,
  );

  final num radius;
  final String text;
  final double initialAngle;
  final TextStyle textStyle;
  final StartAngleAlignment alignment;
  final bool clockwise;

  final _textPainter = TextPainter(textDirection: TextDirection.ltr);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    final angleWithAlignment = clockwise ? initialAngle + _getAlignmentOffset()
        : initialAngle + math.pi - _getAlignmentOffset();
    canvas.rotate(angleWithAlignment);
    _drawText(canvas);
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

  void _drawText(Canvas canvas) {
    for (int i = 0; i < text.length; i++) {
      final translation = _getTranslation(text[i]);
      final halfAngleOffset = translation.alpha / 2 * (clockwise ? 1 : -1);
      canvas.rotate(halfAngleOffset);
      _textPainter.paint(canvas,
          Offset(-translation.d / 2,
              clockwise ? -radius -_textPainter.height : radius));
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
