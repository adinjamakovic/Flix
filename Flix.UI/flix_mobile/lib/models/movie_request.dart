import 'package:flix_mobile/enums/movie_request_status.dart';
import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie_request.g.dart';

@JsonSerializable()
class MovieRequest {
  MovieRequest(
    this.id,
    this.requestedByUser,
    this.movie,
    this.status,
    this.createdAt,
    this.reviewedAt,
    this.adminComment,
  );

  final int? id;

  final User? requestedByUser;

  final Movie? movie;

  final MovieRequestStatus? status;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final String? adminComment;

  String? get statusLabel =>
      status == null ? null : getMovieRequestStatus(status!);

  factory MovieRequest.fromJson(Map<String, dynamic> json) =>
      _$MovieRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MovieRequestToJson(this);
}
