import 'dart:convert';

import 'package:flix_desktop/models/picked_image.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  String _endpoint = "";

  static const String defaultBaseUrl = "http://localhost:5071/";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment("API_BASE_URL",
        defaultValue: defaultBaseUrl);
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$_baseUrl$_endpoint";
    if(filter != null)
    {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);

    var response = await _request(() => http.get(uri, headers: createHeaders()));

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<T>();

      result.totalCount = data["totalCount"];
      result.items = List<T>.from(data["items"].map((e) => fromJson(e)));

      return result;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<dynamic> getObject({dynamic filter, String? action}) async {
    var url = "$_baseUrl$_endpoint${action == null ? "" : "/$action"}";

    if (filter != null) {
      url = "$url?${getQueryString(filter)}";
    }

    var uri = Uri.parse(url);

    var response = await _request(() => http.get(uri, headers: createHeaders()));

    if (isValidResponse(response)) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Unknown error");
    }
  }

  // Every call goes through here so an expired access token is refreshed and
  // the request replayed once, instead of surfacing as an error on whatever
  // screen the admin happened to be on. `send` is a closure rather than a
  // prepared request because the replay has to carry the new token.
  Future<http.Response> _request(Future<http.Response> Function() send) async {
    var response = await send();

    if (response.statusCode == 401 && await AuthProvider.refreshSession()) {
      response = await send();
    }

    return response;
  }

  // Every write endpoint on the API is `[Consumes("multipart/form-data")]`
  // because the insert/update requests carry an `IFormFile`, so writes are
  // sent as form fields rather than as a JSON body.
  Future<T> insert(
    Map<String, dynamic> fields, {
    Map<String, PickedImage> files = const {},
  }) async {
    var uri = Uri.parse("$_baseUrl$_endpoint");

    return _parse(await _multipart("POST", uri, fields, files));
  }

  Future<T> update(
    int id,
    Map<String, dynamic> fields, {
    Map<String, PickedImage> files = const {},
    String? action,
  }) async {
    var uri = Uri.parse("$_baseUrl$_endpoint/${action == null ? "" : "$action/"}$id");

    return _parse(await _multipart("PUT", uri, fields, files));
  }

  Future<T> insertJson(Map<String, dynamic> fields) async {
    var uri = Uri.parse("$_baseUrl$_endpoint");

    return _parse(await _request(() =>
        http.post(uri, headers: createHeaders(), body: jsonEncode(fields))));
  }

  Future<T> updateJson(int id, Map<String, dynamic> fields) async {
    var uri = Uri.parse("$_baseUrl$_endpoint/$id");

    return _parse(await _request(() =>
        http.put(uri, headers: createHeaders(), body: jsonEncode(fields))));
  }

  T _parse(http.Response response) {
    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<void> delete(int id) async {
    var uri = Uri.parse("$_baseUrl$_endpoint/$id");

    isValidResponse(
        await _request(() => http.delete(uri, headers: createHeaders())));
  }

  // The request is built inside the closure, not handed to it: a
  // MultipartRequest is single-use, so a replay after a refresh needs a new one.
  Future<http.Response> _multipart(
    String method,
    Uri uri,
    Map<String, dynamic> fields,
    Map<String, PickedImage> files,
  ) {
    return _request(() async {
      var request = http.MultipartRequest(method, uri);

      request.headers.addAll(createMultipartHeaders());

      fields.forEach((key, value) => _addField(request.fields, key, value));

      files.forEach((key, image) {
        request.files.add(http.MultipartFile.fromBytes(
          key,
          image.bytes,
          filename: image.fileName,
          contentType: MediaType.parse(image.contentType),
        ));
      });

      return http.Response.fromStream(await request.send());
    });
  }

  // `request.fields` is a flat map, so a collection or nested object is spelled
  // out the way ASP.NET Core binds it: `genreIds[0]`, `credits[0].castMemberId`.
  void _addField(Map<String, String> into, String key, dynamic value) {
    if (value == null) return;

    if (value is List) {
      for (int i = 0; i < value.length; i++) {
        _addField(into, "$key[$i]", value[i]);
      }
      return;
    }

    if (value is Map) {
      value.forEach((name, nested) => _addField(into, "$key.$name", nested));
      return;
    }

    into[key] = value is DateTime ? value.toIso8601String() : value.toString();
  }

  String getQueryString(Map params,
      {String prefix = '&', bool inRecursion = false}) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${value.toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query +=
              getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
        });
      }
    });
    return query;
  }

  Map<String, String> createHeaders() {
    String accesstoken = AuthProvider.accessToken ?? "";

    String auth = "Bearer $accesstoken";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": auth
    };

    return headers;
  }

  Map<String, String> createMultipartHeaders() {
    String accesstoken = AuthProvider.accessToken ?? "";

    return {"Authorization": "Bearer $accesstoken"};
  }

  T fromJson(data) {
    throw Exception("Not implemented");
  }

  bool isValidResponse(http.Response response){
    if(response.statusCode < 299) {
      return true;
    }
    else if (response.statusCode == 401) {
      // The refresh above has already been tried and failed, so the session is
      // over: `expireSession` sends the admin back to login.
      AuthProvider.expireSession();
      throw Exception("Your session has expired. Please sign in again.");
    } else {
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

    return "Something bad happened, try again";
  }
}