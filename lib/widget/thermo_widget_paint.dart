import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'base_painter.dart';
import 'slider_painter.dart';
import 'utils.dart';

enum WidgetMode { noLunch, lunch }

class CircularSliderPaint extends StatefulWidget {
  /// Number of sectors in which the slider is divided(# of possible values on the slider).
  final int divisions;

  /// Number of primary sectors in which the slider is divided(lines used to represent Hours).
  final int primarySectors;

  /// Number of primary sectors in which the slider is divided(lines used to represent 15 minutes).
  final int secondarySectors;

  final Map<int, Map<String, dynamic>> handlerValues;

  /// Callback to be used when the user moves one of the handler or a section. It provides new Handlers' values.
  final SelectionChanged<Map<int, Map<String, dynamic>>> onSelectionChange;

  /// Callback to be used when the user terminates the interaction with one handler or a section. It provides new Handlers' values.
  final SelectionChanged<Map<int, Map<String, dynamic>>> onSelectionEnd;

  /// The color used for the base of the circle.
  final Color baseColor;

  /// Color of lines which represent hours.
  final Color hoursColor;

  /// Color of lines which represent minutes.
  final Color minutesColor;

  /// Color of the handler.
  final Color handlerColor;

  /// Radius of the outter circle of the handler.
  final double handlerOutterRadius;

  /// Child widget which can be put inside the slider.
  final Widget child;

  /// Width of the stroke which draws the circle.
  final double sliderStrokeWidth;


  List<int> get intPositions {
    // Creates a fixed-length list.
    List<int> values = List<int>(handlerValues.length);
    handlerValues.forEach((handlerNumber, info) => values[handlerNumber] = info['value']);
    return values;
  }

  CircularSliderPaint({
    @required this.divisions,
    @required this.handlerValues,
    this.child,
    @required this.primarySectors,
    @required this.secondarySectors,
    @required this.onSelectionChange,
    @required this.onSelectionEnd,
    @required this.baseColor,
    @required this.hoursColor,
    @required this.minutesColor,
    @required this.handlerColor,
    @required this.handlerOutterRadius,
    @required this.sliderStrokeWidth,
  });

  @override
  _CircularSliderState createState() => _CircularSliderState();
}

class _CircularSliderState extends State<CircularSliderPaint> {
  /// Paints handlers and sections between handlers.
  SliderPainter _painter;

  /// Angles in radians where we need to locate each handler.
  ///
  /// _angles[i] contains the position of the handler #i.
  List<double> _angles;

  /// Absolute angles in radians representing the section between two handlers.
  ///
  /// _sweepAngles[i] contains the sweep angle between hanbdler #i and
  /// handler #(i+1) % _sweepAngles.length
  List<double> _sweepAngles;


  /// In case we want to move the whole selection by clicking in the slider
  /// this will capture the position in the selection relative to the initial
  /// handler, that way we will be able to keep the selection constant when moving.
  int _differenceFromInitPoint;

  /// Used in handlePan() to know if we are moving a handler or an entire section.
  bool get isBothHandlersSelected {
    for (int i = 0; i < isHandlerSelected.length; i++) {
      if (isHandlerSelected[i] &&
          isHandlerSelected[(i + 1) % isHandlerSelected.length]) return true;
    }
    return false;
  }

  /// Used in onPanDown() to check if the user is clicking in a section.
  bool get isNoHandlerSelected {
    for (bool handlerSelected in isHandlerSelected) {
      if (handlerSelected) return false;
    }
    return true;
  }

  List<bool> isHandlerSelected = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.handlerValues.length; i++) {
      isHandlerSelected.add(false);
    }
    // Creates a non-fixed length list.
    List<int> initOrder = [];
    for(int i = 0; i < widget.handlerValues.length; i++){
      initOrder.add(widget.handlerValues.length - (i + 1));
    }
    _calculatePaintData(null, initOrder);
  }

  // We need to update this widget both with gesture detector but
  // also when the parent widget rebuilds itself.
  // If the parent widget rebuilds and request that this location in the tree update
  // to display a new widget with the same runtimeType and Widget.key, the framework
  // will update the widget property of this State object to refer to the new widget
  // and then call this method with the previous widget as an argument.
  //
  //Override this method to respond when the widget changes (e.g., to start implicit animations).
  //
  //The framework always calls build after calling didUpdateWidget, which means any calls to setState in didUpdateWidget are redundant.
  /// Called whenever the widget configuration changes, this method is used to
  /// respond when the widget changes.
  @override
  void didUpdateWidget(CircularSliderPaint oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Any widget can be updated thousands of time with no change so to modify it
    // we need to check if there are changes.
    List<int> oldValues = oldWidget.intPositions;
    _calculatePaintData(oldValues, _painter.printingOrder);
    /*List<int> oldValues = oldWidget.intPositions;
    List<int> newValues = widget.intPositions;
    for (int i = 0; i < oldValues.length; i++) {
      print('old: ${oldValues[i]} new: ${newValues[i]}');
      if(oldValues[i] != newValues[i]) {
        print('repaint');
        // If configuration is changed repaint the handlers.
        _calculatePaintData(oldValues, _painter.printingOrder);
        return;
      }
    }*/
  }

  @override
  Widget build(BuildContext context) {
    // Returns custom implementation of GestureDetector
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        CustomPanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<CustomPanGestureRecognizer>(
          () => CustomPanGestureRecognizer(
            onPanDown: _onPanDown,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
          ),
          (CustomPanGestureRecognizer instance) {},
        ),
      },
      child: CustomPaint(
        painter: BasePainter(
          baseColor: widget.baseColor,
          hoursColor: widget.hoursColor,
          minutesColor: widget.minutesColor,
          primarySectors: widget.primarySectors,
          secondarySectors: widget.secondarySectors,
          sliderStrokeWidth: widget.sliderStrokeWidth,
        ),
        foregroundPainter: _painter,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: widget.child,
        ),
      ),
    );
  }

  bool areAllDifferentValues(List<int> oldValues, List<int> newValues){
    for(int i = 0; i < oldValues.length; i++) {
      if(oldValues[i] == newValues[i]) return false;
    }
    return true;
  }

  /// Calculates all the new handlers and sweep angles' values and paints handlers.
  ///
  /// [oldValues] List containing old values of the handlers.
  /// [oldOrder] List containing the previous order with which the handlers were printed.
  void _calculatePaintData(List<int> oldValues, List<int> oldOrder) {
    List<int> printingOrder = oldOrder;
    List<int> intPositions = widget.intPositions;

    if (oldValues != null && !areAllDifferentValues(oldValues, intPositions)) {
      // The user moved only one handler.
      for(int i = 0; i < oldValues.length; i++) {
        if(oldValues[i] != intPositions[i]){
          // We keep the same order of before but we print for last the handler# 1,
          // so we it will be displayed foreground.
          printingOrder.remove(i);
          printingOrder.add(i);
          // We already found the selected handler so, stop the loop.
          break;
        }
      }
    }

    // Reset angles coordinates and sweep angles.
    _angles = [];
    _sweepAngles = [];
    // Calculates angles coordinates.
    for(int i = 0; i < intPositions.length; i++) {
      // Converts int position into percentage position for handler #i and the next one.
      double percent = valueToPercentage(intPositions[i], widget.divisions);
      double nextPercent = valueToPercentage(intPositions[(i + 1) % intPositions.length], widget.divisions);
      // Calculates the sweep angle using percentages.
      double sweep = getSweepAngle(percent, nextPercent);
      // Adds the angle #i coordinate.
      _angles.add(percentageToRadians(percent));
      // Adds the sweep angle between handler #i and next handler.
      _sweepAngles.add(percentageToRadians(sweep.abs()));
    }

    // Creates the slider painter that will paints handlers.
    _painter = SliderPainter(
      angles: _angles,
      sweepAngles: _sweepAngles,
      handlerValues: widget.handlerValues,
      handlerColor: widget.handlerColor,
      handlerOutterRadius: widget.handlerOutterRadius,
      sliderStrokeWidth: widget.sliderStrokeWidth,
      printingOrder: printingOrder,
      divisions: widget.divisions,
    );
  }

  /// Handles the pan(tap) gestures on the widget.
  ///
  /// [details] Coordinates of the pan.
  void _onPanUpdate(Offset details) {
    if (isNoHandlerSelected) {
      // No handler is selected so the pan interaction is trash.
      return;
    }
    if (_painter.center == null) {
      // Handlers are not initialized so the pan is trash.
      return;
    }
    // Handles the pan interaction.
    _handlePan(details, false);
  }

  /// User stopped his interaction.
  ///
  /// [details] Coordinates of the pan.
  void _onPanEnd(Offset details) {
    // Handles the last pan interaction.
    _handlePan(details, true);
    // Handlers are no longer selected.
    for(int i = 0; i < isHandlerSelected.length; i++){
      isHandlerSelected[i] = false;
    }
  }

  /// Handles the pan (tap)
  ///
  /// [details] coordinates of the point where te user tapped.
  /// [isPanEnd] indicates if the user stopped the pan interaction.
  void _handlePan(Offset details, bool isPanEnd) {
    // Retrieves the current render object for the widget.
    RenderBox renderBox = context.findRenderObject();
    // Get the local coordinates(on the widget) of the tap.
    var position = renderBox.globalToLocal(details);

    var angle = coordinatesToRadians(_painter.center, position);
    var percentage = radiansToPercentage(angle);
    // Int value on the slider representing the value of the tap.
    var newValue = percentageToValue(percentage, widget.divisions);
    // Old handler positions.
    List<int> intPositions = widget.intPositions;

    if (isBothHandlersSelected) {

      int newHandlerValue = (newValue - _differenceFromInitPoint) % widget.divisions;


      // The user is dragging a section between two handlers.
      for(int i = 0; i < isHandlerSelected.length; i++) {
        if(isHandlerSelected[i] && isHandlerSelected[(i + 1) % isHandlerSelected.length]) {
          if (isPanEnd) {
            // We invoke onSelectionEnd with the same values because
            // newFirstValue != widget.firstValue) is always false, this due to the fact
            // that values were update by the before handlePan call.
            widget.onSelectionEnd(widget.handlerValues);
          } else if(newHandlerValue != intPositions[i]) {
            // Handler is in a different position so update handler values.
            int diff = newHandlerValue - intPositions[i];
            var newMap = widget.handlerValues;
            newMap.forEach((handlerNumber, info){
              // Updates all handler values.
              newMap[handlerNumber]['value'] = (newMap[handlerNumber]['value'] + diff) % widget.divisions;
            });
            // Invokes callback with new handler values.
            widget.onSelectionChange(newMap);
          }
          // No need to manage singular handlers.
          return;
        }
      }
    }

    // Only one handler is selected.
    for(int i = 0; i < isHandlerSelected.length; i++) {
      if(isHandlerSelected[i]) {
        // Handler #i is selected.
        if(!_isInRange(newValue, intPositions[(i - 1) % intPositions.length], intPositions[(i + 1) % intPositions.length] )){
          // If newValue is not allowed for handler #i resets its previous value.
          newValue = intPositions[i];
        }
        // Updates handler #i value(or doesn't if !_isInRange).
        var newMap = widget.handlerValues;
        newMap[i]['value'] = newValue;
        widget.onSelectionChange(newMap);
        if (isPanEnd) {
          // User stopped interaction.
          widget.onSelectionEnd(newMap);
        }
        return;
      }
    }
  }

  /// Returns true if value is included in the interval prec:succ, false otherwise.
  ///
  /// [value] Value of the handler that was moved.
  /// [prev] Value of the previous handler.
  /// [succ] Value of the next handler.
  bool _isInRange(int value, int prev, int succ) {
    if (succ < prev) {
      if (succ == 0) return value > prev && value > succ;
      return (value > prev && value > succ) || (value < prev && value < succ);
    }
    return value > prev && value < succ;
  }

  /// Detect which handler or section has been clicked by the user.
  ///
  /// [details] Offset point representing the place on the widget where the user clicked.
  bool _onPanDown(Offset details) {
    if (_painter == null) {
      return false;
    }
    RenderBox renderBox = context.findRenderObject();
    // Get the position referred to the canvas.
    var position = renderBox.globalToLocal(details);

    if (position == null) {
      return false;
    }
    // Checks if the user selected one of the handler.
    int minimumDistancePos = 0;
    double minimumDistance = distanceBetweenPoints(position, _painter.handlerCenterOffsets[0]);
    for(int i = 1; i < _painter.handlerCenterOffsets.length; i++) {
      if(distanceBetweenPoints(position, _painter.handlerCenterOffsets[i]) < minimumDistance) {
        minimumDistance = distanceBetweenPoints(position, _painter.handlerCenterOffsets[i]);
        minimumDistancePos = i;
      }
    }
    // We know which handler has the minimum distance from tap event.
    if(isPointInsideCircle(position, _painter.handlerCenterOffsets[minimumDistancePos], widget.handlerOutterRadius)) {
      // Handler #minimumDistancePos is selected.
      isHandlerSelected[minimumDistancePos] = true;
    }

    if(isNoHandlerSelected) {
      // Check if the user has clicked in one of the sections included between
      // two handler, so we need to move all the sections.
      if (isPointAlongCircle(position, _painter.center, _painter.radius,
          widget.sliderStrokeWidth)) {
        // The point in which the user tapped is a valid point inside the circular crown.
        var angle = coordinatesToRadians(_painter.center, position);
        var positionPercentage = radiansToPercentage(angle);
        for(int i = 0; i < _angles.length; i++) {
          if (isAngleInsideRadiansSelection(angle, _angles[i], _sweepAngles[i])) {
            // The section between handler #i and handler #i+1 has been selected.
            isHandlerSelected[i] = true;
            isHandlerSelected[(i + 1) % isHandlerSelected.length] = true;
            // No need to account for negative values, that will be sorted out in the onPanUpdate.
            _differenceFromInitPoint =
                percentageToValue(positionPercentage, widget.divisions) -
                    widget.intPositions[i];
            break;
          }
        }
      }
    }
    // Returns true if at least one of the handler has been selected.
    for(bool selected in isHandlerSelected) {
      if (selected) return true;
    }
    return false;
  }
}

/// Custom pan gesture recognizer which checks if the user is interacting with the widget
/// and eventually handles the taps.
///
/// We need to extend OneSequenceGestureRecognizer, as we only need to deal with one gesture at a time.
class CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
  /// Callback used when we start pointer tracking.
  final Function onPanDown;

  /// Callback used when a pointer we are tracking has been moved.
  final Function onPanUpdate;

  /// Callback used when a pointer we are tracking has been released.
  final Function onPanEnd;

  CustomPanGestureRecognizer({
    @required this.onPanDown,
    @required this.onPanUpdate,
    @required this.onPanEnd,
  });

  @override
  void addPointer(PointerEvent event) {
    // When a pointer is detected, it checks if it's a tap down even calling onPanDown and passing
    // it the tap coordinates.
    if (onPanDown(event.position)) {
      // A handler or a section is interested by the tap.
      // Starts pointer tracking.
      startTrackingPointer(event.pointer);
      // Declare victory in the arena avoiding gesture recognition by other GestureDetectors.
      resolve(GestureDisposition.accepted);
    } else {
      // Don't keep track of the pointer.
      stopTrackingPointer(event.pointer);
    }
  }

  // The pointer we are tracking has been moved.
  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      // The pointer has been moved and not still released by the user.
      onPanUpdate(event.position);
    }
    if (event is PointerUpEvent) {
      // The pointer has been released by the user.
      onPanEnd(event.position);
      // Stops pointer tracking.
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  String get debugDescription => 'customPan';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
