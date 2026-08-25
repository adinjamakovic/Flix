import 'package:flix_desktop/enums/activity_type.dart';
import 'package:flix_desktop/models/clash.dart';
import 'package:flix_desktop/models/movie.dart';
import 'package:flix_desktop/models/movie_list.dart';
import 'package:flix_desktop/models/review.dart';
import 'package:flix_desktop/models/user.dart';
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
      this.createdAt
      );

  final int? id;

  final User? user;

  final ActivityType? type;

  final Movie? movie;
  final Review? review;
  final Clash? clash;
  final MovieList? movieList;

  final User? targetUser;

  final DateTime? createdAt;

  Movie? get relatedMovie => movie ?? review?.movie;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
