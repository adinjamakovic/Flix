import 'package:flix_desktop/models/movie_request.dart';
import 'package:flix_desktop/models/picked_image.dart';
import 'package:flix_desktop/providers/base_provider.dart';

class MovieRequestProvider extends BaseProvider<MovieRequest> {
  MovieRequestProvider() : super("MovieRequest");

  Future<MovieRequest> review(
    int id,
    Map<String, dynamic> fields, {
    Map<String, PickedImage> files = const {},
  }) async {
    return update(id, fields, files: files, action: "AdminReview");
  }

  @override
  MovieRequest fromJson(data) {
    return MovieRequest.fromJson(data);
  }
}
