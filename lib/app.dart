import 'package:flutter/material.dart';
import 'widget_files/thermo_widget.dart';
import 'widget_files/utils.dart';
import 'http_json_files/rest_client.dart';

import 'dart:math';

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
        '/': (context) => WidgetPage(),
        '/temperatures': (context) => TempPage(),
      },
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

  Widget _managersTile() =>
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _tempManager(t1, 'T1', Icons.work, Colors.deepPurple, () {
            if (double.parse((t1 - 0.1).toStringAsFixed(1)) >= minTemp)
              setState(() => t1 = double.parse((t1 - 0.1).toStringAsFixed(1)));
          }, () {
            if (t1 + 0.1 < t2)
              setState(() => t1 = double.parse((t1 + 0.1).toStringAsFixed(1)));
          }),
          _tempManager(t2, 'T2', Icons.brightness_3, Colors.brown[400], () {
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

  Widget _tempManager(double temperature, String text, IconData icon,
      Color color,
      Function remFunction, Function addFunction) =>
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

class WidgetPage extends StatefulWidget {

  final double height = 300.0;
  final double width = 300;

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

  Future<String> _dayFuture;

  @override
  void initState() {
    super.initState();
    // Initial load.
    _dayFuture = RestApiHelper.getDayConfig(1, 'winter');
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
      int newFourthTime) async {
    timeToPrint = '';
    // T3 => first-second & third-fourth
    // T1 => second-third
    // T2 => fourth-first
    String binaryDay = _calculatesBinaryDay(
        newFirstTime, newSecondTime, newThirdTime, newFourthTime);

    print('Length: ${binaryDay.length}, String: $binaryDay');
    print(binaryToHex(binaryDay));
    // Send changes to the server.
    // TODO: decommentare dopo sistemazione
     RestApiHelper.sendDayConfig(binaryDay, 1, 'winter');
    // Updates the state and makes the widget re-building.
    setState(() {
      firstTime = newFirstTime;
      secondTime = newSecondTime;
      thirdTime = newThirdTime;
      fourthTime = newFourthTime;
    });
  }

  /// Returns the binary string representing the day configuration using the
  /// handlers' value([firstTime],[secondTime],[thirdTime],[fourthTime]).
  String _calculatesBinaryDay(int firstTime, int secondTime, int thirdTime,
      int fourthTime) {
    String binaryDay = '';
    for (int i = 0; i <= 95; i++) {
      if (_isIncluded(i, firstTime, (secondTime - 1) % 96)) {
        binaryDay += '11';
      } else if (_isIncluded(i, secondTime, (thirdTime - 1) % 96)) {
        binaryDay += '01';
      } else if (_isIncluded(i, thirdTime, (fourthTime - 1) % 96)) {
        binaryDay += '11';
      } else {
        binaryDay += '10';
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

  List<int> _getTimes(String binaryString){
    Map<String, int> t3Section = Map();
    Map<String, int> t3Section2 = Map();
    Map<String, int> t2Section = Map();
    Map<String, int> t1Section = Map();

    for(int i = 0; i <= binaryString.length - 2; i += 2){
      String quarter = binaryString.substring(i, i + 2);
      switch(quarter){
        case '11':
          if(t3Section['start'] == null || t3Section['finish'] == null){
            //
            if(t3Section['start'] == null){
              if(i == 0 && binaryString.substring(binaryString.length - 2,binaryString.length) == quarter){
                int j = binaryString.length - 2;
                while(binaryString.substring(j - 2,j) == quarter){
                  j -= 2;
                }
                t3Section['start'] = j ~/ 2;
              } else{
                t3Section['start'] = i ~/ 2;
              }
            }
            if(i + 2 <= (binaryString.length - 2) && binaryString.substring(i + 2, i + 4)!= quarter) {
              t3Section['finish'] = i ~/ 2;
            } else if(i + 2 > (binaryString.length - 2)){
              t3Section['finish'] = (binaryString.length - 2) ~/2;
            }
          } else {
            if(t3Section2['start'] == null){
              if(i == 0 && binaryString.substring(binaryString.length - 2,binaryString.length) == quarter){
                int j = binaryString.length - 2;
                while(binaryString.substring(j - 2,j) == quarter){
                  j -= 2;
                }
                t3Section2['start'] = j ~/ 2;
              } else{
                t3Section2['start'] = i ~/ 2;
              }
            }
            if(i + 2 <= (binaryString.length - 2) && binaryString.substring(i + 2, i + 4)!= quarter) {
              t3Section2['finish'] = i ~/ 2;
            } else if(i + 2 > (binaryString.length - 2)){
              t3Section2['finish'] = (binaryString.length - 2) ~/2;
            }
          }
          break;
        case '10':
          if(t2Section['start'] == null) {
            if(i == 0 && binaryString.substring(binaryString.length - 2,binaryString.length) == quarter){
              int j = binaryString.length - 2;
              while(binaryString.substring(j - 2,j) == quarter){
                j -= 2;
              }
              t2Section['start'] = j ~/ 2;
            } else{
              t2Section['start'] = i ~/ 2;
            }
          }
          if(i + 2 <= (binaryString.length - 2) && binaryString.substring(i + 2, i + 4)!= quarter) {
            t2Section['finish'] = i ~/ 2;
          } else if(i + 2 > (binaryString.length - 2)){
            t2Section['finish'] = (binaryString.length - 2) ~/2;
          }
          break;
        case '01':
          if(t1Section['start'] == null) {
            if(i == 0 && binaryString.substring(binaryString.length - 2,binaryString.length) == quarter){
              int j = binaryString.length - 2;
              while(binaryString.substring(j - 2,j) == quarter){
                j -= 2;
              }
              t1Section['start'] = j ~/ 2;
            } else{
              t1Section['start'] = i ~/ 2;
            }
            t1Section['start'] = i ~/ 2;
          }
          if(i + 2 <= (binaryString.length - 2) && binaryString.substring(i + 2, i + 4)!= quarter) {
            t1Section['finish'] = i ~/ 2;
          } else if(i + 2 > (binaryString.length - 2)){
            t1Section['finish'] = (binaryString.length - 2) ~/2;
          }
          break;
      }
    }
    print('t3 section: ${t3Section.toString()}');
    print('t3 section: ${t3Section2.toString()}');
    print('t2 section: ${t2Section.toString()}');
    print('t1 section: ${t1Section.toString()}');
    int firstTime, secondTime, thirdTime, fourthTime;
    if((t3Section['finish'] + 1) % 96 == t1Section['start']) {
      firstTime = t3Section['start'];
      thirdTime = t3Section2['start'];
    } else {
      firstTime = t3Section2['start'];
      thirdTime = t3Section['start'];
    }
    secondTime = t1Section['start'];
    fourthTime = t2Section['start'];
    return [firstTime, secondTime, thirdTime, fourthTime];
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
      //backgroundColor: Colors.white70,
      body: FutureBuilder<String>(
        future: _dayFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Errore: ${snapshot.error}'),
              );
            }
            // Calculates handlers' position.
            List<int> times = _getTimes(snapshot.data);
            print(times);
            return Container(
              decoration: BoxDecoration(
                /*gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromRGBO(0, 176, 237, 1),
                      Color.fromRGBO(0, 176, 237, 0.3)
                    ],
                    stops: [0.2, 0.9],
                  )*/
                  gradient: RadialGradient(
                    center: Alignment.center,
                    colors: [
                      Color.fromRGBO(0, 176, 237, 1),
                      Color.fromRGBO(0, 176, 237, 0.3)
                    ],
                    radius: 0.9,
                    stops: [0.4, 0.9],
                  )
              ),
              child: Center(
                child: Container(
                    child: TempSlider(
                      96,
                      /*12,
                      36,
                      60,
                      84,*/
                      times[0],
                      times[1],
                      times[2],
                      times[3],
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
                            child: Text(timeToPrint,
                                // To view the intervals values use the comment below.
                                //'${_formatIntervalTime(initTime, endTime)} - ${_formatIntervalTime(endTime, initTime_2)} -  ${_formatIntervalTime(initTime_2, endTime_2)} - ${_formatIntervalTime(endTime_2, initTime)}',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black))),
                      ),
                    )),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
