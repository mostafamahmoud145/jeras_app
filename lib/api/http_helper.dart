import 'dart:convert';
import 'package:http/http.dart' as http;




class HttpHelper {

  static Future<http.Response> postData(
      {required String linkUrl, required Map data, String? token}) async {

    var headers = {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
      'Content-Type': 'application/json'
    };

    var response = await http.post(
      Uri.parse(linkUrl),
      body: json.encode(data),
      headers: headers,
    );

    return response;
  }



  Future<http.Response> getData(
      {required String linkUrl,
        required String token,
      }) async {

    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    var response = await http.get(Uri.parse(linkUrl), headers: headers);

    return response;
  }



  Future<http.Response> putData(
      {required String linkUrl, required Map data, String? token}) async {

    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    var response =
    await http.put(Uri.parse(linkUrl), body: data, headers: headers);
    return response;
  }



  Future<http.Response> deleteData(
      {required String linkUrl, Map? data, String? token}) async {

    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    var response =
    await http.delete(Uri.parse(linkUrl), body: data, headers: headers);
    return response;
  }


}
