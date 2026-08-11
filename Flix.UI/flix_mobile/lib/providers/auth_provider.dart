import 'dart:convert';

import 'package:flix_mobile/models/picked_image.dart';
import 'package:flix_mobile/providers/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  static String? _accessToken;
  String? _refreshToken;
  String? _username;
  int? _userId;


  static String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get username => _username;
  int? get userId => _userId;
  bool get isAuthenticated => _isAuthenticated;

  String _baseUrl = "";

  AuthProvider() {
    const root = String.fromEnvironment("BASE_URL",
        defaultValue: BaseProvider.defaultBaseUrl);

    _baseUrl = "${root.endsWith('/') ? root : '$root/'}Access";
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

    var data = jsonDecode(response.body);

    _isAuthenticated = true;
    _accessToken = data['accessToken'];
    _refreshToken = data['refreshToken'];
    _username = _readClaim(_accessToken, "Username");
    _userId = int.tryParse(_readClaim(_accessToken, "Id") ?? "");
    notifyListeners();
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
    _userId = null;
    notifyListeners();
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
          "Check BASE_URL — it has to reach the API without a redirect.");
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