import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/base_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  Future<User> getCurrentUserProfile() async {
    var userId = AuthProvider.currentUserId;

    if (userId == null) {
      throw Exception("No signed in user.");
    }

    return getById(userId);
  }
}