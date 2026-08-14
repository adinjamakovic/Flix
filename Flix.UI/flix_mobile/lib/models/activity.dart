import 'package:flix_mobile/enums/activity_type.dart';
import 'package:flix_mobile/models/clash.dart';
import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/movie_list.dart';
import 'package:flix_mobile/models/review.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity {
  Activity(
    this.id,
    this.user,
    this.type,
    this.movie,
    this.review,
    this.clash,
    this.movieList,
    this.targetUser,
    this.createdAt,
  );

  final int? id;

  /// Who the activity belongs to.
  final User? user;

  final ActivityType? type;

  final Movie? movie;
  final Review? review;
  final Clash? clash;
  final MovieList? movieList;

  /// The other party of a `followedUser` activity.
  final User? targetUser;

  final DateTime? createdAt;

  Movie? get relatedMovie => movie ?? review?.movie;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
