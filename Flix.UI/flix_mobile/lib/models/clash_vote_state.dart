import 'package:json_annotation/json_annotation.dart';

part 'clash_vote_state.g.dart';

@JsonSerializable()
class ClashVoteState {
  ClashVoteState(
    this.clashId,
    this.votesAllowed,
    this.votesUsed,
    this.votesRemaining,
    this.votedEntryIds,
  );

  final int? clashId;
  final int? votesAllowed;
  final int? votesUsed;
  final int? votesRemaining;
  final List<int>? votedEntryIds;

  factory ClashVoteState.fromJson(Map<String, dynamic> json) =>
      _$ClashVoteStateFromJson(json);

  Map<String, dynamic> toJson() => _$ClashVoteStateToJson(this);
}
