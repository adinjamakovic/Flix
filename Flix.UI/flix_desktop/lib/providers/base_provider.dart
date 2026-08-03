import 'dart:convert';

import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      throw new Exception("Unknown error");
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

    String auth = "Bearer: $accesstoken";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": auth
    };

    return headers;
  }

  T fromJson(data) {
    throw Exception("Not implemented");
  }

  bool isValidResponse(http.Response response){
    if(response.statusCode < 299) {
      return true;
    }
    else if (response.statusCode == 401) {
      throw new Exception("Unauthorized");
    } else {
      print(response.body);
      throw new Exception("Something bad happened, try again");
    }
  }
}