import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/user_provider.dart';
import 'package:flix_mobile/screens/login.dart';
import 'package:flix_mobile/screens/user_profile/diary.dart';
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

  User? _currentUser;

  bool _isLoading = true;
  String? _error;

  bool get _isCurrentUser =>
      widget.userId == null || widget.userId == _authProvider.userId;

  @override
  void initState() {
    super.initState();

    _userProvider = context.read<UserProvider>();
    _authProvider = context.read<AuthProvider>();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

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

      if (!mounted) return;

      setState(() {
        _currentUser = user;
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
                onPressed: user == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserSettings(),
                          ),
                        );
                      },
                icon: const Icon(Icons.settings_outlined),
                iconSize: 22,
                color: colors.onSurface,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints.tightFor(width: 40, height: 40),
              ),
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
          UserProfile(user: user),
          Diary(user: user),
          UserLists(user: user),
          Watchlist(user: user)
        ],
      ),
    );
  }
}
