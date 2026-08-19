import 'dart:convert';

import 'package:flix_desktop/models/country.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class CountryProvider extends ChangeNotifier {
  final String _baseUrl = "http://localhost:5071/Country";

  Future<SearchResult<Country>> get({dynamic filter}) async {
    var url = _baseUrl;

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);

    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<Country>();

      result.totalCount = data['totalCount'];

      result.items = List<Country>.from(data['items'].map((e) => fromJson(e)));

      return result;
    } else {
      throw Exception("Unknown error");
    }
  }

  Country fromJson(dynamic e) {
    return Country.fromJson(e);
  }

  bool isValidResponse(http.Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
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
}
