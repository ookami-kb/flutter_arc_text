import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Storybook(
        initialRoute: '/stories/arc-text',
        children: [
          Story(
            background: Colors.white,
            name: 'Arc text',
            builder: (_, k) {
              final displayCircle = k.boolean(
                label: 'Display circle',
                initial: true,
              );
              final radius =
                  k.slider(label: 'Radius', initial: 100, max: 200, min: 50);
              final startAngle =
                  k.slider(label: 'Start angle', initial: 0, max: 360) *
                      pi /
                      180;
              final stretchAngle =
                  k.slider(label: 'Stretch angle', initial: 0, max: 360) *
                      pi /
                      180;
              final text = k.text(
                label: 'Text',
                initial: 'Hello, Flutter! I am ArcText widget. '
                    'I can draw circular text.',
              );
              final alignment = k.options(
                  label: 'Alignment',
                  options: const [
                    Option('Start', StartAngleAlignment.start),
                    Option('Center', StartAngleAlignment.center),
                    Option('End', StartAngleAlignment.end),
                  ],
                  initial: StartAngleAlignment.start);
              final hasBackground = k.boolean(label: 'Background');
              final hasDecoration = k.boolean(label: 'Decoration');

              return Container(
                decoration: displayCircle
                    ? BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(radius),
                        color: Colors.white,
                      )
                    : null,
                width: radius * 2,
                height: radius * 2,
                child: ArcText(
                  radius: radius,
                  text: text,
                  textStyle: const TextStyle(fontSize: 18, color: Colors.black),
                  startAngle: startAngle,
                  startAngleAlignment: alignment,
                  placement: k.options(
                    label: 'Placement',
                    options: const [
                      Option('Outside', Placement.outside),
                      Option('Inside', Placement.inside),
                      Option('Middle', Placement.middle),
                    ],
                    initial: Placement.outside,
                  ),
                  direction: k.boolean(label: 'Clockwise', initial: true)
                      ? Direction.clockwise
                      : Direction.counterClockwise,
                  stretchAngle: stretchAngle == 0 ? null : stretchAngle,
                  paint: _makeDelegate(hasBackground, hasDecoration),
                ),
              );
            },
          )
        ],
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

PainterDelegate _makeDelegate(bool hasBackground, bool hasDecoration) =>
    (canvas, size, painter) {
      final rect = Rect.fromLTWH(0, 0, size.width, size.height);

      if (hasBackground) {
        canvas.drawArc(
          rect,
          painter.startAngle - pi / 2,
          painter.sweepAngle,
          false,
          _decorationPaint,
        );
      }

      painter.paint(canvas, size);

      if (hasDecoration) {
        canvas.drawArc(
          rect,
          painter.finalAngle - pi / 2 + radians(10),
          2 * pi - painter.sweepAngle - radians(20),
          false,
          _backgroundPaint,
        );
      }
    };
