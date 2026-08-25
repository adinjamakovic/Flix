import 'package:flix_desktop/models/activity.dart';
import 'package:flix_desktop/models/genre_percentage.dart';
import 'package:flix_desktop/models/movie.dart';
import 'package:flix_desktop/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_statistics.g.dart';

@JsonSerializable()
class AdminStatistics {
  AdminStatistics(
      this.activeUsers,
      this.userPercentage,
      this.totalMovies,
      this.moviePercentage,
      this.totalReviews,
      this.reviewPercentage,
      this.totalClashes,
      this.clashPercentage,
      this.mostActiveUsers,
      this.mostPopularMovies,
      this.recentActivity,
      this.genrePercentages
      );

  final int? activeUsers;
  final double? userPercentage;
  final int? totalMovies;
  final double? moviePercentage;
  final int? totalReviews;
  final double? reviewPercentage;
  final int? totalClashes;
  final double? clashPercentage;

  final List<User>? mostActiveUsers;
  final List<Movie>? mostPopularMovies;
  final List<Activity>? recentActivity;
  final List<GenrePercentage>? genrePercentages;

  factory AdminStatistics.fromJson(Map<String, dynamic> json) =>
      _$AdminStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$AdminStatisticsToJson(this);
}
