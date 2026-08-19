import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  static String? _accessToken;
  String? _refreshToken;
  String? _username;


  static String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get username => _username;
  bool get isAuthenticated => _isAuthenticated;

  String _baseUrl = "";

  AuthProvider() {
    _baseUrl = const String.fromEnvironment("BASE_URL", defaultValue: "http://localhost:5071/Access");
  }

  Future login(String username, String password) async {
    var url = "$_baseUrl/Login";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    // Refactor this into a separate class
    var body = jsonEncode({
        "username": username,
        "password": password
      });

    http.Response response = await http.post(uri, headers: headers, body: body);
    var data = jsonDecode(response.body);
    if(isValidResponse(response) && _readClaim(data['accessToken'], "Role") == "Admin") {
      _isAuthenticated = true;
      _accessToken = data['accessToken'];
      _refreshToken = data['refreshToken'];
      _username = _readClaim(_accessToken, "Username");
      notifyListeners();
    } else {
      throw Exception("Only an admin can log in");
    }

  }

  

  // Reads a claim out of the JWT payload. The token is only ever validated by
  // the API, so this is purely for display.
  static String? _readClaim(String? token, String claim) {
    if (token == null) return null;

    var parts = token.split(".");
    if (parts.length != 3) return null;

    try {
      var payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      var claims = jsonDecode(payload) as Map<String, dynamic>;
      return claims[claim] as String?;
    } catch (_) {
      return null;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _accessToken = null;
    _refreshToken  = null;
    _username = null;
    notifyListeners();
  }

  bool isValidResponse(http.Response response)
  {
    if(response.statusCode < 299){
      return true;
    }
    else if (response.statusCode == 401){
      throw Exception("Unauthorized");
    }
    else{
      print(response.body);
      throw Exception("Something bad happened please try again");
    }
  }

   Map<String, String> createHeaders() {
    var headers = {
      "Content-Type": "application/json",
    };

    return headers;
  }
}