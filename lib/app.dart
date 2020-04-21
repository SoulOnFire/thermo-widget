import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:thermo_widget/widget/hour_painter.dart';
import 'widget/thermo_widget.dart';
import 'widget/utils.dart';
import 'network/rest_client.dart';

/// GLOBAL variables
final double minTemp = 4.0;
final double maxTemp = 30.0;

/// Dart entrypoint.
void main() => runApp(MyApp());

/// Simple app displaying a page with the Thermo widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WidgetPage(),
        '/temperatures': (context) => TempPage(),
      },
    );
  }
}

/// Page displaying the T1,T2,T3 values.
class TempPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TempPageState();
}

/// State for TempPage page.
class _TempPageState extends State<TempPage> {
  double t1 = 16.8;
  double t2 = 17.0;
  double t3 = 17.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Temperatures'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _managersTile(),
    );
  }

  /// Widget which displays actual T1,T2,T3 values and make it possible to change
  /// them.
  Widget _managersTile() =>
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _tempManager(t1, 'T1', Icons.brightness_3, Colors.brown[400], () {
            if (double.parse((t1 - 0.1).toStringAsFixed(1)) >= minTemp)
              setState(() => t1 = double.parse((t1 - 0.1).toStringAsFixed(1)));
          }, () {
            if (t1 + 0.1 < t2)
              setState(() => t1 = double.parse((t1 + 0.1).toStringAsFixed(1)));
          }),
          _tempManager(t2, 'T2', Icons.work, Colors.deepPurple, () {
            if (t2 - 0.1 > t1)
              setState(() => t2 = double.parse((t2 - 0.1).toStringAsFixed(1)));
          }, () {
            if (t2 + 0.1 < t3)
              setState(() => t2 = double.parse((t2 + 0.1).toStringAsFixed(1)));
          }),
          _tempManager(t3, 'T3', Icons.home, Colors.amber, () {
            if (t3 - 0.1 > t2)
              setState(() => t3 = double.parse((t3 - 0.1).toStringAsFixed(1)));
          }, () {
            if (t3 + 0.1 <= maxTemp)
              setState(() => t3 = double.parse((t3 + 0.1).toStringAsFixed(1)));
          }),
        ],
      );

  /// Widget for managing one of the temperatures.
  Widget _tempManager(double temperature, String text, IconData icon,
      Color color, Function remFunction, Function addFunction) =>
      Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          border: Border.all(
            width: 3.0,
            color: color,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(text),
                Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Icon(icon, color: color),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.remove),
                  tooltip: 'Decrease temperature by 0.1',
                  onPressed: remFunction,
                ),
                Text(temperature.toString()),
                IconButton(
                  icon: Icon(Icons.add),
                  tooltip: 'Increase temperature by 0.1',
                  onPressed: addFunction,
                ),
              ],
            ),
          ],
        ),
      );
}

/// Page displaying the Thermo widget.
class WidgetPage extends StatefulWidget {
  final double height = 300.0;
  final double width = 300;

  @override
  State<StatefulWidget> createState() => _WidgetPageState();
}

/// State for WidgetPage page.
class _WidgetPageState extends State<WidgetPage> {
  /// Color of the circle.
  final baseColor = Color.fromRGBO(255, 255, 255, 0.3);

  // 1 = 15 minutes , valid interval 0:95

  /// Time to be displayed inside the handler representing the time the user is
  /// selecting moving one of the handlers.
  String timeToPrint = '';

  /// List of int values corresponding to the handler positions(using values 0:95)
  ///
  /// [0] => handler #1 position
  /// [1] => handler #2 position
  /// [2] => handler #3 position
  /// [3] => handler #4 position.
  Future<List<int>> _dayFuture;

  Map<int, Map<String, dynamic>> handlerValues = {
    0 : {
      'value' : 6,
      'color': Colors.brown,
      'temp': 'T1',
    },
    1 : {
      'value' : 24,
      'color': Colors.amber,
      'temp': 'T2',
    },
    2 : {
      'value' : 36,
      'color': Colors.deepPurple,
      'temp': 'T3',
    },
    3 : {
      'value': 60,
      'color': Colors.blue,
      'temp': 'T2',
    }
  };

  @override
  void initState() {
    super.initState();
    // Download actual day configuration and returns the future.
    //_dayFuture = RestApiHelper.getDayConfig(1, 'winter');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Center(child: Text('Thermo App')),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Temperature Page'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  // When a user opens the drawer, Flutter adds the drawer to
                  //  the navigation stack.
                  // Then close the drawer.
                  Navigator.popAndPushNamed(context, '/temperatures');
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text('Your day configuration'),
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                colors: [
                  Color.fromRGBO(0, 176, 237, 1),
                  Color.fromRGBO(0, 176, 237, 0.3)
                ],
                radius: 0.9,
                stops: [0.4, 0.9],
              )),
          child: Center(
            child: Container(
                child: TempSlider(
                  96,
                  handlerValues,
                  height: widget.height,
                  width: widget.width,
                  primarySectors: 24,
                  secondarySectors: 96,
                  baseColor: baseColor,
                  hoursColor: Colors.greenAccent,
                  handlerColor: Colors.white,
                  onSelectionChange: _updateLabels,
                  onSelectionEnd: _updateLabelsEnd,
                  sliderStrokeWidth: 36,
                  child: Padding(
                    padding: const EdgeInsets.all(42.0),
                    child: Center(
                      /*child: Text(timeToPrint,
                                // To view the intervals values use the comment below.
                                //'${_formatIntervalTime(initTime, endTime)} - ${_formatIntervalTime(endTime, initTime_2)} -  ${_formatIntervalTime(initTime_2, endTime_2)} - ${_formatIntervalTime(endTime_2, initTime)}',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black))),*/
                      child: CustomPaint(painter: HourPainter(timeToPrint)),
                    ),
                  ),
                )),
          ),
        ),
    );
      /*FutureBuilder<List<int>>(
        future: _dayFuture,
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // The request has been completed.
            if (snapshot.hasError) {
              // The request got an error.
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            // The request completed without errors.
            return Container(
              decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    colors: [
                      Color.fromRGBO(0, 176, 237, 1),
                      Color.fromRGBO(0, 176, 237, 0.3)
                    ],
                    radius: 0.9,
                    stops: [0.4, 0.9],
                  )),
              child: Center(
                child: Container(
                    child: TempSlider(
                      96,
                      // Initial handlers' values loaded from the server.
                      snapshot.data[0],
                      snapshot.data[1],
                      snapshot.data[2],
                      snapshot.data[3],
                      height: widget.height,
                      width: widget.width,
                      primarySectors: 24,
                      secondarySectors: 96,
                      baseColor: baseColor,
                      hoursColor: Colors.greenAccent,
                      handlerColor: Colors.white,
                      onSelectionChange: _updateLabels,
                      onSelectionEnd: _updateLabelsEnd,
                      sliderStrokeWidth: 36,
                      child: Padding(
                        padding: const EdgeInsets.all(42.0),
                        child: Center(
                          /*child: Text(timeToPrint,
                                // To view the intervals values use the comment below.
                                //'${_formatIntervalTime(initTime, endTime)} - ${_formatIntervalTime(endTime, initTime_2)} -  ${_formatIntervalTime(initTime_2, endTime_2)} - ${_formatIntervalTime(endTime_2, initTime)}',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black))),*/
                          child: CustomPaint(painter: HourPainter(timeToPrint)),
                        ),
                      ),
                    )),
              ),
            );
          } else {
            // The request has not yet been completed.
            return Container(
              decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    colors: [
                      Color.fromRGBO(0, 176, 237, 1),
                      Color.fromRGBO(0, 176, 237, 0.3)
                    ],
                    radius: 0.9,
                    stops: [0.4, 0.9],
                  )),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          }
        },
      ),
    );*/
  }

  /// Checks if oldMap[i]['value'] is equal to newMap[i]['value'] for each i.
  bool _areAllValuesDifferent(Map<int, Map<String, dynamic>> oldMap, Map<int, Map<String, dynamic>> newMap) {
    for(int i = 0; i < oldMap.length; i++) {
      if(oldMap[i]['value'] == newMap[i]['value']) return false;
    }
    return true;
  }

  /// Updates the widget times, the time to be displayed inside the slider(
  /// referring the handler is being moved) and re-build the widget by calling setState().
  ///
  /// [newMap] is the map containing updated handler values.
  void _updateLabels(Map<int, Map<String, dynamic>> newMap) {
    if(!_areAllValuesDifferent(handlerValues, newMap)) {
      // If the user is not moving all the crown.
      for(int i = 0; i < handlerValues.length; i++) {
        if(handlerValues[i]['value'] != newMap[i]['value']) {
          // Display time of the handler which is being moved.
          timeToPrint = formatTime(newMap[i]['value']);
          break;
        }
      }
    }
    // Updates the state and makes the widget re-building.
    setState(() {
      handlerValues = newIdenticalMap(newMap);
    });
  }

  /// Updates the widget times, hides the time displayed inside the slider
  /// and re-build the widget by calling setState().
  ///
  /// [newMap] is the map containing updated handler values.
  void _updateLabelsEnd(Map<int, Map<String, dynamic>> newMap) async{
    timeToPrint = '';
    String binaryDay = _calculatesBinaryDay(newMap);
    print('Sending string: $binaryDay\nLength: ${binaryDay.length}');
    // Send changes to the server.
    //RestApiHelper.sendDayConfig(binaryDay, 1, 'winter');
    // Updates the state and makes the widget re-building.
    setState(() {
      handlerValues = newIdenticalMap(newMap);
    });

  }

  /// Returns the binary string representing the day configuration using the
  /// handlers' value([firstTime],[secondTime],[thirdTime],[fourthTime]).
  String _calculatesBinaryDay(Map<int, Map<String, dynamic>> map) {
    String binaryDay = '';
    for (int i = 0; i <= 95; i++) {
      // We check for each value in which sections is inserted.
      for(int j = 0; j < map.length; j++) {
        if(_isIncluded(i, map[j]['value'], (map[(j + 1) % map.length]['value'] - 1) % 96)) {
          switch (map[j]['temp']) {
            case 'T0' :
              binaryDay += '00';
              break;
            case 'T1' :
              binaryDay += '01';
              break;
            case 'T2' :
              binaryDay += '10';
              break;
            case 'T3' :
              binaryDay += '11';
              break;
          }
          // We found the section in which the value is included and added is
          // code to the string. so stop the internal for loop.
          break;
        }
      }
    }
    return binaryDay;
  }

  /// Checks if [value] is included in [prev] - [succ] range, extremes included.
  bool _isIncluded(int value, int prev, int succ) {
    if (succ < prev) {
      return (value >= prev && value >= succ) ||
          (value <= prev && value <= succ);
    }
    return value >= prev && value <= succ;
  }
}
