import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

void main() {
  testGoldens('Golden tests', (tester) async {
    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1)
      ..addScenario('Default', const App())
      ..addScenario(
        'StartAngleAlignment.end',
        const App(alignment: StartAngleAlignment.end),
      )
      ..addScenario(
        'Placement.inside',
        const App(placement: Placement.inside),
      )
      ..addScenario(
        'stretchAngle',
        App(stretchAngle: radians(270)),
      )
      ..addScenario(
        'interLetterAngle',
        App(interLetterAngle: radians(5)),
      )
      ..addScenario(
        'painterDelegate clockwise',
        const App(
          placement: Placement.middle,
          alignment: StartAngleAlignment.center,
          painterDelegate: _delegate,
        ),
      )
      ..addScenario(
        'painterDelegate counterclockwise',
        App(
          placement: Placement.middle,
          alignment: StartAngleAlignment.center,
          painterDelegate: _delegate,
          direction: Direction.counterClockwise,
          startAngle: radians(180),
        ),
      );

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(
      tester,
      'flutter_arc_text',
      autoHeight: true,
    );
  });
}

class App extends StatelessWidget {
  const App({
    super.key,
    this.startAngle = 0,
    this.alignment = StartAngleAlignment.start,
    this.direction = Direction.clockwise,
    this.placement = Placement.outside,
    this.stretchAngle,
    this.interLetterAngle,
    this.painterDelegate,
  });

  final double startAngle;
  final StartAngleAlignment alignment;
  final Direction direction;
  final Placement placement;
  final double? stretchAngle;
  final double? interLetterAngle;
  final PainterDelegate? painterDelegate;

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          color: Colors.white,
          width: 300,
          height: 300,
          child: ArcText(
            text: 'Hello, Golden Test for ArcText!',
            radius: 100,
            textStyle: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontFamily: 'Roboto',
            ),
            startAngleAlignment: alignment,
            startAngle: startAngle,
            direction: direction,
            placement: placement,
            stretchAngle: stretchAngle,
            interLetterAngle: interLetterAngle,
            painterDelegate: painterDelegate ??
                (Canvas canvas, Size size, ArcTextPainter painter) =>
                    painter.paint(canvas, size),
          ),
        ),
      );
}

final _backgroundPaint = Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2
  ..color = Colors.black;

final _decorationPaint = Paint()
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeWidth = 32
  ..color = Colors.yellow;

void _delegate(Canvas canvas, Size size, ArcTextPainter painter) {
  final rect = Rect.fromCircle(
    center: Offset(size.width / 2, size.height / 2),
    radius: painter.radius,
  );

  canvas.drawArc(
    rect,
    painter.startAngle,
    painter.sweepAngle,
    false,
    _decorationPaint,
  );

  painter.paint(canvas, size);

  canvas.drawArc(
    rect,
    painter.finalAngle + radians(15),
    2 * pi - painter.sweepAngle - radians(30),
    false,
    _backgroundPaint,
  );
}
