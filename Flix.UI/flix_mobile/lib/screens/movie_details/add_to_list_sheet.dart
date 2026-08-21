import 'package:flix_mobile/enums/list_type.dart';
import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/movie_list_details.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/list_provider.dart';
import 'package:flix_mobile/screens/user_profile/list_form.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showAddToListSheet(BuildContext context, Movie movie) {
  final ColorScheme colors = Theme.of(context).colorScheme;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.surfaceContainerLow,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => AddToListSheet(movie: movie),
  );
}

class AddToListSheet extends StatefulWidget {
  const AddToListSheet({super.key, required this.movie});

  final Movie movie;

  @override
  State<AddToListSheet> createState() => _AddToListSheetState();
}

class _AddToListSheetState extends State<AddToListSheet> {
  static const int _pageSize = 50;

  static const double _maxHeightFraction = 0.7;

  static const double _posterWidth = 36;
  static const double _posterHeight = 54;

  late ListProvider _listProvider;
  late AuthProvider _authProvider;

  List<MovieListDetails> _lists = List.empty();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _listProvider = context.read<ListProvider>();
    _authProvider = context.read<AuthProvider>();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final int? userId = _authProvider.userId;

    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error = "Sign in to add a movie to one of your lists";
      });
      return;
    }

    try {
      // Only a custom list can be written to by id - the watchlist is resolved
      // from the caller and a clash list belongs to the clash.
      final SearchResult<MovieListDetails> result =
          await _listProvider.getUserLists(
        userId: userId,
        pageSize: _pageSize,
        type: ListType.custom,
        includeTotalCount: false,
      );

      if (!mounted) return;

      setState(() {
        _lists = itemsOf(result)
          ..sort((a, b) => _compareDates(b.createdAt, a.createdAt));
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

  // A list with no date sorts last.
  int _compareDates(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    return a.compareTo(b);
  }

  bool _holdsMovie(MovieListDetails list) {
    final int? movieId = widget.movie.id;
    if (movieId == null) return false;

    final List<Movie> movies = list.movies ?? List<Movie>.empty();

    return movies.any((movie) => movie.id == movieId);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFraction,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(colors),
            const Divider(height: 1),
            Flexible(child: _buildBody(colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add to a list:",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            titleWithYear(widget.movie.title, widget.movie.releaseDate),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: buildMessage(
          context,
          _error!,
          action: TextButton(onPressed: _load, child: const Text("Try again")),
        ),
      );
    }

    if (_lists.isEmpty) return _buildNoLists(colors);

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: _lists.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => _buildListRow(colors, _lists[index]),
    );
  }

  Widget _buildNoLists(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "You haven't made a list yet. Start one and it shows up here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _openListForm,
            icon: const Icon(Icons.add),
            label: const Text("Create a list"),
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(ColorScheme colors, MovieListDetails list) {
    final List<Movie> movies = list.movies ?? List<Movie>.empty();
    final bool alreadyAdded = _holdsMovie(list);

    return ListTile(
      enabled: !alreadyAdded && !_isSaving,
      onTap: () => _add(list),
      leading: buildPoster(
        context,
        movies.isEmpty ? null : movies.first.poster,
        width: _posterWidth,
        height: _posterHeight,
        iconSize: 18,
        borderRadius: 4,
      ),
      title: Text(
        list.name ?? "-",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 15),
      ),
      subtitle: Text(
        alreadyAdded
            ? "Already on this list"
            : "${movies.length} ${movies.length == 1 ? "movie" : "movies"}",
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
      ),
      trailing: alreadyAdded
          ? Icon(Icons.check, color: colors.primary, size: 20)
          : null,
    );
  }

  Future<void> _add(MovieListDetails list) async {
    final int? movieId = widget.movie.id;
    final int? listId = list.id;

    if (movieId == null || listId == null || _isSaving) return;

    setState(() => _isSaving = true);

    // The sheet is gone by the time the snack bar goes up, so it is shown on
    // the navigator that hosted it.
    final NavigatorState navigator = Navigator.of(context);

    try {
      await _listProvider.addToList(movieId, listId: listId);

      if (!mounted) return;

      navigator.pop();
      showSnack(navigator.context, "Added to ${list.name ?? "your list"}");
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);
      showSnack(context, errorText(e));
    }
  }

  // The form is a screen of its own, so the sheet gets out of its way first.
  Future<void> _openListForm() async {
    final NavigatorState navigator = Navigator.of(context);
    navigator.pop();

    await navigator.push(
      MaterialPageRoute(builder: (context) => const ListForm()),
    );
  }
}
