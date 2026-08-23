import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/models/user_relationship.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class UserNetworkProvider extends BaseProvider<User> {
  UserNetworkProvider() : super("UserNetwork");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  Future<SearchResult<User>> getFollowers(
    int userId, {
    int page = 1,
    int pageSize = 50,
  }) {
    return get(action: "Followers/$userId", filter: _pageFilter(page, pageSize));
  }

  Future<SearchResult<User>> getFollowing(
    int userId, {
    int page = 1,
    int pageSize = 50,
  }) {
    return get(action: "Following/$userId", filter: _pageFilter(page, pageSize));
  }

  Future<SearchResult<User>> getBlocked({int page = 1, int pageSize = 50}) {
    return get(action: "Blocked", filter: _pageFilter(page, pageSize));
  }

  Future<UserRelationship> getRelationship(int userId) async {
    return UserRelationship.fromJson(
      await getObject(action: "Relationship/$userId"),
    );
  }

  Future<UserRelationship> follow(int userId) async =>
      UserRelationship.fromJson(await postJson("Follow/$userId"));

  Future<UserRelationship> unfollow(int userId) async =>
      UserRelationship.fromJson(await deleteAction("Follow/$userId"));

  Future<UserRelationship> block(int userId) async =>
      UserRelationship.fromJson(await postJson("Block/$userId"));

  Future<UserRelationship> unblock(int userId) async =>
      UserRelationship.fromJson(await deleteAction("Block/$userId"));

  Future<void> report({
    required int reportedUserId,
    required String header,
    String? description,
  }) {
    return postJson("Report", {
      "reportedUserId": reportedUserId,
      "header": header,
      "description": description,
    });
  }

  Map<String, dynamic> _pageFilter(int page, int pageSize) => {
    "page": page,
    "pageSize": pageSize,
    "includeTotalCount": true,
  };
}
