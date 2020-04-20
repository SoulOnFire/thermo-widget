import 'package:flutter/material.dart';
import 'package:thermo_widget/widget/utils.dart';

import 'thermo_widget_paint.dart';

/// Returns a widget which displays a circle to be used as a slider.
///
/// Required arguments are divisions and the values which indicate the position
/// of the handlers on the slider.
/// onSelectionChange is a callback function which returns new values as the user
/// changes one of the sections or one of the handlers.
/// The rest of the params are used to change the look and feel.
///
class TempSlider extends StatefulWidget {
  /// /// Number of sectors in which the slider is divided(# of possible values on the slider)
  /// Max value is 300.
  final int divisions;

  /// Map<int, string> where int is tha value in which the handler #i is positioned
  /// and the other map is <propertyName, value>
  /// - temperature => int
  /// - color => Color
  final Map<int, Map<String, dynamic>> handlerValues;

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

  /// Color of the section between handler #1 and handler #2.
  final Color section12Color;

  /// Color of the section between handler #2 and handler #3.
  final Color section23Color;

  /// Color of the section between handler #3 and handler #4.
  final Color section34Color;

  /// Color of the section between handler #4 and handler #1.
  final Color section41Color;

  /// Color of the handlers.
  final Color handlerColor;

  /// Function called when at least one of firstValue,secondValue,thirdValue,fourthValue changes.
  /// (int firstValue, int secondValue, int thirdValue, int fourthValue) => void
  final SelectionChanged<Map<int, Map<String, dynamic>>> onSelectionChange;

  /// Function called when the user stop changing firstValue,secondValue,thirdValue,fourthValue values.
  /// (int firstValue, int secondValue, int thirdValue, int fourthValue) => void
  final SelectionChanged<Map<int, Map<String, dynamic>>> onSelectionEnd;

  /// Radius of the outter circle of the handler.
  final double handlerOutterRadius;

  /// Stroke width for the slider.
  final double sliderStrokeWidth;


  TempSlider(
      this.divisions,
      this.handlerValues, {
        this.height,
        this.width,
        this.child,
        this.primarySectors,
        this.secondarySectors,
        this.baseColor,
        this.hoursColor,
        this.minutesColor,
        this.section12Color,
        this.section23Color,
        this.section34Color,
        this.section41Color,
        this.handlerColor,
        this.onSelectionChange,
        this.onSelectionEnd,
        this.handlerOutterRadius,
        this.sliderStrokeWidth,
      })  : assert(divisions >= 0 && divisions <= 300,
        'divisions has to be >= 0 and <= 300');

  @override
  _TempSliderState createState() => _TempSliderState();
}

class _TempSliderState extends State<TempSlider> {

  Map<int, Map<String, dynamic>> _handlerValues;

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
          handlerValues: _handlerValues,
          divisions: widget.divisions,
          primarySectors: widget.primarySectors ?? 0,
          secondarySectors: widget.secondarySectors ?? 0,
          child: widget.child,
          onSelectionChange: (newMap) {
            if (widget.onSelectionChange != null) {
              // If the caller passed a callback executes it.
              widget.onSelectionChange(newMap);
            }
            setState(() {
              // Updates the widget values.
              _handlerValues = newMap;
            });
          },
          onSelectionEnd: (newMap) {
            if (widget.onSelectionEnd != null) {
              // If the caller passed a callback executes it.
              widget.onSelectionEnd(newMap);
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
          handlerColor: widget.handlerColor ?? Colors.white,
          handlerOutterRadius: widget.handlerOutterRadius ?? 22.0,
        ));
  }
}
