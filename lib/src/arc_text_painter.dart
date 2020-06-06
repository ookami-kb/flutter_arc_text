import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_arc_text/src/enums.dart';

class ArcTextPainter {
  ArcTextPainter({
    @required num radius,
    @required String text,
    @required textStyle,
    StartAngleAlignment alignment = StartAngleAlignment.start,
    double initialAngle = 0,
    Direction direction = Direction.clockwise,
    Placement placement = Placement.outside,
    double stretchAngle,
    double interLetterAngle,
  })  : assert(radius != null, 'radius should not be null'),
        assert(text != null, 'text should not be null'),
        assert(textStyle != null, 'textStyle should not be null'),
        assert(alignment != null, 'alignment should not be null'),
        assert(initialAngle != null, 'initialAngle should not be null'),
        assert(direction != null, 'direction should not be null'),
        assert(placement != null, 'placement should not be null'),
        assert(stretchAngle == null || interLetterAngle == null,
            'stretchAngle and interLetterAngle should not be both not null'),
        this._text = text,
        this._textStyle = textStyle {
    _textPainter.text = TextSpan(text: _text, style: textStyle);
    _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);

    switch (placement) {
      case Placement.inside:
        this._radius = radius - _textPainter.height;
        break;
      case Placement.outside:
        this._radius = radius;
        break;
    }

    _interLetterAngle = interLetterAngle ?? 0;
    final double finalAngle = getFinalAngle();
    final double alignmentOffset = _getAlignmentOffset(
      alignment,
      stretchAngle != null ? stretchAngle : finalAngle,
    );
    switch (direction) {
      case Direction.clockwise:
        _angleWithAlignment = initialAngle + alignmentOffset;
        _angleMultiplier = 1;
        _heightOffset = -this._radius - _textPainter.height;
        break;
      case Direction.counterClockwise:
        _angleWithAlignment = initialAngle - alignmentOffset + math.pi;
        _angleMultiplier = -1;
        _heightOffset = this._radius;
        break;
    }

    if (stretchAngle != null && _text.runes.length > 1) {
      _interLetterAngle = (stretchAngle - finalAngle) / _text.runes.length;
    }
  }

  final String _text;
  final TextStyle _textStyle;
  num _radius;
  int _angleMultiplier;
  double _heightOffset;
  double _angleWithAlignment;
  double _interLetterAngle;

  final _textPainter = TextPainter(textDirection: TextDirection.ltr);

  /// Call this method whenever the text needs to be repainted.
  ///
  /// Center of the arc will be in [offset] position.
  void paint(Canvas canvas, [Offset offset = Offset.zero]) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(_angleWithAlignment);
    _drawText(canvas, _angleMultiplier, _heightOffset);
    canvas.restore();
  }

  /// Calculates final angle the canvas will be rotated after all the text
  /// is drawn.
  double getFinalAngle() {
    double finalRotation = 0;
    _text.runes.forEach((charCode) {
      final translation = _getTranslation(String.fromCharCode(charCode));
      finalRotation += translation.alpha + _interLetterAngle;
    });
    return finalRotation - _interLetterAngle;
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
    throw ArgumentError('Unknown type: $alignment');
  }

  void _drawText(Canvas canvas, int angleMultiplier, double heightOffset) {
    _text.runes.forEach((charCode) {
      final translation = _getTranslation(String.fromCharCode(charCode));
      final halfAngleOffset = translation.alpha / 2 * angleMultiplier;
      canvas.rotate(halfAngleOffset);
      _textPainter.paint(canvas, Offset(-translation.d / 2, heightOffset));
      canvas.rotate(halfAngleOffset + _interLetterAngle * angleMultiplier);
    });
  }

  /// Calculates width and central angle for the provided [letter].
  LetterTranslation _getTranslation(String letter) {
    _textPainter.text = TextSpan(text: letter, style: _textStyle);
    _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);

    return LetterTranslation.fromRadius(_textPainter.width, _radius);
  }
}

class LetterTranslation {
  LetterTranslation(this.d, this.alpha);

  LetterTranslation.fromRadius(double letterWidth, double radius)
      : d = letterWidth,
        alpha = 2 * math.asin(letterWidth / (2 * radius));

  final double d;
  final double alpha;
}
