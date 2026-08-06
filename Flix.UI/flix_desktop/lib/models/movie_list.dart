import 'package:json_annotation/json_annotation.dart';

// To generate run command: "dart run build_runner build"
part 'movie_list.g.dart';

/// A list of movies put together by a user. Only the parts the admin client
/// needs are modelled - the movies themselves are not pulled down anywhere yet.
@JsonSerializable()
class MovieList {
  MovieList(
      this.id,
      this.name,
      this.description,
      this.movieCount,
      this.createdAt,
      this.updatedAt
      );

  final int? id;
  final String? name;
  final String? description;
  final int? movieCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory MovieList.fromJson(Map<String, dynamic> json) =>
      _$MovieListFromJson(json);

  Map<String, dynamic> toJson() => _$MovieListToJson(this);
}
