import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  CustomDecorationPainter _drawArc(bool clockwise) =>
      (Canvas canvas, Rect rect, double finalAngle) {
        final length = 2 * pi - finalAngle;
        if (length < 0) return;

        final startAngle =
            clockwise ? finalAngle - pi / 2 : finalAngle + length + pi / 2;

        const distance = 0.05;

        final paint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

        canvas.drawArc(
            rect, startAngle + distance, length - distance * 2, false, paint);
      };

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
              final clockwise = k.boolean(label: 'Clockwise', initial: true);

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
                  direction: clockwise
                      ? Direction.clockwise
                      : Direction.counterClockwise,
                  stretchAngle: stretchAngle == 0 ? null : stretchAngle,
                  customDecoration:
                      k.boolean(label: 'Draw arc between text ends')
                          ? _drawArc(clockwise)
                          : null,
                ),
              );
            },
          )
        ],
      );
}
