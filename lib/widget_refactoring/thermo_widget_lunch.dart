import 'package:flutter/material.dart';
import 'package:thermo_widget/widget/utils.dart';

import '../widget/thermo_widget_paint.dart';

/// Returns a widget which displays a circle to be used as a slider.
///
/// Required arguments are divisions and the values which indicate the position
/// of the handlers on the slider.
/// onSelectionChange is a callback function which returns new values as the user
/// changes one of the sections or one of the handlers.
/// The rest of the params are used to change the look and feel.
///
class TempSliderLunch extends StatefulWidget {
  /// /// Number of sectors in which the slider is divided(# of possible values on the slider)
  /// Max value is 300.
  final int divisions;

  /// Map<int, string> where int is tha value in which the handler #i is positioned
  /// and the other map is <propertyName, value>
  /// - temperature => int
  /// - color => Color
  final Map<String, Map<String, dynamic>> handlerValues;

  /// The number of primary sectors to be painted.
  final int primarySectors;

  /// The number of secondary sectors to be painted.
  final int secondarySectors;

  /// An optional widget that will be inserted inside the slider.
  final Widget child;

  /// Height of the canvas where the slider is rendered, default at 300.
  final double height;

  /// Width of the canvas where the slider is rendered, default at 300.
  final double width;

  /// Color of the base circle.
  final Color baseColor;

  /// Color of lines which represent hours(primarySectors).
  final Color hoursColor;

  /// Color of lines which represent minutes(secondarySectors).
  final Color minutesColor;

  /// Color of the handlers.
  final Color handlerColor;

  /// Function called when at least one of firstValue,secondValue,thirdValue,fourthValue changes.
  /// (int firstValue, int secondValue, int thirdValue, int fourthValue) => void
  final SelectionChanged<int> onSelectionChange;

  /// Function called when the user stop changing firstValue,secondValue,thirdValue,fourthValue values.
  /// (int firstValue, int secondValue, int thirdValue, int fourthValue) => void
  final SelectionChanged<int> onSelectionEnd;

  /// Radius of the outter circle of the handler.
  final double handlerOutterRadius;

  /// Stroke width for the slider.
  final double sliderStrokeWidth;

  TempSliderLunch(
      this.divisions,
      this.handlerValues,
      {
        this.height,
        this.width,
        this.child,
        this.primarySectors,
        this.secondarySectors,
        this.baseColor,
        this.hoursColor,
        this.minutesColor,
        this.handlerColor,
        this.onSelectionChange,
        this.onSelectionEnd,
        this.handlerOutterRadius,
        this.sliderStrokeWidth,
      })  : assert(divisions >= 0 && divisions <= 300,
        'divisions has to be >= 0 and <= 300');

  @override
  _TempSliderLunchState createState() => _TempSliderLunchState();
}

class _TempSliderLunchState extends State<TempSliderLunch> {

  Map<String, Map<String, dynamic>> _handlerValues;

  /// Set the initial state of the widget.
  @override
  void initState() {
    super.initState();
    _handlerValues = widget.handlerValues;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height ?? 300.0,
        width: widget.width ?? 300.0,
        child: CircularSliderPaint(
          mode: WidgetMode.lunch,
          handlerValues: _handlerValues,
          divisions: widget.divisions,
          primarySectors: widget.primarySectors ?? 0,
          secondarySectors: widget.secondarySectors ?? 0,
          child: widget.child,
          onSelectionChange: (newFirst, newSecond, newThird, newForth) {
            if (widget.onSelectionChange != null) {
              // If the caller passed a callback executes it.
              widget.onSelectionChange(newFirst, newSecond, newThird, newForth);
            }
            setState(() {
              // Updates the widget values.
              _firstValue = newFirst;
              _secondValue = newSecond;
              _thirdValue = newThird;
              _fourthValue = newForth;
            });
          },
          onSelectionEnd: (newFirst, newSecond, newThird, newFourth) {
            if (widget.onSelectionEnd != null) {
              // If the caller passed a callback executes it.
              widget.onSelectionEnd(newFirst, newSecond, newThird, newFourth);
            }
          },
          sliderStrokeWidth: widget.sliderStrokeWidth == null ||
              widget.sliderStrokeWidth < 20.0 ||
              widget.sliderStrokeWidth > 36
              ? 28.0
              : widget.sliderStrokeWidth,
          baseColor: widget.baseColor ?? Color.fromRGBO(255, 255, 255, 0.1),
          hoursColor: widget.hoursColor ?? Color.fromRGBO(255, 255, 255, 0.3),
          minutesColor: widget.minutesColor ?? Colors.white30,
          section12Color: widget.section12Color ?? Colors.amber,
          section23Color: widget.section23Color ?? Colors.deepPurpleAccent,
          section34Color: widget.section34Color ?? Colors.amber,
          section41Color: widget.section41Color ?? Colors.brown[400],
          handlerColor: widget.handlerColor ?? Colors.white,
          handlerOutterRadius: widget.handlerOutterRadius ?? 22.0,
        ));
  }
}
