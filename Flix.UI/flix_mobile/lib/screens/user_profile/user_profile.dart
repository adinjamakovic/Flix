import 'package:flix_mobile/models/review_count.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/models/user_relationship.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/review_provider.dart';
import 'package:flix_mobile/providers/user_network_provider.dart';
import 'package:flix_mobile/screens/activity.dart';
import 'package:flix_mobile/screens/user_profile/user_network.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flix_mobile/widgets/rating_count.dart';
import 'package:flix_mobile/widgets/review_side_scroll.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({
    super.key,
    required this.user,
    this.relationship,
    this.onRelationshipChanged,
  });

  final User user;

  final UserRelationship? relationship;

  final Future<void> Function()? onRelationshipChanged;

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late ReviewProvider _reviewProvider;
  late AuthProvider _authProvider;
  late UserNetworkProvider _networkProvider;

  ReviewCount? _reviewCount;

  bool _isLoading = true;
  bool _isTogglingFollow = false;
  String? _error;

  bool get _isCurrentUser =>
      widget.user.id != null && widget.user.id == _authProvider.userId;

  @override
  void initState() {
    super.initState();

    _reviewProvider = context.read<ReviewProvider>();
    _authProvider = context.read<AuthProvider>();
    _networkProvider = context.read<UserNetworkProvider>();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ReviewCount reviewCount =
          await _reviewProvider.getUserReviewCount(userId: widget.user.id);

      if(!mounted) return;

      setState(() {
        _isLoading = false;
        _reviewCount = reviewCount;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = errorText(e);
      });
    }
  }

  void _redirectToActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ActivityScreen()),
    );
  }

  Future<void> _openNetwork(int initialTab) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UserNetwork(user: widget.user, initialTab: initialTab),
      ),
    );

    await widget.onRelationshipChanged?.call();
  }

  Future<void> _toggleFollow() async {
    final int? userId = widget.user.id;
    final UserRelationship? relationship = widget.relationship;

    if (_isTogglingFollow || userId == null || relationship == null) return;

    setState(() => _isTogglingFollow = true);

    try {
      if (relationship.following) {
        await _networkProvider.unfollow(userId);
      } else {
        await _networkProvider.follow(userId);
      }

      await widget.onRelationshipChanged?.call();

      if (!mounted) return;

      setState(() => _isTogglingFollow = false);
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() => _isTogglingFollow = false);
      showSnack(context, errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
   return Column(
       children: [
        SizedBox(height: 16,),
        buildAvatar( context,
          widget.user.profileImage,
          widget.user.username,
          radius: 48),
        SizedBox(height: 16,),
        _buildFollowCounts(context),
        if (widget.relationship != null) ...[
          SizedBox(height: 16,),
          _buildFollowButton(context),
        ],
        SizedBox(height: 16,),
        Divider(),
        SizedBox(height: 8,),
        ReviewSideScroll(title: "RECENT ACTIVITY", reviews: widget.user.reviews ?? const [], isUserProfile: true,),
        if (_isCurrentUser)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: _redirectToActivity, child: const Text("More activity", style: TextStyle(color: Colors.white)),),
              IconButton(onPressed: _redirectToActivity, icon: Icon(Icons.arrow_forward))
            ],
          ),
        Divider(),
        _buildRatings(context)
       ],
     );
  }

  Row _buildFollowCounts(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Following: ",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          InkWell(
            onTap: () => _openNetwork(UserNetwork.followingTab),
            child: Text(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w900
              ),
              "${widget.user.followingCount ?? 0}"
            ),
          ),
          SizedBox(width: 16,),
          Text(
            "Followers: ",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          InkWell(
            onTap: () => _openNetwork(UserNetwork.followersTab),
            child: Text(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w900
              ),
              "${widget.user.followerCount ?? 0}"
            ),
          ),
        ],
      );
  }

  Widget _buildFollowButton(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final UserRelationship relationship = widget.relationship!;

    if (_isTogglingFollow) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    // A block in either direction takes the follow off the table. Unblocking is
    // in the profile menu, and a block the other way is not named as one.
    if (!relationship.canFollow) {
      return Text(
        relationship.blocked ? "Blocked" : "Can't follow this account",
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
      );
    }

    const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 32, vertical: 10);

    return relationship.following
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(padding: padding),
            onPressed: _toggleFollow,
            child: const Text("Following"),
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(padding: padding),
            onPressed: _toggleFollow,
            child: const Text("Follow"),
          );
  }

  Widget _buildRatings(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return buildMessage(
        context,
        _error!,
        action: TextButton(
          onPressed: _load,
          child: const Text("Try again"),
        ),
      );
    }

    final ReviewCount? counts = _reviewCount;
    if (counts == null) {
      return buildEmpty(context, "No ratings yet");
    }

    return RatingCountChart(counts: counts);
  }
}
