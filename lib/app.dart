import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thermo_widget/http_json_files/quarter.dart';

import 'http_json_files/rest_client.dart';

import 'widget_files/thermo_widget.dart';
import 'widget_files/utils.dart';

/// GLOBAL variables
final double minTemp = 4.0;
final double maxTemp = 30.0;

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
        '/': (context) => MyHomePage(),
        '/temperatures': (context) => TempPage(),
        '/widget': (context) => WidgetPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
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
            ListTile(
              title: Text('Widget Page'),
              onTap: () {
                // Update the state of the app.
                // ...
                // When a user opens the drawer, Flutter adds the drawer to
                //  the navigation stack.
                // Then close the drawer.
                Navigator.popAndPushNamed(context, '/widget');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Text('Home page'),
      ),
    );
  }
}

class TempPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TempPageState();
}

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

  Widget _managersTile() => Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      _tempManager(t1, () {
        if (double.parse((t1 - 0.1).toStringAsFixed(1)) >= minTemp)
          setState(() => t1 = double.parse((t1 - 0.1).toStringAsFixed(1)));
      }, () {
        if (t1 + 0.1 < t2)
          setState(() => t1 = double.parse((t1 + 0.1).toStringAsFixed(1)));
      }),
      _tempManager(t2, () {
        if (t2 - 0.1 > t1)
          setState(() => t2 = double.parse((t2 - 0.1).toStringAsFixed(1)));
      }, () {
        if (t2 + 0.1 < t3)
          setState(() => t2 = double.parse((t2 + 0.1).toStringAsFixed(1)));
      }),
      _tempManager(t3, () {
        if (t3 - 0.1 > t2)
          setState(() => t3 = double.parse((t3 - 0.1).toStringAsFixed(1)));
      }, () {
        if (t3 + 0.1 <= maxTemp)
          setState(() => t3 = double.parse((t3 + 0.1).toStringAsFixed(1)));
      }),
    ],
  );

  Widget _tempManager(
      double temperature, Function remFunction, Function addFunction) =>
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
      );
}

class WidgetPage extends StatefulWidget {

  final RestApiHelper _helper = RestApiHelper();

  @override
  State<StatefulWidget> createState() => _WidgetPageState();
}

class _WidgetPageState extends State<WidgetPage> {
  /// Color of the circle.
  final baseColor = Color.fromRGBO(255, 255, 255, 0.3);

  // 1 = 15 minutes , valid interval 0:95
  /// The value in which will be positioned the handler #1.
  /// The initial value of section #1 and end value of section #4.
  int firstTime = 0;

  /// The value in which will be positioned the handler #2.
  /// The initial value of section #2 and end value of section #1.
  int secondTime = 24;

  /// The value in which will be positioned the handler #3.
  /// The initial value of section #3 and end value of section #2.
  int thirdTime = 48;

  /// The value in which will be positioned the handler #4.
  /// The initial value of section #4 and end value of section #3.
  int fourthTime = 72;

  /// Time to be displayed inside the handler representing the time the user is
  /// selecting moving one of the handlers.
  String timeToPrint = '';

  @override
  void initState() {
    super.initState();
    widget._helper.getToken().then((token) => print(token));
  }

  /// Updates the widget times, the time to be displayed inside the slider(
  /// referring the handler is being moved) and re-build the widget by calling setState().
  ///
  /// [newFirstTime] Time selected by the handler #1.
  /// [newSecondTime] Time selected by the handler #2.
  /// [newThirdTime] Time selected by the handler #3.
  /// [newFourthTime] Time selected by the handler #4.
  void _updateLabels(int newFirstTime, int newSecondTime, int newThirdTime,
      int newFourthTime) {
    if (!(newFirstTime != firstTime &&
        newSecondTime != secondTime &&
        newThirdTime != thirdTime &&
        newFourthTime != fourthTime)) {
      if (newFirstTime != firstTime) {
        timeToPrint = formatTime(newFirstTime);
      } else if (newSecondTime != secondTime) {
        timeToPrint = formatTime(newSecondTime);
      } else if (newThirdTime != thirdTime) {
        timeToPrint = formatTime(newThirdTime);
      } else if (newFourthTime != fourthTime) {
        timeToPrint = formatTime(newFourthTime);
      }
    }
    // Updates the state and makes the widget re-building.
    setState(() {
      firstTime = newFirstTime;
      secondTime = newSecondTime;
      thirdTime = newThirdTime;
      fourthTime = newFourthTime;
    });
  }

  /// Updates the widget times, hides the time displayed inside the slider
  /// and re-build the widget by calling setState().
  ///
  /// [newFirstTime] Time selected by the handler #1.
  /// [newSecondTime] Time selected by the handler #2.
  /// [newThirdTime] Time selected by the handler #3.
  /// [newFourthTime] Time selected by the handler #4.
  void _updateLabelsEnd(int newFirstTime, int newSecondTime, int newThirdTime,
      int newFourthTime) {
    timeToPrint = '';
    // T3 => first-second & third-fourth
    // T2 => second-third
    // T1 => fourth-first
    double t3 = 21;
    double t2 = 18;
    double t1 = 15;
    print('*** First section ***');
    for (int i = newFirstTime;
    _isIncluded(i, newFirstTime, (newSecondTime - 1) % 96);
    i = (++i) % 96) {
      //print("$i $newSecondTime");
      var quarter = Quarter(formatTime(i), formatTime((i + 1) % 96), t3);
      print(jsonEncode(quarter));
      //print(formatIntervalTime(i, (i+1)%96) + ': $t3 °C');
    }
    print('*** Second section ***');
    for (int i = newSecondTime;
    _isIncluded(i, newSecondTime, (newThirdTime - 1) % 96);
    i = (++i) % 96) {
      //print("$i $newThirdTime");
      var quarter = Quarter(formatTime(i), formatTime((i + 1) % 96), t1);
      print(jsonEncode(quarter));
      //print(formatIntervalTime(i, (i+1)%96) + ': $t2 °C');
    }
    print('*** Third section ***');
    for (int i = newThirdTime;
    _isIncluded(i, newThirdTime, (newFourthTime - 1) % 96);
    i = (++i) % 96) {
      //print("$i $newFourthTime");
      var quarter = Quarter(formatTime(i), formatTime((i + 1) % 96), t3);
      print(jsonEncode(quarter));
      //print(formatIntervalTime(i, (i+1)%96) + ': $t3 °C');
    }
    print('*** Fourth section ***');
    for (int i = newFourthTime;
    _isIncluded(i, newFourthTime, (newFirstTime - 1) % 96);
    i = (++i) % 96) {
      //print("$i $newFirstTime");
      var quarter = Quarter(formatTime(i), formatTime((i + 1) % 96), t2);
      print(jsonEncode(quarter));
      //print(formatIntervalTime(i, (i+1)%96) + ': $t1 °C');
    }

    // testHttp();
    // Updates the state and makes the widget re-building.
    setState(() {
      firstTime = newFirstTime;
      secondTime = newSecondTime;
      thirdTime = newThirdTime;
      fourthTime = newFourthTime;
    });
  }

  /// Checks if [value] is included in [prev] - [succ] range, extremes included.
  bool _isIncluded(int value, int prev, int succ) {
    if (succ < prev) {
      return (value >= prev && value >= succ) ||
          (value <= prev && value <= succ);
    }
    return value >= prev && value <= succ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Center(
          child: Container(
              child: TempSlider(
                96,
                0,
                24,
                48,
                72,
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
                      child: Text(timeToPrint,
                          // To view the intervals values use the comment below.
                          //'${_formatIntervalTime(initTime, endTime)} - ${_formatIntervalTime(endTime, initTime_2)} -  ${_formatIntervalTime(initTime_2, endTime_2)} - ${_formatIntervalTime(endTime_2, initTime)}',
                          style: TextStyle(fontSize: 18.0, color: Colors.black))),
                ),
              )),
        ));
  }
}
