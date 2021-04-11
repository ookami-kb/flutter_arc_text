import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_arc_text/src/arc_text_painter.dart';
import 'package:flutter_arc_text/src/enums.dart';

class ArcText extends StatelessWidget {
  const ArcText({
    Key? key,
    required this.radius,
    required this.text,
    required this.textStyle,
    this.startAngle = 0,
    this.startAngleAlignment = StartAngleAlignment.start,
    this.direction = Direction.clockwise,
    this.placement = Placement.outside,
    this.stretchAngle,
    this.interLetterAngle,
    this.paint = _defaultPaint,
  }) : super(key: key);

  /// Radius of the arc along which the text will be drawn.
  final double radius;

  /// Text to draw.
  final String text;

  /// TextStyle that will be applied to the text.
  final TextStyle textStyle;

  /// Initial angle (0 is top center, positive angle is clockwise).
  final double startAngle;

  /// Angle of the arc to fit text into by adjusting inter-letter space.
  ///
  /// At least one of [stretchAngle] and [interLetterAngle] should be null.
  final double? stretchAngle;

  /// Inter-letter spacing set by angle.
  ///
  /// At least one of [stretchAngle] and [interLetterAngle] should be null.
  final double? interLetterAngle;

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

  final PainterDelegate paint;

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
          stretchAngle: stretchAngle,
          interLetterAngle: interLetterAngle,
          paint: paint,
        ),
      );
}

class _Painter extends CustomPainter {
  _Painter({
    required num radius,
    required String text,
    required TextStyle textStyle,
    required StartAngleAlignment alignment,
    required double initialAngle,
    required Direction direction,
    required Placement placement,
    double? stretchAngle,
    double? interLetterAngle,
    required PainterDelegate paint,
  })   : _paint = paint,
        _painter = ArcTextPainter(
          radius: radius,
          text: text,
          textStyle: textStyle,
          alignment: alignment,
          initialAngle: initialAngle,
          direction: direction,
          placement: placement,
          stretchAngle: stretchAngle,
          interLetterAngle: interLetterAngle,
        );

  final ArcTextPainter _painter;
  final PainterDelegate _paint;

  @override
  void paint(Canvas canvas, Size size) => _paint(canvas, size, _painter);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

typedef PainterDelegate = void Function(
  Canvas canvas,
  Size size,
  ArcTextPainter painter,
);

void _defaultPaint(Canvas canvas, Size size, ArcTextPainter painter) {
  painter.paint(canvas, size);
}
