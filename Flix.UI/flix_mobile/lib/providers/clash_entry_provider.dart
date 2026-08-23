import 'package:flix_mobile/models/clash_entry.dart';
import 'package:flix_mobile/models/clash_vote_state.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class ClashEntryProvider extends BaseProvider<ClashEntry> {
  ClashEntryProvider() : super("ClashEntry");

  @override
  ClashEntry fromJson(data) {
    return ClashEntry.fromJson(data);
  }

  Future<void> participate({
    required int clashId,
    required int movieListId,
  }) =>
      postJson("Participate", {
        "clashId": clashId,
        "movieListId": movieListId,
      });

  Future<ClashVoteState> getVoteState(int clashId) async {
    var data = await getObject(action: "VoteState/$clashId");

    return ClashVoteState.fromJson(data);
  }

  Future<void> vote(int clashEntryId) => postJson("Vote/$clashEntryId");

  Future<void> removeVote(int clashEntryId) =>
      deleteAction("Vote/$clashEntryId");
}
