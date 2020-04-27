import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
                color: Colors.white,
              ),
              width: 300,
              height: 300,
              child: ArcText(
                radius: 100,
                text: 'Hello, Flutter! '
                    'I am ArcText widget. I can draw circular text.',
                textStyle: TextStyle(fontSize: 18, color: Colors.black),
                startAngle: -pi / 2,
                startAngleAlignment: StartAngleAlignment.start,
              ),
            ),
          ),
        ),
      );
}
