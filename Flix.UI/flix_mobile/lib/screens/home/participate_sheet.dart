import 'package:flix_mobile/enums/list_type.dart';
import 'package:flix_mobile/models/clash.dart';
import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/movie_list_details.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/clash_entry_provider.dart';
import 'package:flix_mobile/providers/list_provider.dart';
import 'package:flix_mobile/screens/user_profile/list_form.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Resolves to true once the clash has been entered.
Future<bool?> showParticipateSheet(BuildContext context, Clash clash) {
  final ColorScheme colors = Theme.of(context).colorScheme;

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.surfaceContainerLow,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => ParticipateSheet(clash: clash),
  );
}

class ParticipateSheet extends StatefulWidget {
  const ParticipateSheet({super.key, required this.clash});

  final Clash clash;

  @override
  State<ParticipateSheet> createState() => _ParticipateSheetState();
}

class _ParticipateSheetState extends State<ParticipateSheet> {
  static const int _pageSize = 50;

  static const double _maxHeightFraction = 0.7;

  static const double _posterWidth = 36;
  static const double _posterHeight = 54;

  late ListProvider _listProvider;
  late ClashEntryProvider _clashEntryProvider;
  late AuthProvider _authProvider;

  List<MovieListDetails> _lists = List.empty();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

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

    final int? userId = _authProvider.userId;

    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error = "Sign in to enter a clash";
      });
      return;
    }

    try {
      final SearchResult<MovieListDetails> result =
          await _listProvider.getUserLists(
        userId: userId,
        pageSize: _pageSize,
        includeTotalCount: false,
      );

      if (!mounted) return;

      setState(() {
        _lists = _contenders(itemsOf(result));
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

  // Anything but the watchlist can be entered - a list that already ran in an
  // earlier clash is fair game, which is why the type filter is not narrowed
  // to custom lists.
  List<MovieListDetails> _contenders(List<MovieListDetails> lists) {
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

  Future<void> _participate(MovieListDetails list) async {
    final int? clashId = widget.clash.id;
    final int? listId = list.id;

    if (clashId == null || listId == null || _isSaving) return;

    if (!await _confirmRename(list)) return;
    if (!mounted) return;

    setState(() => _isSaving = true);

    // The sheet is gone by the time the snack bar goes up, so it is shown on
    // the navigator that hosted it.
    final NavigatorState navigator = Navigator.of(context);

    try {
      await _clashEntryProvider.participate(
        clashId: clashId,
        movieListId: listId,
      );

      if (!mounted) return;

      navigator.pop(true);
      showSnack(
        navigator.context,
        "${list.name ?? "Your list"} is in the clash.",
      );
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);
      showSnack(context, errorText(e));
    }
  }

  Future<bool> _confirmRename(MovieListDetails list) async {
    final String clashName = widget.clash.name ?? "the clash";

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter this list?"),
        content: Text(
          "\"${list.name ?? "Your list"}\" is renamed to \"$clashName\" once it "
          "is entered, and keeps that name afterwards.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Enter"),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  // The form is a screen of its own, so the sheet gets out of its way first.
  Future<void> _openListForm() async {
    final NavigatorState navigator = Navigator.of(context);
    navigator.pop();

    await navigator.push(
      MaterialPageRoute(builder: (context) => const ListForm()),
    );
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
            "Enter with a list:",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            widget.clash.name ?? "-",
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
      itemCount: _lists.length + 1,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => index == _lists.length
          ? _buildCreateAction()
          : _buildListRow(colors, _lists[index]),
    );
  }

  Widget _buildNoLists(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "You need a list to enter a clash with. Start one and it shows up here.",
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

  Widget _buildCreateAction() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: OutlinedButton.icon(
        onPressed: _isSaving ? null : _openListForm,
        icon: const Icon(Icons.add),
        label: const Text("Create a list"),
      ),
    );
  }

  Widget _buildListRow(ColorScheme colors, MovieListDetails list) {
    final List<Movie> movies = list.movies ?? List<Movie>.empty();

    return ListTile(
      enabled: !_isSaving,
      onTap: () => _participate(list),
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
        "${movies.length} ${movies.length == 1 ? "movie" : "movies"}",
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
      ),
    );
  }
}
