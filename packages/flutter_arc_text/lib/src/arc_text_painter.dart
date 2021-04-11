import 'dart:math' as math;

import 'package:characters/characters.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_arc_text/src/enums.dart';

class ArcTextPainter {
  ArcTextPainter({
    required num radius,
    required String text,
    required TextStyle textStyle,
    StartAngleAlignment alignment = StartAngleAlignment.start,
    double initialAngle = 0,
    Direction direction = Direction.clockwise,
    Placement placement = Placement.outside,
    double? stretchAngle,
    double? interLetterAngle,
  })  : assert(
          stretchAngle == null || interLetterAngle == null,
          'stretchAngle and interLetterAngle should not be both not null',
        ),
        _text = text,
        _textStyle = textStyle {
    _textPainter
      ..text = TextSpan(text: _text, style: textStyle)
      ..layout(minWidth: 0, maxWidth: double.maxFinite);

    switch (placement) {
      case Placement.inside:
        _radius = radius - _textPainter.height;
        break;
      case Placement.outside:
        _radius = radius;
        break;
      case Placement.middle:
        _radius = radius - _textPainter.height / 2;
        break;
    }

    _interLetterAngle = interLetterAngle ?? 0;
    final double finalAngle = sweepAngle;
    final double alignmentOffset = _getAlignmentOffset(
      alignment,
      stretchAngle ?? finalAngle,
    );
    switch (direction) {
      case Direction.clockwise:
        _angleWithAlignment = initialAngle + alignmentOffset;
        _angleMultiplier = 1;
        _heightOffset = -_radius.toDouble() - _textPainter.height;
        break;
      case Direction.counterClockwise:
        _angleWithAlignment = initialAngle - alignmentOffset + math.pi;
        _angleMultiplier = -1;
        _heightOffset = _radius.toDouble();
        break;
    }

    if (stretchAngle != null && _text.characters.length > 1) {
      _interLetterAngle = (stretchAngle - finalAngle) / _text.characters.length;
    }
  }

  final String _text;
  final TextStyle _textStyle;
  late final num _radius;
  late final int _angleMultiplier;
  late final double _heightOffset;
  late final double _angleWithAlignment;
  late double _interLetterAngle;

  final _textPainter = TextPainter(textDirection: TextDirection.ltr);

  /// Call this method whenever the text needs to be repainted.
  ///
  /// Center of the arc by default will be in the center rectangle of [size]
  /// with top left in (0, 0). You can control it with [offset].
  void paint(Canvas canvas, Size size, {Offset? offset}) {
    final effectiveOffset = offset ?? Offset(size.width / 2, size.height / 2);
    canvas
      ..save()
      ..translate(effectiveOffset.dx, effectiveOffset.dy)
      ..rotate(_angleWithAlignment);
    _drawText(canvas, _angleMultiplier, _heightOffset);
    canvas.restore();
  }

  /// Returns start from which the text will be draw
  /// (0 is top center, positive angle is clockwise).
  double get startAngle => _angleWithAlignment;

  /// Calculates the angle of the arc, along which the text is drawn.
  double get sweepAngle {
    double finalRotation = 0;
    _text.characters.forEach((graphemeCluster) {
      final translation = _getTranslation(graphemeCluster);
      finalRotation += translation.alpha + _interLetterAngle;
    });
    return finalRotation - _interLetterAngle;
  }

  /// Return final angle at which the text stops.
  double get finalAngle => startAngle + sweepAngle;

  double _getAlignmentOffset(StartAngleAlignment alignment, double angle) {
    switch (alignment) {
      case StartAngleAlignment.start:
        return 0;
      case StartAngleAlignment.center:
        return -angle / 2;
      case StartAngleAlignment.end:
        return -angle;
    }
  }

  void _drawText(Canvas canvas, int angleMultiplier, double heightOffset) {
    _text.characters.forEach((graphemeCluster) {
      final translation = _getTranslation(graphemeCluster);
      final halfAngleOffset = translation.alpha / 2 * angleMultiplier;
      canvas.rotate(halfAngleOffset);
      _textPainter.paint(
          canvas, Offset(-translation.letterWidth / 2, heightOffset));
      canvas.rotate(halfAngleOffset + _interLetterAngle * angleMultiplier);
    });
  }

  /// Calculates width and central angle for the provided [letter].
  LetterTranslation _getTranslation(String letter) {
    _textPainter
      ..text = TextSpan(text: letter, style: _textStyle)
      ..layout(minWidth: 0, maxWidth: double.maxFinite);

    return LetterTranslation.fromRadius(_textPainter.width, _radius.toDouble());
  }
}

class LetterTranslation {
  LetterTranslation(this.letterWidth, this.alpha);

  LetterTranslation.fromRadius(this.letterWidth, double radius)
      : alpha = 2 * math.asin(letterWidth / (2 * radius));

  final double letterWidth;
  final double alpha;
}
