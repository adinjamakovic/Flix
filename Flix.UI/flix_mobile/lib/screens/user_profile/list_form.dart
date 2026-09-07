import 'dart:async';
import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/movie_list_details.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/list_provider.dart';
import 'package:flix_mobile/providers/movie_provider.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A name, an optional description and the movies that go on the list. Movies
/// are optional too; the list can be filled in later from a movie's "Add to
/// list" sheet.
class ListForm extends StatefulWidget {
  const ListForm({super.key, this.list});

  final MovieListDetails? list;

  @override
  State<ListForm> createState() => _ListFormState();
}

class _ListFormState extends State<ListForm> {
  static const int _nameMaxLength = 150;
  static const int _descriptionMaxLength = 500;

  static const int _pageSize = 20;

  static const Duration _debounce = Duration(milliseconds: 400);

  static const double _fieldRadius = 14;

  static const double _posterWidth = 44;
  static const double _posterHeight = 66;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController = TextEditingController(
    text: widget.list?.name ?? "",
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.list?.description ?? "");
  final TextEditingController _searchController = TextEditingController();

  late ListProvider _listProvider;
  late MovieProvider _movieProvider;

  Timer? _debounceTimer;

  late final List<Movie> _selected = List<Movie>.of(
    widget.list?.movies ?? List<Movie>.empty(),
  );
  List<Movie> _results = List.empty();

  int _requestToken = 0;

  bool _isSearching = false;
  bool _isSubmitting = false;
  bool _isDeleting = false;
  String? _searchError;

  bool get _hasQuery => _searchController.text.trim().isNotEmpty;

  int? get _listId => widget.list?.id;

  bool get _isEditing => _listId != null;

  bool get _isBusy => _isSubmitting || _isDeleting;

  @override
  void initState() {
    super.initState();

    _listProvider = context.read<ListProvider>();
    _movieProvider = context.read<MovieProvider>();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isBusy || !(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final String name = _nameController.text.trim();
    final String? description = _nullIfBlank(_descriptionController.text);
    final List<int> movieIds =
        _selected.map((movie) => movie.id).whereType<int>().toList();

    final int? id = _listId;

    try {
      if (id == null) {
        await _listProvider.createList(
          name: name,
          description: description,
          movieIds: movieIds,
        );
      } else {
        await _listProvider.updateList(
          id: id,
          name: name,
          description: description,
          movieIds: movieIds,
        );
      }

      if (!mounted) return;

      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(id == null ? "List created." : "List updated.")),
      );
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);
      messenger.showSnackBar(SnackBar(content: Text(errorText(e))));
    }
  }

  Future<void> _delete() async {
    final int? id = _listId;

    if (id == null || _isBusy || !await _confirmDelete()) return;

    if (!mounted) return;

    FocusScope.of(context).unfocus();
    setState(() => _isDeleting = true);

    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      await _listProvider.delete(id);

      if (!mounted) return;

      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text("List deleted.")));
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() => _isDeleting = false);
      messenger.showSnackBar(SnackBar(content: Text(errorText(e))));
    }
  }

  Future<bool> _confirmDelete() async {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete list"),
        content: Text(
          "\"${widget.list?.name ?? "This list"}\" is gone for good, along with "
          "any clash it was entered in.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: colors.error),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  String? _nullIfBlank(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _onQueryChanged(String _) {
    _debounceTimer?.cancel();

    setState(() {});

    if (!_hasQuery) {
      _clearResults();
      return;
    }

    _debounceTimer = Timer(_debounce, _search);
  }

  Future<void> _search() async {
    final String title = _searchController.text.trim();

    if (title.isEmpty) {
      _clearResults();
      return;
    }

    final int token = ++_requestToken;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final SearchResult<Movie> data = await _movieProvider.get(
        filter: {
          "page": 1,
          "pageSize": _pageSize,
          "title": title,
        },
      );

      if (!mounted || token != _requestToken) return;

      setState(() {
        _results = itemsOf(data);
        _isSearching = false;
      });
    } on Exception catch (e) {
      if (!mounted || token != _requestToken) return;

      setState(() {
        _isSearching = false;
        _searchError = errorText(e);
      });
    }
  }

  void _clearResults() {
    _requestToken++;

    setState(() {
      _results = List.empty();
      _isSearching = false;
      _searchError = null;
    });
  }

  void _clearQuery() {
    _debounceTimer?.cancel();
    _searchController.clear();
    _clearResults();
  }

  bool _isSelected(Movie movie) =>
      movie.id != null && _selected.any((entry) => entry.id == movie.id);

  void _add(Movie movie) {
    if (movie.id == null || _isSelected(movie) || _isBusy) return;

    setState(() => _selected.add(movie));
  }

  void _remove(Movie movie) {
    if (_isBusy) return;

    setState(() => _selected.removeWhere((entry) => entry.id == movie.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit list" : "New list"),
        actions: [if (_isEditing) _buildDeleteAction()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildName(),
              const SizedBox(height: 14),
              _buildDescription(),
              const SizedBox(height: 22),
              _buildSelected(),
              const SizedBox(height: 22),
              _buildSearchField(),
              _buildResults(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildFooter(),
    );
  }

  Widget _buildDeleteAction() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (_isDeleting) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.delete_outline),
      color: colors.error,
      tooltip: "Delete list",
      onPressed: _isBusy ? null : _delete,
    );
  }

  Widget _buildName() {
    return TextFormField(
      controller: _nameController,
      enabled: !_isBusy,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      decoration: _decoration("Name your list..."),
      validator: (value) =>
          requiredValidator(value, "Name") ??
          maxLengthValidator(value, _nameMaxLength, "Name"),
    );
  }

  Widget _buildDescription() {
    return TextFormField(
      controller: _descriptionController,
      enabled: !_isBusy,
      minLines: 4,
      maxLines: 8,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      decoration: _decoration("What is this list about? (optional)"),
      validator: (value) =>
          maxLengthValidator(value, _descriptionMaxLength, "Description"),
    );
  }

  Widget _buildSelected() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel(
          _selected.isEmpty
              ? "Movies on this list"
              : "Movies on this list (${_selected.length})",
        ),
        const SizedBox(height: 10),
        if (_selected.isEmpty)
          buildEmpty(context, "Search below to put movies on this list.")
        else
          ..._selected.map(
            (movie) => _buildMovieRow(
              movie,
              onTap: () => _remove(movie),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 20),
                tooltip: "Remove",
                onPressed: () => _remove(movie),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return TextField(
      controller: _searchController,
      enabled: !_isBusy,
      textInputAction: TextInputAction.search,
      onChanged: _onQueryChanged,
      onSubmitted: (value) {
        _debounceTimer?.cancel();
        _search();
      },
      style: TextStyle(color: colors.onSurface, fontSize: 15),
      decoration: InputDecoration(
        hintText: "Add a movie by title...",
        prefixIcon: const Icon(Icons.search, size: 24),
        suffixIcon: _hasQuery
            ? IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: colors.onSurfaceVariant,
                onPressed: _clearQuery,
              )
            : null,
      ),
    );
  }

  Widget _buildResults() {
    if (!_hasQuery) return const SizedBox.shrink();

    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_searchError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: buildMessage(
          context,
          _searchError!,
          action: TextButton(onPressed: _search, child: const Text("Try again")),
        ),
      );
    }

    if (_results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text("No movies match your search."),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        ..._results.map((movie) {
          final bool added = _isSelected(movie);

          return _buildMovieRow(
            movie,
            onTap: added ? null : () => _add(movie),
            trailing: Icon(
              added ? Icons.check : Icons.add,
              size: 20,
              color: added
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMovieRow(
    Movie movie, {
    required VoidCallback? onTap,
    required Widget trailing,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            buildPoster(
              context,
              movie.poster,
              width: _posterWidth,
              height: _posterHeight,
              iconSize: 20,
              borderRadius: 4,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titleWithYear(movie.title, movie.releaseDate),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.onSurface, fontSize: 15),
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Text(
      label,
      style: TextStyle(
        color: colors.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildFooter() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: ElevatedButton(
          onPressed: _isBusy ? null : _submit,
          child: _isSubmitting
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onPrimary,
                  ),
                )
              : Text(_isEditing ? "Save Changes" : "Create List"),
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hint,
      errorMaxLines: 2,
      border: _border(),
      enabledBorder: _border(),
      disabledBorder: _border(),
      focusedBorder: _border(colors.primary),
      errorBorder: _border(colors.error),
      focusedErrorBorder: _border(colors.error),
    );
  }

  OutlineInputBorder _border([Color? color]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(_fieldRadius),
    borderSide: color == null
        ? BorderSide.none
        : BorderSide(color: color, width: 1.5),
  );
}
