import 'package:json_annotation/json_annotation.dart';

part 'movie_user_state.g.dart';

/// What the signed-in user has recorded about one movie — the standing review
/// behind the toggles and the stars, plus the diary and watchlist state the
/// actions sheet opens on.
@JsonSerializable()
class MovieUserState {
  MovieUserState(
      this.movieId,
      this.isWatched,
      this.isLiked,
      this.rating,
      this.isInWatchlist,
      this.diaryEntryCount
      );

  final int? movieId;
  final bool? isWatched;
  final bool? isLiked;
  final double? rating;
  final bool? isInWatchlist;
  final int? diaryEntryCount;

  bool get watched => isWatched ?? false;
  bool get liked => isLiked ?? false;
  bool get inWatchlist => isInWatchlist ?? false;
  double get stars => rating ?? 0;

  bool get isRewatch => (diaryEntryCount ?? 0) > 0;

  static MovieUserState empty(int? movieId) =>
      MovieUserState(movieId, false, false, null, false, 0);

  factory MovieUserState.fromJson(Map<String, dynamic> json) =>
      _$MovieUserStateFromJson(json);

  Map<String, dynamic> toJson() => _$MovieUserStateToJson(this);
}
