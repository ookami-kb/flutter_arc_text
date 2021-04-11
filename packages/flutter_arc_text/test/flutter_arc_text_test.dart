import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:flutter_arc_text/src/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

void main() {
  testWidgets('Default', (tester) async {
    await tester.pumpWidget(const App());
    await expectLater(
      find.byType(App),
      matchesGoldenFile('golden/Default.png'),
    );
  });

  testWidgets('StartAngleAlignment.end', (tester) async {
    await tester.pumpWidget(const App(
      alignment: StartAngleAlignment.end,
    ));
    await expectLater(
      find.byType(App),
      matchesGoldenFile('golden/StartAngleAlignment.end.png'),
    );
  });

  testWidgets('Placement.inside', (tester) async {
    await tester.pumpWidget(const App(
      placement: Placement.inside,
    ));
    await expectLater(
      find.byType(App),
      matchesGoldenFile('golden/Placement.inside.png'),
    );
  });

  testWidgets('stretchAngle', (tester) async {
    await tester.pumpWidget(App(
      stretchAngle: radians(270),
    ));
    await expectLater(
      find.byType(App),
      matchesGoldenFile('golden/stretchAngle.png'),
    );
  });

  testWidgets('interLetterAngle', (tester) async {
    await tester.pumpWidget(App(
      interLetterAngle: radians(10),
    ));
    await expectLater(
      find.byType(App),
      matchesGoldenFile('golden/interLetterAngle.png'),
    );
  });

  testWidgets('painterDelegate clockwise', (tester) async {
    await tester.pumpWidget(const App(
      placement: Placement.middle,
      alignment: StartAngleAlignment.center,
      painterDelegate: _delegate,
    ));
    await expectLater(
      find.byType(App),
      matchesGoldenFile('golden/painterDelegate_clockwise.png'),
    );
  });

  testWidgets('painterDelegate counterclockwise', (tester) async {
    await tester.pumpWidget(App(
      placement: Placement.middle,
      alignment: StartAngleAlignment.center,
      painterDelegate: _delegate,
      direction: Direction.counterClockwise,
      startAngle: radians(180),
    ));
    await expectLater(
      find.byType(App),
      matchesGoldenFile('golden/painterDelegate_counterclockwise.png'),
    );
  });
}

class App extends StatelessWidget {
  const App({
    Key? key,
    this.startAngle = 0,
    this.alignment = StartAngleAlignment.start,
    this.direction = Direction.clockwise,
    this.placement = Placement.outside,
    this.stretchAngle,
    this.interLetterAngle,
    this.painterDelegate,
  }) : super(key: key);

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
            text: 'Hello ArcText',
            radius: 100,
            textStyle: const TextStyle(fontSize: 14, color: Colors.black),
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
