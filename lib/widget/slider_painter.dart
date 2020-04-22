import 'dart:math';

import 'package:flutter/material.dart';

import 'utils.dart';

/// Paints the handler and the areas between the handlers
class SliderPainter extends CustomPainter {
  /// Color of the handler.
  Color handlerColor;

  /// Width of slider.
  double sliderStrokeWidth;

  /// Radius of the handlers.
  double handlerRadius;

  /// Radius of the outter circle of the handler.
  double handlerOutterRadius;

  /// Center's coordinates of the slider.
  Offset center;

  /// Radius of the slider.
  double radius;

  /// Order in which the handlers must be printed.
  List<int> printingOrder;

  /// Number of sectors in which the slider is divided(# of possible values on the slider).
  int divisions;

  /// Map containing handlers information.
  ///
  /// handlerValues[i] returns a Map<String, dynamic> containing handler information.
  Map<int, Map<String, dynamic>> handlerValues;

  /// Handlers coordinate on the slider.
  List<Offset> handlerOffsets;

  /// Coordinates of the center of each handler.
  List<Offset> handlerCenterOffsets;

  /// Angles in which handlers are located.
  ///
  /// angles[i] contains the angle in which handler #i is located.
  List<double> angles;

  /// Absolute angles in radians representing the section between two handlers.
  ///
  /// _sweepAngles[i] contains the sweep angle between hanbdler #i and
  /// handler #(i+1) % _sweepAngles.length
  List<double> sweepAngles;

  /// Map containing default color for each temperature.
  Map<String, Color> defaultColors = {
    'T0': Colors.redAccent,
    'T1': Colors.brown[400],
    'T2': Colors.deepPurpleAccent,
    'T3': Colors.amber,
  };

  /// Map containing default icon for each temperature.
  Map<String, IconData> defaultIcons = {
    'T0': Icons.ac_unit,
    'T1': Icons.brightness_3,
    'T2': Icons.work,
    'T3': Icons.home,
  };

  SliderPainter({
    @required this.handlerValues,
    @required this.angles,
    @required this.sweepAngles,
    @required this.handlerColor,
    @required this.handlerOutterRadius,
    @required this.sliderStrokeWidth,
    @required this.printingOrder,
    @required this.divisions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    center = Offset(size.width / 2, size.height / 2);
    radius = min((size.width - distanceFromCanvas) / 2,
        (size.height - distanceFromCanvas) / 2) -
        sliderStrokeWidth;

    // Paints the sections.
    for (int i = 0; i < angles.length; i++) {
      Color color =
          handlerValues[i]['color'] ?? defaultColors[handlerValues[i]['temp']];
      Paint sectionPaint = _getPaint(color: color);
      // Paints the section between handler #i and the next one.
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          -pi / 2 + angles[i], sweepAngles[i], false, sectionPaint);
      // Paints the icon in the section between handler #i and the next one.
      _paintIcon(canvas, i);
    }
    // Initializes handlers' coordinates lists.
    handlerOffsets = List(handlerValues.length);
    handlerCenterOffsets = List(handlerValues.length);
    // Prints the handlers in the given order.
    for (int toBePrinted in printingOrder) {
      _paintHandler(canvas, toBePrinted);
    }
  }

  /// Prints the icon number [number] on the [canvas].
  ///
  /// [number] = 1 => prints the icon in the section between handler #1 and handler #2
  /// [number] = 2 => prints the icon in the section between handler #2 and handler #3
  /// [number] = 3 => prints the icon in the section between handler #3 and handler #4
  /// [number] = 4 => prints the icon in the section between handler #4 and handler #1.
  void _paintIcon(Canvas canvas, int number) {
    double adj = 3.0;
    TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    // Dimension of the icons.
    double iconDim = sliderStrokeWidth - 8.0;
    // Prints the icon in the section between handler #1 and handler #2.
    Offset pos = radiansToCoordinates(
        center, (-pi / 2 + angles[number] + sweepAngles[number] / 2), radius);
    // Recalculates position for printing the icon in the center of the slider.
    pos = Offset(pos.dx - sliderStrokeWidth / 3 - adj,
        pos.dy - sliderStrokeWidth / 3 - adj);
    // Icon.
    var icon = handlerValues[number]['icon'] ??
        defaultIcons[handlerValues[number]['temp']];
    // TextPainter settings.
    textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(fontSize: iconDim, fontFamily: icon.fontFamily));
    // Calculates the distance between handler #number and the next one.
    var distance = _distanceHandlerValues(handlerValues[number]['value'],
        handlerValues[(number + 1) % handlerValues.length]['value']);
    if (distance < 5) {
      if (distance > 2) {
        // We need to manage icon dimension and printing position.
        pos = radiansToCoordinates(center,
            (-pi / 2 + angles[number] + sweepAngles[number] / 2), radius);
        // Recalculates printing position in relation to the distance between handlers(= the space available
        // for icon printing).
        pos = Offset(pos.dx - sliderStrokeWidth / 3 + (5 - distance),
            pos.dy - sliderStrokeWidth / 3 + (5 - distance));
        // TextPainter settings with new dimension for the icon.
        textPainter.text = TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
                fontSize: iconDim * (distance / 5),
                fontFamily: icon.fontFamily));
      } else
        return; // Don't print the icon, too little space.
    }
    // Prints the icon on the canvas.
    textPainter.layout();
    textPainter.paint(canvas, pos);
  }

  /// Calculates and returns the number of sectors between tha value of
  /// the first handler[fHandler] and second handler[sHandler] given.
  int _distanceHandlerValues(int fHandler, sHandler) {
    int distance = 0;
    while ((fHandler + distance) % divisions != sHandler) {
      distance++;
    }
    return distance;
  }

  /// Prints the handle #[number] on the given [canvas].
  void _paintHandler(Canvas canvas, int number) {
    handlerRadius = handlerOutterRadius - 1.0;
    // Stroke configuration for the line that connects slider and handler.
    Paint handlerLinePaint = _getPaint(color: Colors.black, width: 2.0);
    // Stroke configuration for the handler.
    Paint handler = _getPaint(color: handlerColor, style: PaintingStyle.fill);
    // Stroke configuration for the outter circle of the handler.
    Paint handlerOutter = _getPaint(
        color: Colors.black26, width: 2.0, style: PaintingStyle.stroke);

    // Font size of the time painted inside handlers.
    double fontSize = handlerRadius - handlerRadius / 4 - 1;
    double xGap = handlerRadius / 2 + 6;
    double yGap = handlerRadius / 2 - 2;

    var offsets;
    double adjustment;

    // Gets List<Offset> with handler coordinates.
    offsets = _getHandlerCoordinates(angles[number]);
    // Handler coordinates on the slider.
    handlerOffsets[number] = offsets[0];
    // Coordinates of the center of the handler.
    handlerCenterOffsets[number] = offsets[1];
    // Draws the line which connect the slider to the handler.
    canvas.drawLine(
        handlerOffsets[number],
        radiansToCoordinates(center, -pi / 2 + angles[number],
            radius + sliderStrokeWidth / 2 + 9.0),
        handlerLinePaint);
    // Draws the handler.
    canvas.drawCircle(handlerCenterOffsets[number], handlerRadius, handler);
    // Draws the handler outter circle.
    canvas.drawCircle(
        handlerCenterOffsets[number], handlerOutterRadius, handlerOutter);
    // We need to move the time on the right and on the left to center it in the handler.
    adjustment =
    formatTime(handlerValues[number]['value']).length == 4 ? 2.0 : -2.0;
    // Draws the time inside the handler.
    TextSpan span = new TextSpan(
        style: new TextStyle(color: Colors.black, fontSize: fontSize),
        text: formatTime(handlerValues[number]['value']));
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
        canvas,
        Offset(handlerCenterOffsets[number].dx - xGap + adjustment,
            handlerCenterOffsets[number].dy - yGap));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  /// Returns List<Offset> of length = 2:
  /// - [0] center of the handler on the slider radius
  /// - [1] center of the handler out of slider(to be used as center point to draw
  /// the handler.
  List<Offset> _getHandlerCoordinates(double handlerAngle) {
    return [
      radiansToCoordinates(
          center, -pi / 2 + handlerAngle, radius - sliderStrokeWidth / 2),
      radiansToCoordinates(center, -pi / 2 + handlerAngle,
          radius + sliderStrokeWidth + (handlerRadius / 3) * 2)
    ];
  }

  /// Returns a Paint object with the given options
  ///
  /// [color] Color of the stroke.
  /// [width] Width od the stroke.
  /// [style] Style of the stroke.
  Paint _getPaint({@required Color color, double width, PaintingStyle style}) =>
      Paint()
        ..color = color
        ..strokeCap = StrokeCap.butt
        ..style = style ?? PaintingStyle.stroke
        ..strokeWidth = width ?? sliderStrokeWidth;
}
