[![](https://img.shields.io/pub/v/flutter_arc_text)](https://pub.dev/packages/flutter_arc_text)

# Flutter Arc Text

Renders text along the arc. See [demo](https://ookami-kb.github.io/flutter_arc_text/).

The story behind the plugin is [here](https://developers.mews.com/flutter-how-to-draw-text-along-arc/).

![](screenshot_sm.png)

## Basic usage

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ArcText(
        radius: 100,
        text: 'Hello, Flutter!',
        textStyle: TextStyle(fontSize: 18, color: Colors.black),
        startAngle: -pi / 2,
        startAngleAlignment: StartAngleAlignment.start,
        placement: Placement.outside,
        direction: Direction.clockwise
      );
}
```

## Example

See [example](example) project.
