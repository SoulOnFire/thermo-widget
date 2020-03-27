import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'network_exceptions.dart';

class RestApiHelper {

  SharedPreferences sharedPref;

  /// Url to be used in GET token request.
  final String tokenUrl = 'https://devapi2.cameconnect.net/api/oauth/token';

  /// Url of the thermo Rest API
  final String thermoApiUrl = 'https://thermo-sandbox.cameconnect.net:8443';
  final String getDevicesUrl = 'devices';
  final String postDayConfigUrl = 'control';

  final String keycode = '67238978E4E70C2C';

  final String testResponse = '''[
  {
  "_id": "5e627b640ff7cd0011c6602b",
  "system": true,
  "user": "user.cameconnect",
  "name": "THs",
  "items": [
  {
  "keycode": "67238978E4E70C2C",
  "devcode": "67238978E4E70C2C",
  "cameconnect": {
  "Keycode": "67238978E4E70C2C",
  "Description": "TH700WiFi",
  "ProductTypeId": 20,
  "ProductTypeName": "TH/700"
  },
  "Description": "TH700WiFi",
  "ProductTypeId": 20,
  "_id": "5e627da3e179beefc50ddcf8",
  "Compile time": "Jul 10 2019 10:06:14",
  "Global FW Version": "1.00.001",
  "Slot": 1052672,
  "WiFi FW Version": "1.00.001",
  "on_line": 0,
  "updatedAt": "2020-03-24T17:24:40.737Z",
  "chunk_rate": 1,
  "chunk_size": 1024,
  "crc32": "E25098DB",
  "error": "None",
  "page_max": 512,
  "page_size": 4096,
  "algo": {
  "PI_band": 1.7,
  "T_cycle": 30,
  "T_off_min": 4,
  "T_on_min": 4,
  "n_prog": 4,
  "t_diff": 0.7,
  "type": "diff"
  },
  "comfort_state": false,
  "current_season": "summer",
  "hum_loc": 45,
  "manual_temp": 30,
  "mode": "manual",
  "relay_status": 0,
  "st_fw_version": "V1.00.001",
  "temp_loc": 19.2,
  "winter": {
  "T0": 3.4,
  "T1": 16.29,
  "T2": 18.2,
  "T3": 20.1,
  "day1": "555555555555FFFF555555FFFFAAAAAAAAFFFFFFFFFF5555",
  "day2": "555555555555FFFF555555FFFFAAAAAAAAFFFFFFFFFF5555",
  "day3": "555555555555FFFF555555FFFFAAAAAAAAFFFFFFFFFF5555",
  "day4": "555555555555FFFF555555FFFFAAAAAAAAFFFFFFFFFF5555",
  "day5": "555555555555FFFF555555FFFFEAAAAAAAFFFFFFFFFF5555",
  "day6": "55555555555555FFFFFFFFFFFFFFAAAAAAFFFFFFFFFF5555",
  "day7": "55555555555555FFFFFFFFFFFFFFAAAAAAFFFFFFFFFF5555"
  },
  "boost_level": 3,
  "boost_rem_minutes": 0,
  "buzzer": true,
  "holiday_days": 3,
  "holiday_rem_days": 0,
  "keyboard_lock": false,
  "set_point_temp": 30,
  "stdby_mode": "proximity",
  "summer": {
  "T1": 23.9,
  "T2": 25.9,
  "T3": 27.9,
  "day1": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
  "day2": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
  "day3": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
  "day4": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
  "day5": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
  "day6": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
  "day7": "FFFFFFFFFFFF55555555555555555555555555555555FFFF"
  },
  "automatic_hour_change": true,
  "light_skin": false,
  "max_temp": 35,
  "min_temp": 3,
  "offset_temp": 0,
  "t_threshold_high": 0,
  "t_threshold_low": 0,
  "alarm_h_low": false,
  "alarm_t_high": false,
  "alarm_t_low": false,
  "h_threshold_enable": false,
  "h_threshold_high": 134260089,
  "h_threshold_low": 134260059,
  "t_threshold_enable": false,
  "alarm_h_high": false
  }
  ],
  "sceneries": [
  {
  "_id": "5e627b640ff7cd0011c6602d",
  "name": "Esco di casa",
  "name_translated": "scenery_1",
  "actions": [],
  "group_id": "5e627b640ff7cd0011c6602b"
  },
  {
  "_id": "5e627b640ff7cd0011c6602f",
  "name": "Sto in casa",
  "name_translated": "scenery_2",
  "actions": [],
  "group_id": "5e627b640ff7cd0011c6602b"
  },
  {
  "_id": "5e627b640ff7cd0011c66031",
  "name": "Vado a letto",
  "name_translated": "scenery_3",
  "actions": [],
  "group_id": "5e627b640ff7cd0011c6602b"
  }
  ]
}
]''';

  Future<String> _getToken() async {
    sharedPref = sharedPref ?? await SharedPreferences.getInstance();
    if(sharedPref.getString('token') != null && sharedPref.getString('expiry_date') != null){
      DateTime expiryDate = DateTime.parse(sharedPref.getString('expiry_date'));
      if(expiryDate.isAfter(DateTime.now())) return sharedPref.getString('token');
    }
    // There is not a valid token, so we need to request it.
    try {
      var httpResponse = await http.post(tokenUrl, headers: {
        'Authorization':
        'Basic ZmUyYjgwZmI1NTA5OTYxNDgwNTBmMDJmZGZjZTg0MTc6OGRjMTA3Zjc5NWQzNTRhODczYzdjOTlmYzVjZDc0ZDQ4ZmQ0NjhjMzU5MTM0ZGI1ZTg1MTk5YTg4ZGRjM2MzZmIwN2U4MmFhN2ZhY2U3NjhlOTc5MmMzMzU4YTQwMjBiMGM1YWI4MGQ1ZDZjNjViMTQ4MGMzNWJkMWJlN2JhYmFiMTFkZjhmODE0M2I0MTg2NmQ2ZmE5YWFmMjdkMTAxZjg5NmEzMmRhZTFjOTY2YWJhYWJlOGE0Mzk0NTYzZDFhOTc2NzRhYzI2OGNkOTA5ZmIzOGRkMGUxODE5NTBjNzJhNWJlMmE2N2FkODA0MWZkYjgwNjJiMmFmN2Y3MWE1Mg==',
        'Content-Type': 'application/x-www-form-urlencoded'
      }, body: {
        'username': 'user.cameconnect',
        'password': 'cameRD2019',
        'grant_type': 'password',
      });
      Map<String, dynamic> jsonMap = _returnResponse(httpResponse);
      // Stores token and its expiry_date into Shared Preferences
      sharedPref.setString('token', jsonMap['access_token']);
      sharedPref.setString('expiry_date', DateTime.now().add(new Duration(seconds: jsonMap['expires_in'])).toString());
      return jsonMap['access_token'];
    } on SocketException {
      throw FetchDataException('No internet connection');
    }
  }

  Future<String> _getKeyCode() async{
    sharedPref = sharedPref ?? await SharedPreferences.getInstance();
    if(sharedPref.getString('keycode') != null){

    }
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        print(json.decode(response.body));
        return json.decode(response.body);
      case 400:
        throw BadRequestException(response.body);
      case 401:
      case 403:
        throw UnauthorisedException(response.body);
      case 500:
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getDevices() async {
    String token = await _getToken();
    try {
      /*
      var httpResponse = await http.get(thermoApiUrl + getDevicesUrl, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      dynamic jsonResponse = _returnResponse(httpResponse);*/
      List<dynamic> jsonMap = json.decode(testResponse);
      return jsonMap;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  void sendDayConfig(String binaryDay, int dayNumber, String season) async {
    String hexDay = _binaryToHex(binaryDay);
    String token = await _getToken();
    try {
      var httpResponse = await http
          .post('$thermoApiUrl/$postDayConfigUrl/$keycode/$keycode', headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }, body: {
        '$season.day$dayNumber': hexDay,
      });
      dynamic jsonResponse = _returnResponse(httpResponse);
      print('POST sendDayConfig: $jsonResponse');
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<String> getDayConfig(int dayNumber, String season) async {

  }

  String _hexToBinary(String hexString) {
    String binaryString = '';
    for (int i = 0; i < hexString.length; i++) {
      // Extract string of binary digits corresponding to the hex digit.
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

/*
  --- RISPOSTA Get Token
  {
    "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJDbGllbnRVcmkiOiJjYW1lY29ubmVjdC5uZXQ6ZmUyYjgwZmI1NTA5OTYxNDgwNTBmMDJmZGZjZTg0MTciLCJhdWQiOltdLCJleHAiOjE1ODUxMzIyMjIsImlhdCI6MTU4NTEyNTAyMiwiaXNzIjoiQ2FtZV9Db25uZWN0IiwianRpIjoiZDkzODJiNTQtMGExNC00YTUzLTkzOTktMmY5OWU2NzM2ZDExIiwicGVybWlzc2lvbnMiOiJVU0VSIiwic2NwIjpbXSwic3ViIjoidXNlci5jYW1lY29ubmVjdCIsInVzZXJpZCI6MTAxMSwidXNlcm5hbWUiOiJ1c2VyLmNhbWVjb25uZWN0In0.I47GRwBO2KpJCkZsCGTqWHwEpycSid-EivumWAZbGDfus4ZtX2MF74uIVfPDMqRm38Dx7S5Q63PL-fqe9L5Q9vrFJ71yG9mw-nk9RFaWDMg60ka7j0hv9wu3XvFxP81qUK6dWuNEuF4mPCZesM6Wo9JYUimrx7ffvyJqtbCEOfn-0JkSC1CdY3dZoq8YN40WekG_e3bGRerNn4Uz8t_6NDi_ty7HwTjhuqNcMBJ7fqJJCdylsyRsPP8B2im8dPrtj5bgMS_6KnjCoFRWh-Bz_7KZooo7ho4HNTMLvFQQGfsR4xT_tVDy5BJyWI-K6F3-TIlFH810NbcKl1DBkMqpog",
    "expires_in": 7199,
    "scope": "",
    "token_type": "bearer"
}
 ---- RISPOSTA GET  Devices
 [
    {
        "_id": "5e627b640ff7cd0011c6602b",
        "system": true,
        "user": "user.cameconnect",
        "name": "THs",
        "items": [
            {
                "keycode": "67238978E4E70C2C",
                "devcode": "67238978E4E70C2C",
                "cameconnect": {
                    "Keycode": "67238978E4E70C2C",
                    "Description": "TH700WiFi",
                    "ProductTypeId": 20,
                    "ProductTypeName": "TH/700"
                },
                "Description": "TH700WiFi",
                "ProductTypeId": 20,
                "_id": "5e627da3e179beefc50ddcf8",
                "Compile time": "Jul 10 2019 10:06:14",
                "Global FW Version": "1.00.001",
                "Slot": 1052672,
                "WiFi FW Version": "1.00.001",
                "on_line": 0,
                "updatedAt": "2020-03-24T17:24:40.737Z",
                "chunk_rate": 1,
                "chunk_size": 1024,
                "crc32": "E25098DB",
                "error": "None",
                "page_max": 512,
                "page_size": 4096,
                "algo": {
                    "PI_band": 1.7,
                    "T_cycle": 30,
                    "T_off_min": 4,
                    "T_on_min": 4,
                    "n_prog": 4,
                    "t_diff": 0.7,
                    "type": "diff"
                },
                "comfort_state": false,
                "current_season": "summer",
                "hum_loc": 45,
                "manual_temp": 30,
                "mode": "manual",
                "relay_status": 0,
                "st_fw_version": "V1.00.001",
                "temp_loc": 19.2,
                "winter": {
                    "T0": 3.4,
                    "T1": 16.29,
                    "T2": 18.2,
                    "T3": 20.1,
                    "day1": "555555555555FFFF555555FFFFAAAAAAAAFFFFFFFFFF5555",
                    "day2": "555555555555FFFF555555FFFFAAAAAAAAFFFFFFFFFF5555",
                    "day3": "555555555555FFFF555555FFFFAAAAAAAAFFFFFFFFFF5555",
                    "day4": "555555555555FFFF555555FFFFAAAAAAAAFFFFFFFFFF5555",
                    "day5": "555555555555FFFF555555FFFFEAAAAAAAFFFFFFFFFF5555",
                    "day6": "55555555555555FFFFFFFFFFFFFFAAAAAAFFFFFFFFFF5555",
                    "day7": "55555555555555FFFFFFFFFFFFFFAAAAAAFFFFFFFFFF5555"
                },
                "boost_level": 3,
                "boost_rem_minutes": 0,
                "buzzer": true,
                "holiday_days": 3,
                "holiday_rem_days": 0,
                "keyboard_lock": false,
                "set_point_temp": 30,
                "stdby_mode": "proximity",
                "summer": {
                    "T1": 23.9,
                    "T2": 25.9,
                    "T3": 27.9,
                    "day1": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
                    "day2": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
                    "day3": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
                    "day4": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
                    "day5": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
                    "day6": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
                    "day7": "FFFFFFFFFFFF55555555555555555555555555555555FFFF"
                },
                "automatic_hour_change": true,
                "light_skin": false,
                "max_temp": 35,
                "min_temp": 3,
                "offset_temp": 0,
                "t_threshold_high": 0,
                "t_threshold_low": 0,
                "alarm_h_low": false,
                "alarm_t_high": false,
                "alarm_t_low": false,
                "h_threshold_enable": false,
                "h_threshold_high": 134260089,
                "h_threshold_low": 134260059,
                "t_threshold_enable": false,
                "alarm_h_high": false
            }
        ],
        "sceneries": [
            {
                "_id": "5e627b640ff7cd0011c6602d",
                "name": "Esco di casa",
                "name_translated": "scenery_1",
                "actions": [],
                "group_id": "5e627b640ff7cd0011c6602b"
            },
            {
                "_id": "5e627b640ff7cd0011c6602f",
                "name": "Sto in casa",
                "name_translated": "scenery_2",
                "actions": [],
                "group_id": "5e627b640ff7cd0011c6602b"
            },
            {
                "_id": "5e627b640ff7cd0011c66031",
                "name": "Vado a letto",
                "name_translated": "scenery_3",
                "actions": [],
                "group_id": "5e627b640ff7cd0011c6602b"
            }
        ]
    }
]
  *
  * */
}
