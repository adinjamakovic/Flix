import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/models/user_relationship.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/user_network_provider.dart';
import 'package:flix_mobile/providers/user_provider.dart';
import 'package:flix_mobile/screens/login.dart';
import 'package:flix_mobile/screens/user_profile/diary.dart';
import 'package:flix_mobile/screens/user_profile/report_user.dart';
import 'package:flix_mobile/screens/user_profile/user_lists.dart';
import 'package:flix_mobile/screens/user_profile/user_profile.dart';
import 'package:flix_mobile/screens/user_profile/user_settings.dart';
import 'package:flix_mobile/screens/user_profile/watchlist.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId});

  final int? userId;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _tabs = <String>['Profile', 'Diary', 'Lists', 'Watchlist'];

  static const double _userRowHeight = 48;

  late UserProvider _userProvider;
  late AuthProvider _authProvider;
  late UserNetworkProvider _networkProvider;

  User? _currentUser;
  UserRelationship? _relationship;

  bool _isLoading = true;
  String? _error;

  bool get _isCurrentUser =>
      widget.userId == null || widget.userId == _authProvider.userId;

  @override
  void initState() {
    super.initState();

    _userProvider = context.read<UserProvider>();
    _authProvider = context.read<AuthProvider>();
    _networkProvider = context.read<UserNetworkProvider>();

    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    if (!_authProvider.isAuthenticated) {
      setState(() {
        _isLoading = false;
        _error = "User not logged in";
      });
      return;
    }

    try {
      final int? userId = widget.userId;

      final User user = userId == null
          ? await _userProvider.getCurrentUserProfile()
          : await _userProvider.getById(userId);

      final UserRelationship? relationship = _isCurrentUser
          ? null
          : await _networkProvider.getRelationship(userId!);

      if (!mounted) return;

      setState(() {
        _currentUser = user;
        _relationship = relationship;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = errorText(e);
      });
    }
  }

  Future<void> _openSettings() async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const UserSettings()),
    );

    if (saved == true) await _load();
  }

  Future<void> _toggleBlock() async {
    final User? user = _currentUser;
    final int? userId = user?.id;
    final UserRelationship? relationship = _relationship;

    if (userId == null || relationship == null) return;

    final bool wasBlocked = relationship.blocked;

    if (!wasBlocked && !await _confirmBlock(user?.username)) return;

    try {
      if (wasBlocked) {
        await _networkProvider.unblock(userId);
      } else {
        await _networkProvider.block(userId);
      }

      await _load(silent: true);

      if (!mounted) return;

      showSnack(context, wasBlocked ? "User unblocked." : "User blocked.");
    } on Exception catch (e) {
      if (!mounted) return;

      showSnack(context, errorText(e));
    }
  }

  Future<bool> _confirmBlock(String? username) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Block user"),
        content: Text(
          "${username ?? "This user"} will no longer follow you, and you will "
          "stop following them.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Block"),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _reportUser() async {
    final User? user = _currentUser;
    if (user == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportUser(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FLIX'),
          bottom: PreferredSize(
            preferredSize:
                const Size.fromHeight(_userRowHeight + kTextTabBarHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildUserRow(context),
                TabBar(
                  tabs: _tabs.map((label) => Tab(text: label)).toList(),
                ),
              ],
            ),
          ),
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildUserRow(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final User? user = _currentUser;

    return SizedBox(
      height: _userRowHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 16),
        child: Row(
          children: <Widget>[
            if (_isCurrentUser) ...[
              IconButton(
                onPressed: user == null ? null : _openSettings,
                icon: const Icon(Icons.settings_outlined),
                iconSize: 22,
                color: colors.onSurface,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints.tightFor(width: 40, height: 40),
              ),
              const SizedBox(width: 8),
            ] else ...[
              _buildUserMenu(context),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                user?.username ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final UserRelationship? relationship = _relationship;

    return SizedBox(
      width: 40,
      height: 40,
      child: PopupMenuButton<VoidCallback>(
        enabled: relationship != null,
        onSelected: (action) => action(),
        icon: const Icon(Icons.settings_outlined),
        iconSize: 22,
        iconColor: colors.onSurface,
        padding: EdgeInsets.zero,
        color: colors.surfaceContainerHigh,
        itemBuilder: (context) => [
          PopupMenuItem<VoidCallback>(
            value: _toggleBlock,
            child: Text(
              (relationship?.blocked ?? false) ? "Unblock user" : "Block user",
            ),
          ),
          PopupMenuItem<VoidCallback>(
            value: _reportUser,
            child: const Text("Report user"),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return buildMessage(
        context,
        _error!,
        action: TextButton(
          onPressed: _authProvider.isAuthenticated
              ? _load
              : () {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Login()),
                    (route) => false,
                  );
                },
          child: const Text("Try again"),
        ),
      );
    }

    final User? user = _currentUser;
    if (user == null) {
      return buildMessage(context, "Profile not found");
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: TabBarView(
        children: <Widget>[
          UserProfile(
            user: user,
            relationship: _relationship,
            onRelationshipChanged: () => _load(silent: true),
          ),
          Diary(user: user),
          UserLists(user: user),
          Watchlist(user: user)
        ],
      ),
    );
  }
}
