import 'dart:convert';

import 'package:flix_mobile/models/picked_image.dart';
import 'package:flix_mobile/providers/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
  static int? get currentUserId =>
      int.tryParse(_readClaim(_accessToken, "Id") ?? "");
  String? get refreshToken => _refreshToken;
  String? get username => _username;
  int? get userId => currentUserId;
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

    // Validate before decoding — a failed call can come back with an empty
    // body (an HTTPS redirect, for one), and jsonDecode("") throws a
    // FormatException that hides the real reason.
    isValidResponse(response);

    _store(jsonDecode(response.body));
  }

  // A 401 means the access token ran out, so the request that hit it asks for
  // a new one; false says the session is gone and cannot be replayed.
  // Concurrent callers share one call — a screen loading four things at once
  // gets four 401s, not four refreshes.
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

  /// `Access/Register` takes the profile image as an `IFormFile`, so the
  /// request is multipart rather than JSON. It answers with a plain string,
  /// not a user payload, so there is nothing to decode — a non-throwing call
  /// is the whole result.
  ///
  /// The API sets `RoleId` itself (always User), so a role sent from here
  /// would be ignored.
  Future register(
    Map<String, dynamic> fields, {
    Map<String, PickedImage> files = const {},
  }) async {
    var request =
        http.MultipartRequest("POST", Uri.parse("$_baseUrl/Register"));

    fields.forEach((key, value) {
      if (value == null) return;
      request.fields[key] = value.toString();
    });

    files.forEach((key, image) {
      request.files.add(http.MultipartFile.fromBytes(
        key,
        image.bytes,
        filename: image.fileName,
        contentType: MediaType.parse(image.contentType),
      ));
    });

    var response = await http.Response.fromStream(await request.send());

    isValidResponse(response);
  }

  Future<void> requestPasswordReset(String email) =>
      _postJson("ForgotPassword", {"email": email});

  Future<void> verifyResetToken(String email, String token) =>
      _postJson("VerifyResetToken", {"email": email, "token": token});

  Future<void> resetPassword(String email, String token, String newPassword) =>
      _postJson("ResetPassword", {
        "email": email,
        "token": token,
        "newPassword": newPassword,
      });

  Future<void> _postJson(String action, Map<String, dynamic> body) async {
    final http.Response response = await http.post(
      Uri.parse("$_baseUrl/$action"),
      headers: createHeaders(),
      body: jsonEncode(body),
    );

    isValidResponse(response);
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

    // The session is already gone locally, so a failed call must not keep the
    // user signed in: an expired token answers 401, and an unreachable API
    // throws.
    try {
      await http.post(
        Uri.parse("$_baseUrl/Logout"),
        headers: {...createHeaders(), "Authorization": "Bearer $token"},
      );
    } catch (_) {}
  }

  bool isValidResponse(http.Response response)
  {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    if (response.statusCode == 401) {
      throw Exception("Incorrect username or password.");
    }

    // The API redirects HTTP to HTTPS, and the redirect target is
    // `localhost`, which on a device/emulator is the device itself.
    if (response.statusCode >= 300 && response.statusCode < 400) {
      throw Exception(
          "The API redirected the request to ${response.headers['location']}. "
          "Check API_BASE_URL — it has to reach the API without a redirect.");
    }

    throw Exception(_errorMessage(response));
  }

  // Mirrors BaseProvider: the API's ExceptionFilter returns
  // `{ "errors": { field: [messages] } }` for ClientException and validation
  // failures, so surface those messages instead of a generic string.
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

    return "Something bad happened, try again";
  }

   Map<String, String> createHeaders() {
    var headers = {
      "Content-Type": "application/json",
    };

    return headers;
  }
}