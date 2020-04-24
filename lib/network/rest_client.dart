import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thermo_widget/widget/utils.dart';

import 'network_exceptions.dart';

/// Converts the [hexString] into a binary string.
String _hexToBinary(String hexString) {
  String binaryString = '';
  for (int i = 0; i < hexString.length; i++) {
// Extracts string of binary digits corresponding to the hex digit.
    String binaryDigits = int.parse(hexString[i], radix: 16).toRadixString(2);
    if (binaryDigits.length < 4) {
// Adds zeros to the start of the string to obtain 4-digits binary string.
      for (int zeroToAdd = 4 - binaryDigits.length;
      zeroToAdd > 0;
      zeroToAdd--) {
        binaryDigits = '0' + binaryDigits;
      }
    }
    binaryString += binaryDigits;
  }
  return binaryString;
}

/// Converts the [binaryString] into a hex string.
String _binaryToHex(String binaryString) {
  String hexString = '';
  for (int i = 0; i <= binaryString.length - 4; i += 4) {
    String hexDigit = int.parse(binaryString.substring(i, i + 4), radix: 2)
        .toRadixString(16)
        .toUpperCase();
    hexString += hexDigit;
  }
  return hexString;
}

/// Extracts the handlers' values from the [binaryString] representing the day
/// configuration.
///
/// Returns a List<int> where:
/// [0] => handler #1 position
/// [1] => handler #2 position
/// [2] => handler #3 position
/// [3] => handler #4 position.
Map<int, Map<String, dynamic>> _getTimes(String binaryString) {

  List<Map<String, dynamic>> sections = [];
  for (int i = 0; i <= binaryString.length - 2; i += 2) {
    // A quarter of hour is represented by two binary digits.
    // substring() returns a string with the digits from position i to i + 2 - 1.
    String quarter = binaryString.substring(i, i + 2);
    switch (quarter) {
      case '00':  // T0
        if(sections.isEmpty && binaryString.substring(
            binaryString.length - 2, binaryString.length) !=
            quarter || sections.isNotEmpty && sections.last['temp'] != 'T0') {
          // Creates a new section.
          sections.add({
            'value': i ~/ 2,
            'temp': 'T0',
          });
        }
        break;
      case '01':  // T1
        if(sections.isEmpty && binaryString.substring(
            binaryString.length - 2, binaryString.length) !=
            quarter || sections.isNotEmpty && sections.last['temp'] != 'T1') {
          // Creates a new section.
          sections.add({
            'value': i ~/ 2,
            'temp': 'T1',
          });
        }
        break;
      case '10':  // T2
        if(sections.isEmpty && binaryString.substring(
            binaryString.length - 2, binaryString.length) !=
            quarter || sections.isNotEmpty && sections.last['temp'] != 'T2') {
          // Creates a new section.
          sections.add({
            'value': i ~/ 2,
            'temp': 'T2',
          });
        }
        break;
      case '11':  // T3
        if(sections.isEmpty && binaryString.substring(
            binaryString.length - 2, binaryString.length) !=
            quarter || sections.isNotEmpty && sections.last['temp'] != 'T3') {
          // Creates a new section.
          sections.add({
            'value': i ~/ 2,
            'temp': 'T3',
          });
        }
        break;
    }
  }
  Map<int, Map<String, dynamic>> dayMap = Map<int, Map<String, dynamic>>();
  for(int i = 0; i < sections.length; i++) {
    dayMap[i] = sections[i];
  }
  // TODO: eliminare dopo test.
  /*dayMap.forEach((key, info) {
    print('$key: ${formatTime(info['value'])}');
  });*/
  return dayMap;
}

class RestApiHelper {
  /// Shared preferences instance used for storing and retrieving toke info.
  static SharedPreferences sharedPref;

  /// Url to be used in GET token request.
  static const String tokenUrl =
      'https://devapi2.cameconnect.net/api/oauth/token';

  /// Url of the thermo Rest API
  static const String thermoApiUrl =
      'https://thermo-sandbox.cameconnect.net:8443';
  static const String getDevicesUrl = 'devices';
  static const String postDayConfigUrl = 'control';

  /// Returns JWT.
  ///
  /// It checks if a valid JWT is stored in shared preferences, if not it
  /// ask a new one from the server.
  static Future<String> _getToken() async {
    sharedPref = sharedPref ?? await SharedPreferences.getInstance();
    if (sharedPref.getString('token') != null &&
        sharedPref.getString('expiry_date') != null) {
      DateTime expiryDate = DateTime.parse(sharedPref.getString('expiry_date'));
      if (expiryDate.isAfter(DateTime.now())) {
        print("Shared preference token used");
        print(sharedPref.getString('token'));
        return sharedPref.getString('token');
      }
    }
    // There is not a valid token, so we need to request it.
    try {
      var httpResponse = await http.post(tokenUrl, headers: {
        'Authorization':
        'Basic ZmUyYjgwZmI1NTA5OTYxNDgwNTBmMDJmZGZjZTg0MTc6OGRjMTA3Zjc5NWQzNTRhODczYzdjOTlmYzVjZDc0ZDQ4ZmQ0NjhjMzU5MTM0ZGI1ZTg1MTk5YTg4ZGRjM2MzZmIwN2U4MmFhN2ZhY2U3NjhlOTc5MmMzMzU4YTQwMjBiMGM1YWI4MGQ1ZDZjNjViMTQ4MGMzNWJkMWJlN2JhYmFiMTFkZjhmODE0M2I0MTg2NmQ2ZmE5YWFmMjdkMTAxZjg5NmEzMmRhZTFjOTY2YWJhYWJlOGE0Mzk0NTYzZDFhOTc2NzRhYzI2OGNkOTA5ZmIzOGRkMGUxODE5NTBjNzJhNWJlMmE2N2FkODA0MWZkYjgwNjJiMmFmN2Y3MWE1Mg==',
        'Content-Type': 'application/x-www-form-urlencoded'
      }, body: {
        'username': 'candreola.ios',
        'password': 'cameRD2019',
        'grant_type': 'password',
      });
      Map<String, dynamic> jsonMap = _returnResponse(httpResponse);
      // Stores token and its expiry_date into Shared Preferences
      sharedPref.setString('token', jsonMap['access_token']);
      sharedPref.setString(
          'expiry_date',
          DateTime.now()
              .add(new Duration(seconds: jsonMap['expires_in']))
              .toString());
      // Returns the received token.
      print('New token used');
      sharedPref.getString('token');
      return jsonMap['access_token'] as String;
    } on SocketException {
      throw FetchDataException('No internet connection');
    }
  }

  /// Returns the device keycode.
  static Future<String> _getKeyCode() async {
    // Gets the list of available devices for the user.
    List<dynamic> devicesList = await getDevices();
    // Information about first available device.
    Map<String, dynamic> firstDevInfo = devicesList.first['items'].first;
    return firstDevInfo['keycode'] as String;
  }

  /// Checks http response status code to manage various exceptions.
  static dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      // OK.
      //print(json.decode(response.body));
        return json.decode(response.body);
      case 400:
      // Bad Request.
        throw BadRequestException(response.body);
      case 401:
      case 403:
      // No authorization.
        throw UnauthorisedException(response.body);
      case 500:
      // Server error.
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }

  /// Returns the list of available devices for the user.
  static Future<List<dynamic>> getDevices() async {
    String token = await _getToken();
    try {
      var httpResponse =
      await http.get('$thermoApiUrl/$getDevicesUrl', headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      // Extract json body from the response.
      List<dynamic> jsonList = _returnResponse(httpResponse);
      return jsonList;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  /// Sends the temperature configuration [binaryDay] for day [dayNumber] in
  /// mode [season] to the server.
  ///
  /// The temperature configuration [binaryDay] is converted into hexadecimal
  /// string before the sending.
  static Future<bool> sendDayConfig(
      String binaryDay, int dayNumber, String season) async {
    // Converts the configuration into hexadecimal string.
    String hexDay = _binaryToHex(binaryDay);
    // TODO: eliminare dopo testing
    print('Sending day: $hexDay');
    Map expectedPositions = _getTimes(binaryDay);
    print('Test con binary:');
    expectedPositions.forEach((handlerNumber, info) {
      print('#$handlerNumber : ${formatTime(info['value'])}');
    });
    expectedPositions = _getTimes(_hexToBinary(hexDay));
    print('Test con hex:');
    expectedPositions.forEach((handlerNumber, info) {
      print('#$handlerNumber : ${formatTime(info['value'])} ${info['temp']}');
    });

    // Gets token and keycode.
    String token = await _getToken();
    String keycode = await _getKeyCode();
    try {
      var httpResponse =
      await http.post('$thermoApiUrl/$postDayConfigUrl/$keycode/$keycode',
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            '$season.day$dayNumber': hexDay,
          }));
      Map<String, dynamic> bodyResponse = _returnResponse(httpResponse);
      print('${DateTime.now().toString()} ${bodyResponse['ok']}');
      return bodyResponse['ok'] as bool;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  /// Returns the temperature configuration for the desired [dayNumber] in
  /// binary format in [season].
  static Future<Map<int, Map<String, dynamic>>> getDayConfig(int dayNumber, String season) async {
    List<dynamic> devicesList = await getDevices();
    Map<String, dynamic> firstDevInfo = devicesList.first['items'].first;
    Map<String, dynamic> weekConf = firstDevInfo[season];
    // TODO: eliminare dopo testing.
    print('Day received: ${weekConf['day$dayNumber'] as String}');
    print('Day received: ${_hexToBinary(weekConf['day$dayNumber'] as String)}');
    Map<int, Map<String, dynamic>> expectedPositions =
    _getTimes(_hexToBinary(weekConf['day$dayNumber'] as String));
    expectedPositions.forEach((handlerNumber, info) {
      print('#$handlerNumber : ${formatTime(info['value'])}');
    });
    /* ---  For local testing
    String testString = '101010101010101010101011111111111111111111111111111111111111111111111110101010101010101010101010101010101010101010101001010101010101010101010101010101010101010101010110101010101010101010101010';
    Map<int, Map<String, dynamic>> expectedPositions = _getTimes(testString);
    expectedPositions.forEach((key, info) {
      print('$key: ${formatTime(info['value'])}');
    });
    return expectedPositions;
  --- */
     // Converts the configuration into binary and sent back to the caller.
   return _getTimes(_hexToBinary(weekConf['day$dayNumber'] as String));
  }
}
