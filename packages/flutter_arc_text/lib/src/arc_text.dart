import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_arc_text/src/arc_text_painter.dart';
import 'package:flutter_arc_text/src/enums.dart';

class ArcText extends StatelessWidget {
  const ArcText({
    super.key,
    required this.radius,
    required this.text,
    this.textStyle,
    this.startAngle = 0,
    this.startAngleAlignment = StartAngleAlignment.start,
    this.direction = Direction.clockwise,
    this.placement = Placement.outside,
    this.stretchAngle,
    this.interLetterAngle,
    this.painterDelegate = _defaultPaint,
  });

  /// Radius of the arc along which the text will be drawn.
  final double radius;

  /// Text to draw.
  final String text;

  /// TextStyle that will be applied to the text.
  final TextStyle? textStyle;

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

  /// Controls how the text will be rendered.
  ///
  /// By default, it just calls
  ///
  /// ```dart
  /// painter.paint(canvas, size);
  /// ```
  ///
  /// You can use this parameter, for example, to add decoration before or
  /// after text is drawn. Consider the following delegate to draw background
  /// behind the text:
  ///
  /// ```dart
  /// final decorationPaint = Paint()
  ///   ..style = PaintingStyle.stroke
  ///   ..strokeCap = StrokeCap.round
  ///   ..strokeWidth = 32
  ///   ..color = Colors.yellow;
  ///
  /// void painterDelegate(Canvas canvas, Size size, ArcTextPainter painter) {
  ///   final rect = Rect.fromCircle(
  ///     center: Offset(size.width / 2, size.height / 2),
  ///     radius: painter.radius,
  ///   );
  ///   canvas.drawArc(
  ///     rect,
  ///     painter.startAngle,
  ///     painter.sweepAngle,
  ///     false,
  ///     decorationPaint,
  ///   );
  ///   painter.paint(canvas, size);
  /// }
  /// ```
  ///
  /// For a more complex use case, take a look at the example package.
  ///
  /// Don't forget to call `painter.paint(canvas, size)` in your custom
  /// delegate to draw the text itself.
  final PainterDelegate painterDelegate;

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle effectiveTextStyle = defaultTextStyle.style.merge(textStyle);

    if (MediaQuery.boldTextOf(context)) {
      effectiveTextStyle = effectiveTextStyle
          .merge(const TextStyle(fontWeight: FontWeight.bold));
    }

    return CustomPaint(
      painter: _Painter(
        radius: radius,
        text: text,
        textStyle: effectiveTextStyle,
        alignment: startAngleAlignment,
        initialAngle: startAngle,
        direction: direction,
        placement: placement,
        stretchAngle: stretchAngle,
        interLetterAngle: interLetterAngle,
        painterDelegate: painterDelegate,
      ),
    );
  }
}

class _Painter extends CustomPainter {
  _Painter({
    required num radius,
    required String text,
    TextStyle? textStyle,
    required StartAngleAlignment alignment,
    required double initialAngle,
    required Direction direction,
    required Placement placement,
    double? stretchAngle,
    double? interLetterAngle,
    required PainterDelegate painterDelegate,
  })  : _painterDelegate = painterDelegate,
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
  final PainterDelegate _painterDelegate;

  @override
  void paint(Canvas canvas, Size size) =>
      _painterDelegate(canvas, size, _painter);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// Use this delegate to override how the text will be rendered.
typedef PainterDelegate = void Function(
  Canvas canvas,
  Size size,
  ArcTextPainter painter,
);

void _defaultPaint(Canvas canvas, Size size, ArcTextPainter painter) {
  painter.paint(canvas, size);
}
