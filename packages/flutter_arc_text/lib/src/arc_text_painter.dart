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
    this.direction = Direction.clockwise,
    Placement placement = Placement.outside,
    double? stretchAngle,
    double? interLetterAngle,
  })  : assert(
          stretchAngle == null || interLetterAngle == null,
          'stretchAngle and interLetterAngle should not be both not null',
        ),
        radius = radius.toDouble(),
        _text = text,
        _textStyle = textStyle {
    _textPainter
      ..text = TextSpan(text: _text, style: textStyle)
      ..layout(minWidth: 0, maxWidth: double.maxFinite);

    switch (placement) {
      case Placement.inside:
        _effectiveRadius = this.radius - _textPainter.height;
      case Placement.outside:
        _effectiveRadius = this.radius;
      case Placement.middle:
        _effectiveRadius = this.radius - _textPainter.height / 2;
    }

    _interLetterAngle = (stretchAngle != null && _text.characters.length > 1)
        ? (stretchAngle -
                _calculateSweepAngle(
                  _textPainter,
                  _textStyle,
                  _effectiveRadius,
                  _text,
                  0,
                )) /
            _text.characters.length
        : interLetterAngle ?? 0;

    final double alignmentOffset =
        _getAlignmentOffset(alignment, stretchAngle ?? sweepAngle);
    switch (direction) {
      case Direction.clockwise:
        _angleWithAlignment = initialAngle + alignmentOffset;
        _angleMultiplier = 1;
        _heightOffset = -_effectiveRadius - _textPainter.height;
      case Direction.counterClockwise:
        _angleWithAlignment = initialAngle - alignmentOffset + math.pi;
        _angleMultiplier = -1;
        _heightOffset = _effectiveRadius;
    }
  }

  final String _text;
  final TextStyle _textStyle;
  late final double _effectiveRadius;
  late final int _angleMultiplier;
  late final double _heightOffset;
  late final double _angleWithAlignment;
  late final double _interLetterAngle;
  final Direction direction;
  final double radius;

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

  /// Returns angle from which the text rendering starts.
  ///
  /// {@template flutter_arc_text.angle}
  /// Zero radians is the point on the right hand side of the circle
  /// and positive angles goes clockwise.
  ///
  /// Whether it is start or end of the text depends on [direction], but
  /// it's always correct to assume that
  /// [startAngle] + [sweepAngle] == [finalAngle].
  /// {@endtemplate}
  double get startAngle {
    switch (direction) {
      case Direction.clockwise:
        return _angleWithAlignment - math.pi / 2;
      case Direction.counterClockwise:
        return _angleWithAlignment + math.pi / 2 - sweepAngle;
    }
  }

  /// Returns angle where the text rendering stops.
  ///
  /// {@macro flutter_arc_text.angle}
  late final double sweepAngle = _calculateSweepAngle(
    _textPainter,
    _textStyle,
    _effectiveRadius,
    _text,
    _interLetterAngle,
  );

  /// Returns final angle at which the text stops.
  double get finalAngle => startAngle + sweepAngle;

  void _drawText(Canvas canvas, int angleMultiplier, double heightOffset) {
    for (final graphemeCluster in _text.characters) {
      final translation = _getTranslation(
        _textPainter,
        _textStyle,
        _effectiveRadius,
        graphemeCluster,
      );
      final halfAngleOffset = translation.alpha / 2 * angleMultiplier;
      canvas.rotate(halfAngleOffset);
      _textPainter.paint(
        canvas,
        Offset(-translation.letterWidth / 2, heightOffset),
      );
      canvas.rotate(halfAngleOffset + _interLetterAngle * angleMultiplier);
    }
  }
}

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

double _calculateSweepAngle(
  TextPainter painter,
  TextStyle style,
  double radius,
  String text,
  double interLetterAngle,
) {
  double finalRotation = 0;
  for (final graphemeCluster in text.characters) {
    final translation = _getTranslation(
      painter,
      style,
      radius,
      graphemeCluster,
    );
    finalRotation += translation.alpha + interLetterAngle;
  }
  return finalRotation - interLetterAngle;
}

/// Calculates width and central angle for the provided [letter].
LetterTranslation _getTranslation(
  TextPainter painter,
  TextStyle style,
  double radius,
  String letter,
) {
  painter
    ..text = TextSpan(text: letter, style: style)
    ..layout(minWidth: 0, maxWidth: double.maxFinite);

  return LetterTranslation.fromRadius(painter.width, radius);
}

class LetterTranslation {
  LetterTranslation(this.letterWidth, this.alpha);

  LetterTranslation.fromRadius(this.letterWidth, double radius)
      : alpha = 2 * math.asin(letterWidth / (2 * radius));

  final double letterWidth;
  final double alpha;
}
