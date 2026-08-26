import 'dart:convert';

import 'package:flix_desktop/providers/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  // The session lives in statics so `BaseProvider` can read the token and
  // refresh it without an injected dependency; the instance registered in
  // `MultiProvider` is kept only to notify the screens watching it.
  static AuthProvider? _instance;

  static bool _isAuthenticated = false;
  static String? _accessToken;
  static String? _refreshToken;
  static String? _username;

  static Future<bool>? _refreshing;

  // Set by `main()`: a token expires inside a request, far from any
  // BuildContext, so the redirect back to login is left to the app root.
  static VoidCallback? onSessionExpired;

  static String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get username => _username;
  bool get isAuthenticated => _isAuthenticated;

  static final String _baseUrl = () {
    const root = String.fromEnvironment("API_BASE_URL",
        defaultValue: BaseProvider.defaultBaseUrl);

    return "${root.endsWith('/') ? root : '$root/'}Access";
  }();

  AuthProvider() {
    _instance = this;
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
      _store(data);
    } else {
      throw Exception("Only an admin can log in");
    }

  }

  // A 401 means the access token ran out, so the request that hit it asks for
  // a new one; false says the session is gone and cannot be replayed.
  // Concurrent callers share one call — a screen loading several things at once
  // gets a 401 each, not a refresh each.
  static Future<bool> refreshSession() {
    return _refreshing ??=
        _refreshSession().whenComplete(() => _refreshing = null);
  }

  static Future<bool> _refreshSession() async {
    final String? token = _refreshToken;

    if (token == null) return false;

    try {
      final http.Response response = await http.post(
        Uri.parse("$_baseUrl/LoginWithRefreshToken"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": token}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) return false;

      _store(jsonDecode(response.body));

      return true;
    } catch (_) {
      return false;
    }
  }

  static void expireSession() {
    if (!_isAuthenticated && _accessToken == null) return;

    _clear();
    onSessionExpired?.call();
  }

  static void _store(Map<String, dynamic> data) {
    _isAuthenticated = true;
    _accessToken = data['accessToken'];
    _refreshToken = data['refreshToken'];
    _username = _readClaim(_accessToken, "Username");
    _instance?.notifyListeners();
  }

  static void _clear() {
    _isAuthenticated = false;
    _accessToken = null;
    _refreshToken = null;
    _username = null;
    _instance?.notifyListeners();
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

  Future<void> logout() async {
    var token = _accessToken;

    _clear();

    if (token == null) return;

    try {
      await http.post(
        Uri.parse("$_baseUrl/Logout"),
        headers: {...createHeaders(), "Authorization": "Bearer $token"},
      );
    } catch (_) {}
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
      debugPrint(response.body);
      throw Exception(_errorMessage(response));
    }
  }

  String _errorMessage(http.Response response) {
    try {
      var errors = jsonDecode(response.body)["errors"] as Map<String, dynamic>;

      var messages = errors.values
          .expand((value) => value is List ? value : [value])
          .map((message) => message.toString().trim())
          .where((message) => message.isNotEmpty);

      if (messages.isNotEmpty) return messages.join("\n");
    } catch (_) {
      // Not a validation payload — fall through to the generic message.
    }

    return "Something bad happened please try again";
  }

   Map<String, String> createHeaders() {
    var headers = {
      "Content-Type": "application/json",
    };

    return headers;
  }
}