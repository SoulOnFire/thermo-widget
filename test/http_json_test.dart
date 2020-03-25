import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:thermo_widget/http_json_files/quarter.dart';
import 'package:thermo_widget/http_json_files/rest_client.dart';

Map<String, String> tempMap = {
  '11': 'T3',
  '10': 'T2',
  '01': 'T1',
  '00': 'T0',
};

String hexToBinary(String hexString) {
  String binaryString = '';
  for (int i = 0; i < hexString.length; i++) {
    // Extract string of binary digits corresponding to the hex digit.
    String binaryDigits = int.parse(hexString[i], radix: 16).toRadixString(2);
    if (binaryDigits.length < 4) {
      // Adds zeros to the start of the string to obtain 4-digits binary string.
      for (int zeroToAdd = 4 - binaryDigits.length;
      zeroToAdd > 0; zeroToAdd--) {
        binaryDigits = '0' + binaryDigits;
      }
    }
    binaryString += binaryDigits;
  }
  return binaryString;
}

String binaryToHex(String binaryString) {
  String hexString = '';
  for (int i = 0; i <= binaryString.length - 4; i += 4) {
    String hexDigit = int.parse(binaryString.substring(i, i + 4), radix: 2)
        .toRadixString(16)
        .toUpperCase();
    hexString += hexDigit;
  }
  return hexString;
}

void main() {
  group('Alcuni test JSON e HTTP', () {
    test('Test about DateTime', (){
      var now = new DateTime.now();
      print(now);
      var nowAdded = now.add(new Duration(seconds: 7200));
      String expiryString = nowAdded.toString();
      print('String: $expiryString DateTime: ${DateTime.parse(expiryString)}');
    });

    /*test('Binary => Hex', () {
      final String binaryDay =
          '111111111111111111111111111111111111111111111111101010101010101010101010101010101010101010101010111111111111111111111111111111111111111111111111010101010101010101010101010101010101010101010101';
      String hexString = binaryToHex(binaryDay);
      print('Hex: $hexString');
      assert(hexToBinary(hexString) == binaryDay);
    });
    test('Hex => Binary', () {
      final String hexDay = 'FFFFFFFFFFFFAAAAAAAAAAAAFFFFFFFFFFFF555555555555';
      String binaryString = hexToBinary(hexDay);
      print('Binary: $binaryString');
      assert(binaryToHex(binaryString) == hexDay);
    });


    test('Test risposta get devices', ()async{
      RestApiHelper helper = RestApiHelper();
      List<dynamic> jsonList = await helper.getDevices();
      Map<String, dynamic> jsonMap = jsonList.first as Map<String, dynamic>;
      List<dynamic> items = jsonMap['items'];
      Map<String, dynamic> item = items.first as Map<String, dynamic>;
      String keycode = item['keycode'];
      print(keycode);
      String currentSeason = item['current_season'];
      Map<String, dynamic> currentCalendar = item[currentSeason];
      parseDayString(currentCalendar['day1']);
    });

    test('Dovrebbe correttamente serializzare e deserializzare', () {
      Quarter quarter = Quarter('9:45', '12:30', 21.0);
      // Encoding in json dell'oggetto
      String json = jsonEncode(quarter);
      print('Oggetto serializzato $json');
      // Decoding dell'oggetto da Json
      Map quarterMap = jsonDecode(json);
      var newQuarter = Quarter.fromJson(quarterMap);
      print('Oggetto ricostruito da Json: ' +
          newQuarter.startTime +
          ' - ' +
          newQuarter.endTime +
          ', ' +
          newQuarter.temp.toString() + '°C');
    });

    test('Test chiamate HTTP', () async {
      var url = 'https://87952341-157d-45ea-9fa6-a61ccc6d381e.mock.pstmn.io/status';
      var response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    });

    test('Effetuare richiesta login CAME', () async {
      var response = await http
          .post('https://devapi2.cameconnect.net:443/api/oauth/token', headers: {
        'Authorization':
        'Basic Nzk2ODYxZjM3Y2VjOTFjYjc1M2IxYzhiOTc1NWZhOWQ6YjJkNmE4NjE1YTM5ZWI1ZGY3MTMwYThhNzA4Yjg3ODdjNjIwNTRhNDc2MDI5NGNlMDhlNGYyYzg2NzRhYmI3YWFjNzFkYzA0ODUxMzJmYTA5ODQ0OGJjMjQwZTQ1ZmNkNDA5YzIzODQ3NGZkM2RiMjQyMDhjM2Q5YjRiYWZhMWQ0Y2Y3NDYxMzg3Y2E3NWI2MDQyYzUxZGI3ODE4ZWY5OWQ4ZTI3MzNlODQ5ZmY1MDRlMmYxNGYxNWIyZmVkNTQyMmI1NjhiYzRlYjI2ZmIzYTgzNDRiMzE2YzBmYmZlZmY2YjA4Y2MyNTg1YjlhNDVkM2Q0YTIxZTUxYTcxNjExNQ==',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Postman-Token': 'baf2ccb8-20e8-4fa6-ba7a-b7d8bda3a561',
        'cache-control': 'no-cache'},
          body: 'grant_type=password&password=cameRD2019&username=user.cameconnect');
      final responseJson = json.decode(response.body);
      print('Json ricevuto: $responseJson');
    });*/
  });
}
