import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _startAngle = -pi / 2;
  bool _outside = true;
  bool _clockwise = true;
  double _radius = 120;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(_radius),
                        color: Colors.white,
                      ),
                      width: _radius * 2,
                      height: _radius * 2,
                      child: ArcText(
                        radius: _radius,
                        text: 'Hello, Flutter! '
                            'I am ArcText widget. I can draw circular text.',
                        textStyle: TextStyle(fontSize: 18, color: Colors.black),
                        startAngle: _startAngle,
                        startAngleAlignment: StartAngleAlignment.start,
                        placement:
                            _outside ? Placement.outside : Placement.inside,
                        direction: _clockwise
                            ? Direction.clockwise
                            : Direction.counterClockwise,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  subtitle: Slider(
                    value: _radius,
                    min: 90,
                    max: 150,
                    onChanged: (v) => setState(() => _radius = v),
                  ),
                  title: Text('Radius'),
                ),
                ListTile(
                  subtitle: Slider(
                    value: _startAngle,
                    min: -pi,
                    max: pi,
                    onChanged: (v) => setState(() => _startAngle = v),
                  ),
                  title: Text('Start angle'),
                ),
                CheckboxListTile(
                  value: _outside,
                  onChanged: (v) => setState(() => _outside = v),
                  title: Text('Outside'),
                ),
                CheckboxListTile(
                  value: _clockwise,
                  onChanged: (v) => setState(() => _clockwise = v),
                  title: Text('Clockwise'),
                ),
              ],
            ),
          ),
        ),
      );
}
