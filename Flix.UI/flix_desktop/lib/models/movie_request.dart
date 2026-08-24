import 'package:flix_desktop/enums/movie_request_status.dart';
import 'package:flix_desktop/models/cast_member.dart';
import 'package:flix_desktop/models/movie.dart';
import 'package:flix_desktop/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie_request.g.dart';

@JsonSerializable()
class MovieRequest {
  MovieRequest(
      this.id,
      this.requestedByUser,
      this.movie,
      this.status,
      this.createdAt
      );

  final int? id;

  final User? requestedByUser;
  final Movie? movie;

  final MovieRequestStatus? status;
  final DateTime? createdAt;

  bool get isPending => status == MovieRequestStatus.pending;

  CastMember? get requestedDirector {
    final CastMember? director = movie?.director;

    if (director == null) return null;

    final bool filledIn = (director.biography?.trim().isNotEmpty ?? false) ||
        director.birthDate != null ||
        director.photo != null;

    return filledIn ? null : director;
  }

  factory MovieRequest.fromJson(Map<String, dynamic> json) =>
      _$MovieRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MovieRequestToJson(this);
}
