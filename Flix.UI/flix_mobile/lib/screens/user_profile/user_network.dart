import 'package:flix_mobile/layouts/profile_screen.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/user_network_provider.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserNetwork extends StatefulWidget {
  const UserNetwork({super.key, required this.user, this.initialTab = followersTab});

  static const int followersTab = 0;
  static const int followingTab = 1;

  final User user;
  final int initialTab;

  @override
  State<UserNetwork> createState() => _UserNetworkState();
}

class _UserNetworkState extends State<UserNetwork> {
  static const int _pageSize = 100;

  static const double _headerHeight = 48;
  static const double _avatarRadius = 20;

  late UserNetworkProvider _networkProvider;
  late AuthProvider _authProvider;

  List<User> _followers = const [];
  List<User> _following = const [];
  List<User> _blocked = const [];

  bool _isLoading = true;
  String? _error;

  bool get _isOwnNetwork =>
      widget.user.id != null && widget.user.id == _authProvider.userId;

  @override
  void initState() {
    super.initState();

    _networkProvider = context.read<UserNetworkProvider>();
    _authProvider = context.read<AuthProvider>();

    _load();
  }

  Future<void> _load() async {
    final int? userId = widget.user.id;
    if (userId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<SearchResult<User>> results = await Future.wait([
        _networkProvider.getFollowers(userId, pageSize: _pageSize),
        _networkProvider.getFollowing(userId, pageSize: _pageSize),
        if (_isOwnNetwork) _networkProvider.getBlocked(pageSize: _pageSize),
      ]);

      if (!mounted) return;

      setState(() {
        _followers = itemsOf(results[0]);
        _following = itemsOf(results[1]);
        _blocked = _isOwnNetwork ? itemsOf(results[2]) : const [];
        _isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = errorText(e);
      });
    }
  }

  // Following or blocking somebody from their profile changes the lists behind
  // this screen, so they are read again on the way back.
  Future<void> _openProfile(User user) async {
    if (user.id == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen(userId: user.id)),
    );

    if (!mounted) return;

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = [
      "Followers",
      "Following",
      if (_isOwnNetwork) "Blocked",
    ];

    return DefaultTabController(
      length: tabs.length,
      initialIndex: widget.initialTab.clamp(0, tabs.length - 1),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('FLIX'),
          bottom: PreferredSize(
            preferredSize:
                const Size.fromHeight(_headerHeight + kTextTabBarHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildHeader(context),
                TabBar(tabs: tabs.map((label) => Tab(text: label)).toList()),
              ],
            ),
          ),
        ),
        body: _buildBody(context, tabs.length),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: _headerHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 16),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              iconSize: 22,
              color: colors.onSurface,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "${widget.user.username ?? ""}'s network",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, int tabCount) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return buildMessage(
        context,
        _error!,
        action: TextButton(onPressed: _load, child: const Text("Try again")),
      );
    }

    return TabBarView(
      children: <Widget>[
        _buildList(_followers, "Nobody follows this account yet."),
        _buildList(_following, "This account isn't following anyone yet."),
        if (tabCount > 2)
          _buildList(_blocked, "You haven't blocked anyone."),
      ],
    );
  }

  Widget _buildList(List<User> users, String emptyMessage) {
    if (users.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          // Nothing here fills the screen, and a list that cannot be dragged
          // cannot be pulled to refresh either.
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            buildMessage(context, emptyMessage),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: users.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) => _buildUserRow(users[index]),
      ),
    );
  }

  Widget _buildUserRow(User user) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _openProfile(user),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            buildAvatar(
              context,
              user.profileImage,
              user.username,
              radius: _avatarRadius,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                user.username ?? "-",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: colors.onSurface, size: 22),
          ],
        ),
      ),
    );
  }
}
