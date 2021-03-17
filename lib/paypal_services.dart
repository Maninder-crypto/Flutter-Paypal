import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class PaypalServices {
  /*static String username =
      'AWdNlgqyRyRiZrME5C9RN5wPwtpnMm7eXYXt6wjt0UjSw00zbCLF_Iy5oTuNNsPlNcSoXxIlKNxAqeUo';
  static String password =
      'EH1qLfxjhFRIM53IZHfu1nt3WuGGI2yEEcfs5U5R7LCIm7tm1JlcwJc-3HC97swAsrbObXsTkgL2nkSB';*/

  static String username =
      'AVQBsnUTzWRVl85wu6ZkHu1FMuvSRnZqwlDOflbbIHeHjQS6OGhEMlmXlWfdoAmu-KVibb2D5zzHwI1c';
  static String password =
      'EBu6WdBejhfcGvzN06FFWvnRzBDj6Gp038lsDPQSFmEhvx9QBC77Ar1KOME2VbiwbDBBjEjSMSNscmqj';

  static var rootObj = {"grant_type": "client_credentials"};

  static Future<Map<String, dynamic>> getToken() async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final response = await http.post('https://api.paypal.com/v1/oauth2/token',
        headers: {HttpHeaders.authorizationHeader: basicAuth}, body: rootObj);
    //final responseJson = json.decode(response.body);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      //print('response ${response.body}');
      final data = json.decode(response.body);
      // print(data['scope']);
      return data;
    } else {
      print('error details: $response');
      // If that call was not successful, throw an error.
      throw Exception('Failed');
    }

    // print('response ${response.body}');

    //return response.body;
    //return Post.fromJson(responseJson);
  }

  static Future<Map<String, dynamic>> createOrder(
      String token, var bodyData) async {
    //String basicAuth =
    //'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final response = await http.post(
        'https://api.paypal.com/v2/checkout/orders',
        headers: requestHeaders,
        body: bodyData);
    //final responseJson = json.decode(response.body);

    //print(requestHeaders);
    // print('---------------------------------------------------------');
    // print(bodyData);
    print('response statusCode - ' + response.statusCode.toString());
    print('response body - ' + response.body);

    if (response.statusCode == 201) {
      // If the call to the server was successful, parse the JSON
      //print('response ${response.body}');
      final data = json.decode(response.body);
      //print(data['links'][1]['href']);
      return data;
    } else {
      // If that call was not successful, throw an error.
      //print(response.body);
      print('error details: $response');
      throw Exception('request Failed');
    }
  }

  static Future<Map<String, dynamic>> capture(String token, String url) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final response = await http.post(url, headers: requestHeaders);

    print('capture response statusCode - ' + response.statusCode.toString());
    print('capture response body - ' + response.body);

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('request Failed');
    }
  }
}
