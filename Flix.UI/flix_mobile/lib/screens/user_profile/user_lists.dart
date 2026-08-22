import 'package:flix_mobile/enums/list_type.dart';
import 'package:flix_mobile/models/clash_entry.dart';
import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/movie_list_details.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/clash_entry_provider.dart';
import 'package:flix_mobile/providers/list_provider.dart';
import 'package:flix_mobile/screens/user_profile/list_details.dart';
import 'package:flix_mobile/screens/user_profile/list_form.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserLists extends StatefulWidget {
  const UserLists({ super.key, required this.user });

  final User user;

  @override
  _UserListsState createState() => _UserListsState();
}

class _UserListsState extends State<UserLists> {
  static const int _pageSize = 50;

  static const double _posterWidth = 100;
  static const double _posterHeight = 150;
  static const double _posterRadius = 4;
  static const double _posterGap = 4;

  static const double _bottomInset = 88;

  late ListProvider _listProvider;
  late ClashEntryProvider _clashEntryProvider;
  late AuthProvider _authProvider;

  List<MovieListDetails> _lists = List.empty();

  Set<int> _clashWinnerListIds = const {};

  bool _isLoading = true;
  String? _error;

  bool get _isCurrentUser =>
      widget.user.id != null && widget.user.id == _authProvider.userId;

  @override
  void initState() {
    super.initState();

    _listProvider = context.read<ListProvider>();
    _clashEntryProvider = context.read<ClashEntryProvider>();
    _authProvider = context.read<AuthProvider>();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final int? userId = widget.user.id;

    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error = "User not found";
      });
      return;
    }

    try {
      final Future<SearchResult<MovieListDetails>> listsRequest =
          _listProvider.getUserLists(userId: userId, pageSize: _pageSize);
      final Future<Set<int>> winnersRequest = _loadClashWinnerListIds();

      final List<MovieListDetails> lists = itemsOf(await listsRequest);
      final Set<int> winners = await winnersRequest;

      if (!mounted) return;

      setState(() {
        _lists = _ownLists(lists);
        _clashWinnerListIds = winners;
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

  List<MovieListDetails> _ownLists(List<MovieListDetails> lists) {
    return lists.where((list) => list.type != ListType.watchlist).toList()
      ..sort((a, b) => _compareDates(b.createdAt, a.createdAt));
  }

  // A list with no date sorts last.
  int _compareDates(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    return a.compareTo(b);
  }

  Future<Set<int>> _loadClashWinnerListIds() async {
    final String username = widget.user.username?.trim() ?? "";
    if (username.isEmpty) return const {};

    final SearchResult<ClashEntry> result = await _clashEntryProvider.get(
      filter: {
        "page": 1,
        "pageSize": _pageSize,
        "username": username,
        "includeMovieList": true,
      },
    );

    return itemsOf(result)
        .where((entry) => entry.isWinner == true)
        .map((entry) => entry.movieList?.id)
        .whereType<int>()
        .toSet();
  }

  bool _hasWonClash(MovieListDetails list) =>
      _clashWinnerListIds.contains(list.id);

  Future<void> _openListForm([MovieListDetails? list]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListForm(list: list)),
    );

    if (!mounted) return;

    await _load();
  }

  void _onListTapped(MovieListDetails list) {
    if (_isCurrentUser) {
      _openListForm(list);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListDetails(list: list, owner: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _isCurrentUser
          ? FloatingActionButton(
              onPressed: _openListForm,
              tooltip: "New list",
              child: const Icon(Icons.add),
            )
          : null,
      body: _buildBody(context),
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
        action: TextButton(onPressed: _load, child: const Text("Try again")),
      );
    }

    if (_lists.isEmpty) {
      return buildMessage(
        context,
        _isCurrentUser
            ? "You haven't made a list yet. Start one and the movies on it show up here."
            : "${widget.user.username ?? "This user"} hasn't made a list yet.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: _bottomInset),
      itemCount: _lists.length,
      itemBuilder: (context, index) => _buildListRow(_lists[index]),
    );
  }

  Widget _buildListRow(MovieListDetails list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => _onListTapped(list),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPosters(list),
              _buildCaption(list),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  // The posters run off the right edge the way a shelf does, so the strip is
  // flush with both edges of the screen rather than padded like the caption.
  Widget _buildPosters(MovieListDetails list) {
    final List<Movie> movies = list.movies ?? List<Movie>.empty();

    if (movies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
        child: buildEmpty(context, "No movies on this list yet."),
      );
    }

    return SizedBox(
      height: _posterHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: movies.length,
        separatorBuilder: (context, index) => const SizedBox(width: _posterGap),
        itemBuilder: (context, index) => buildPoster(
          context,
          movies[index].poster,
          width: _posterWidth,
          height: _posterHeight,
          iconSize: 32,
          borderRadius: _posterRadius,
        ),
      ),
    );
  }

  Widget _buildCaption(MovieListDetails list) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  list.name ?? "-",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                if (_hasWonClash(list)) ...[
                  const SizedBox(height: 2),
                  Text(
                    "CLASH WINNER!!",
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.arrow_forward, color: colors.onSurface, size: 22),
        ],
      ),
    );
  }
}
