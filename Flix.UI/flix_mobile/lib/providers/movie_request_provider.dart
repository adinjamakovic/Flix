import 'package:flix_mobile/enums/movie_request_status.dart';
import 'package:flix_mobile/models/movie_request.dart';
import 'package:flix_mobile/models/picked_image.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class MovieRequestProvider extends BaseProvider<MovieRequest> {
  MovieRequestProvider() : super("MovieRequest");

  @override
  MovieRequest fromJson(data) {
    return MovieRequest.fromJson(data);
  }

  Future<SearchResult<MovieRequest>> getRequests({
    MovieRequestStatus? status,
    int page = 1,
    int pageSize = 10,
    bool includeMovie = true,
    bool includeUser = false,
    bool includeTotalCount = true,
  }) {
    return get(filter: {
      "page": page,
      "pageSize": pageSize,
      if (status != null) "status": status.index,
      "includeMovie": includeMovie,
      "includeUser": includeUser,
      "includeTotalCount": includeTotalCount,
    });
  }

  Future<MovieRequest> cancelRequest(int id) async {
    return MovieRequest.fromJson(await postJson("Cancel/$id"));
  }

  Future<MovieRequest> submitRequest({
    required String title,
    String? directorName,
    String? description,
    DateTime? dateOfRelease,
    int? genreId,
    PickedImage? poster,
  }) {
    return insert(
      {
        "title": title,
        "directorName": directorName,
        "description": description,
        "dateOfRelease": dateOfRelease,
        "genreId": genreId ?? 0,
      },
      files: {"poster": ?poster},
      action: "UserRequest",
    );
  }
}
