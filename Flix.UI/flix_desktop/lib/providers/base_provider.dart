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

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment("baseUrl", 
        defaultValue: "https://localhost:7140/");
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$_baseUrl$_endpoint";
    if(filter != null)
    {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

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

  // Every write endpoint on the API is `[Consumes("multipart/form-data")]`
  // because the insert/update requests carry an `IFormFile`, so writes are
  // sent as form fields rather than as a JSON body.
  Future<T> insert(
    Map<String, dynamic> fields, {
    Map<String, PickedImage> files = const {},
  }) async {
    var uri = Uri.parse("$_baseUrl$_endpoint");

    return _send(http.MultipartRequest("POST", uri), fields, files);
  }

  Future<T> update(
    int id,
    Map<String, dynamic> fields, {
    Map<String, PickedImage> files = const {},
  }) async {
    var uri = Uri.parse("$_baseUrl$_endpoint/$id");

    return _send(http.MultipartRequest("PUT", uri), fields, files);
  }

  Future<void> delete(int id) async {
    var uri = Uri.parse("$_baseUrl$_endpoint/$id");

    var response = await http.delete(uri, headers: createHeaders());

    isValidResponse(response);
  }

  Future<T> _send(
    http.MultipartRequest request,
    Map<String, dynamic> fields,
    Map<String, PickedImage> files,
  ) async {
    request.headers.addAll(createMultipartHeaders());

    fields.forEach((key, value) {
      if (value == null) return;
      request.fields[key] = value is DateTime
          ? value.toIso8601String()
          : value.toString();
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

    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Unknown error");
    }
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
      throw Exception("Unauthorized");
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