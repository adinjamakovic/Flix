import 'package:flix_desktop/providers/auth_provider.dart';
import 'package:flix_desktop/screens/lists/cast_list.dart';
import 'package:flix_desktop/screens/issues.dart';
import 'package:flix_desktop/screens/lists/clash_list.dart';
import 'package:flix_desktop/screens/lists/movie_request_list.dart';
import 'package:flix_desktop/screens/lists/review_list.dart';
import 'package:flix_desktop/screens/login.dart';
import 'package:flix_desktop/screens/miscellaneous.dart';
import 'package:flix_desktop/screens/statistics.dart';
import 'package:flix_desktop/screens/lists/user_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/lists/movie_list.dart';

enum DrawerDestination { movies, submissions, cast, users, reviews, clashes, issues, statistics, cruds }

class MasterScreen extends StatefulWidget {
  const MasterScreen({
    super.key,
    required this.child,
    required this.title,
    required this.destination,
  });
  final Widget child;
  final String title;
  final DrawerDestination destination;

  @override
  _MasterScreenState createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  final List<_DrawerItem> _items = const [
    _DrawerItem(DrawerDestination.movies, Icons.movie_filter_outlined, "Movies", MovieList()),
    _DrawerItem(DrawerDestination.submissions, Icons.playlist_add_check_outlined, "Submissions", MovieRequestList()),
    _DrawerItem(DrawerDestination.cast, Icons.account_circle_outlined, "Cast", CastList()),
    _DrawerItem(DrawerDestination.users, Icons.groups_outlined, "Users", UserList()),
    _DrawerItem(DrawerDestination.reviews, Icons.star_border, "Reviews", ReviewList()),
    _DrawerItem(DrawerDestination.clashes, Icons.emoji_events_outlined, "Clashes", ClashList()),
    _DrawerItem(DrawerDestination.issues, Icons.flag_outlined, "Issues", Issues()),
    _DrawerItem(DrawerDestination.statistics, Icons.bar_chart, "Statistics", Statistics()),
    _DrawerItem(DrawerDestination.cruds, Icons.more, "Miscellaneous CRUDs", Miscellaneous()),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        width: 300,
        backgroundColor: colors.secondary,
        shape: const RoundedRectangleBorder(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Text(
                "FLIX",
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final _DrawerItem item = _items[index];
                  final bool selected = item.destination == widget.destination;

                  return _DrawerTile(
                    item: item,
                    selected: selected,
                    selectedColor: colors.primaryContainer,
                    foregroundColor: colors.onSecondary,
                    onTap: () {
                      Navigator.pop(context); // close the drawer
                      if (selected) return;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => item.navigateTo));
                    },
                  );
                },
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: colors.onSecondary.withValues(alpha: 0.12),
            ),
            Container(
              color: colors.secondaryContainer,
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
              child: Row(
                children: [
                  Icon(Icons.person_outline,
                      color: colors.onSecondaryContainer, size: 26),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      context.watch<AuthProvider>().username ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSecondaryContainer,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    tooltip: "Log out",
                    icon: Icon(Icons.logout,
                        color: colors.onSecondaryContainer, size: 24),
                    onPressed: () async {
                      var navigator = Navigator.of(context);

                      await context.read<AuthProvider>().logout();

                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false, // drop every screen behind us
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: widget.child,
    );
  }
}

class _DrawerItem {
  const _DrawerItem(this.destination, this.icon, this.label, this.navigateTo);
  final DrawerDestination destination;
  final IconData icon;
  final String label;
  final Widget navigateTo;
}

class _DrawerTile extends StatefulWidget {
  const _DrawerTile({
    required this.item,
    required this.selected,
    required this.selectedColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final _DrawerItem item;
  final bool selected;
  final Color selectedColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  State<_DrawerTile> createState() => _DrawerTileState();
}

class _DrawerTileState extends State<_DrawerTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color background = widget.selected
        ? widget.selectedColor
        : _hovered
            ? widget.foregroundColor.withValues(alpha: 0.10)
            : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(widget.item.icon, color: widget.foregroundColor, size: 24),
                const SizedBox(width: 16),
                Text(
                  widget.item.label,
                  style: TextStyle(
                    color: widget.foregroundColor,
                    fontSize: 17,
                    fontWeight:
                        widget.selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
