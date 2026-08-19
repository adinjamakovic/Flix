import 'package:flix_mobile/enums/list_type.dart';
import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie_list_details.g.dart';

@JsonSerializable()
class MovieListDetails {
  MovieListDetails(
    this.id,
    this.name,
    this.description,
    this.type,
    this.createdAt,
    this.user,
    this.movies,
  );

  final int? id;
  final String? name;
  final String? description;
  final ListType? type;
  final DateTime? createdAt;
  final User? user;
  final List<Movie>? movies;

  factory MovieListDetails.fromJson(Map<String, dynamic> json) =>
      _$MovieListDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$MovieListDetailsToJson(this);
}
