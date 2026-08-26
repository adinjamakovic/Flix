import 'package:flix_mobile/enums/recommendation_source.dart';
import 'package:flix_mobile/models/movie.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie_recommendation.g.dart';

@JsonSerializable()
class MovieRecommendation {
  MovieRecommendation(
    this.id,
    this.movieId,
    this.movie,
    this.recommendedMovieId,
    this.recommendedMovie,
    this.score,
    this.source,
    this.reason,
  );

  final int? id;

  final int? movieId;
  final Movie? movie;

  final int? recommendedMovieId;
  final Movie? recommendedMovie;

  final double? score;

  final RecommendationSource? source;
  final String? reason;

  factory MovieRecommendation.fromJson(Map<String, dynamic> json) =>
      _$MovieRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$MovieRecommendationToJson(this);
}
