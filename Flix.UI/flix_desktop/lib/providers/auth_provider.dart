import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _accessToken;
  String? _refreshToken;


  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _isAuthenticated;

  String _baseUrl = "";

  AuthProvider() {
    _baseUrl = const String.fromEnvironment("BASE_URL", defaultValue: "https://localhost:7140/Access");
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
    if(isValidResponse(response)) {
      var data = jsonDecode(response.body);
      _isAuthenticated = true;
      _accessToken = data['accessToken'];
      _refreshToken = data['refreshToken'];
      notifyListeners();
    } else {
      throw Exception("Unknown error");
    }

  }

  

  void logout() {
    _isAuthenticated = false;
    _accessToken = null;
    _refreshToken  = null;
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