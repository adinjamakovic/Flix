import 'package:flix_desktop/models/movie_list.dart';
import 'package:flix_desktop/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

// To generate run command: "dart run build_runner build"
part 'clash_entry.g.dart';

/// One user's submission to a clash: the list they entered with, and how many
/// votes that list has collected so far.
@JsonSerializable()
class ClashEntry {
  ClashEntry(
      this.id,
      this.clashId,
      this.user,
      this.movieList,
      this.votes,
      this.isWinner,
      this.createdAt
      );

  final int? id;
  final int? clashId;

  /// Only populated when the search was sent with includeUser/includeMovieList.
  final User? user;
  final MovieList? movieList;

  final int? votes;
  final bool? isWinner;
  final DateTime? createdAt;

  factory ClashEntry.fromJson(Map<String, dynamic> json) =>
      _$ClashEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ClashEntryToJson(this);
}
