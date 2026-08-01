import 'dart:convert';

import 'package:flix_desktop/models/movie.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class MovieProvider extends ChangeNotifier {
  final String _baseUrl = "https://localhost:7140/Movie";

  Future<SearchResult<Movie>> get({dynamic filter}) async {
    var url = _baseUrl;

    if(filter != null){
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);

    var headers = createHeaders();


    var response = await http.get(uri, headers: headers);

    if(isValidResponse(response)){
        var data = jsonDecode(response.body);

        var result = SearchResult<Movie>();

        result.totalCount = data['totalCount'];

        result.items = List<Movie>.from(data['items'].map((e)=>fromJson(e)));

        return result;
    }
    else{
      throw Exception("Unknown error");
    }
  }

  Future<Movie> insert(dynamic object) async {
    var url = _baseUrl;
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(object);

    http.Response response = await http.post(uri, headers: headers, body: jsonRequest);
    if(isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<Movie> update(dynamic object) async {
    var url = _baseUrl;
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(object);

    http.Response response = await http.put(uri, headers: headers, body: jsonRequest);
    if(isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Unknown error");
    }
  }

  Movie fromJson(dynamic e) {
    return Movie.fromJson(e);
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