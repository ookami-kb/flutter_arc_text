import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Story(
            name: 'Arc text',
            builder: (_, k) {
              final radius =
                  k.slider('Radius', initial: 100, max: 200, min: 50);
              final startAngle =
                  k.slider('Start angle', initial: 0, max: 360) * pi / 180;
              final stretchAngle =
                  k.slider('Stretch angle', initial: 0, max: 360) * pi / 180;
              final text = k.text(
                'Text',
                initial: 'Hello, Flutter! I am ArcText widget. '
                    'I can draw circular text.',
              );
              final alignment = k.options('Alignment',
                  options: [
                    Option('Start', StartAngleAlignment.start),
                    Option('Center', StartAngleAlignment.center),
                    Option('End', StartAngleAlignment.end),
                  ],
                  initial: StartAngleAlignment.start);
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(radius),
                  color: Colors.white,
                ),
                width: radius * 2,
                height: radius * 2,
                child: ArcText(
                  radius: radius,
                  text: text,
                  textStyle: TextStyle(fontSize: 18, color: Colors.black),
                  startAngle: startAngle,
                  startAngleAlignment: alignment,
                  placement: k.boolean('Outside', initial: true)
                      ? Placement.outside
                      : Placement.inside,
                  direction: k.boolean('Clockwise', initial: true)
                      ? Direction.clockwise
                      : Direction.counterClockwise,
                  stretchAngle: stretchAngle == 0 ? null : stretchAngle,
                ),
              );
            },
          ),
        ),
      );
}
