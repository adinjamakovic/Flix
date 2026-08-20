import 'dart:async';

import 'package:flix_mobile/models/country.dart';
import 'package:flix_mobile/models/genre.dart';
import 'package:flix_mobile/models/language.dart';
import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/country_provider.dart';
import 'package:flix_mobile/providers/genre_provider.dart';
import 'package:flix_mobile/providers/language_provider.dart';
import 'package:flix_mobile/providers/movie_provider.dart';
import 'package:flix_mobile/screens/movie_details/movie_details.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  static const int _pageSize = 20;

  static const int _lookupPageSize = 200;

  // Typing fires a search on its own; this is how long it waits for the next
  // keystroke first.
  static const Duration _debounce = Duration(milliseconds: 400);

  static const double _loadMoreThreshold = 300;

  static const int _maxPreviousSearches = 5;

  static const double _posterWidth = 72;
  static const double _posterHeight = 108;

  // Nothing local is persisted yet, so previous searches are kept statically —
  // they survive a rebuild of the tab, but not a restart of the app.
  static final List<String> _previousSearches = <String>[];

  late MovieProvider _movieProvider;
  late GenreProvider _genreProvider;
  late LanguageProvider _languageProvider;
  late CountryProvider _countryProvider;

  final TextEditingController _titleController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  bool _filtersExpanded = false;

  List<Genre> _genres = List.empty();
  List<Language> _languages = List.empty();
  List<Country> _countries = List.empty();
  bool _lookupsLoading = true;

  Genre? _selectedGenre;
  Language? _selectedLanguage;
  Country? _selectedCountry;

  final List<Movie> _movies = <Movie>[];
  int _totalCount = 0;
  int _page = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Results come back out of order when the user keeps typing, so every
  // request carries a token and only the newest one is allowed to land.
  int _requestToken = 0;

  bool get _hasQuery => _titleController.text.trim().isNotEmpty;

  bool get _hasFilters =>
      _selectedGenre != null ||
      _selectedLanguage != null ||
      _selectedCountry != null;

  bool get _isSearchActive => _hasQuery || _hasFilters;

  bool get _hasMorePages => _movies.length < _totalCount;

  @override
  void initState() {
    super.initState();

    _movieProvider = context.read<MovieProvider>();
    _genreProvider = context.read<GenreProvider>();
    _languageProvider = context.read<LanguageProvider>();
    _countryProvider = context.read<CountryProvider>();

    _scrollController.addListener(_onScroll);

    _loadLookups();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    try {
      final List<dynamic> results = await Future.wait([
        _genreProvider.get(filter: _lookupFilter),
        _languageProvider.get(filter: _lookupFilter),
        _countryProvider.get(filter: _lookupFilter),
      ]);

      if (!mounted) return;

      setState(() {
        _genres = _sorted<Genre>(results[0], (genre) => genre.name);
        _languages = _sorted<Language>(results[1], (language) => language.name);
        _countries = _sorted<Country>(results[2], (country) => country.name);
        _lookupsLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _lookupsLoading = false;
      });
      _showError(e);
    }
  }

  Map<String, dynamic> get _lookupFilter => {
    "page": 1,
    "pageSize": _lookupPageSize,
  };

  List<T> _sorted<T>(SearchResult<T> result, String? Function(T) nameOf) {
    final List<T> items = itemsOf(result);

    items.sort(
      (a, b) => (nameOf(a) ?? "").toLowerCase().compareTo(
        (nameOf(b) ?? "").toLowerCase(),
      ),
    );

    return items;
  }

  Map<String, dynamic> _buildFilter(int page) {
    final Map<String, dynamic> filter = {
      "page": page,
      "pageSize": _pageSize,
      "includeTotalCount": true,
      "includeReviews": true,
      "isEnabled": true,
    };

    final String title = _titleController.text.trim();
    if (title.isNotEmpty) filter["title"] = title;

    final int? genreId = _selectedGenre?.id;
    if (genreId != null) filter["genreId"] = genreId;

    final int? languageId = _selectedLanguage?.id;
    if (languageId != null) filter["languageId"] = languageId;

    final int? countryId = _selectedCountry?.id;
    if (countryId != null) filter["countryId"] = countryId;

    return filter;
  }

  Future<void> _search({bool loadMore = false}) async {
    if (!_isSearchActive) {
      _clearResults();
      return;
    }

    final int page = loadMore ? _page + 1 : 1;
    final int token = ++_requestToken;

    setState(() {
      _isLoading = !loadMore;
      _isLoadingMore = loadMore;
      _error = null;
    });

    try {
      final SearchResult<Movie> data = await _movieProvider.get(
        filter: _buildFilter(page),
      );

      if (!mounted || token != _requestToken) return;

      setState(() {
        if (!loadMore) _movies.clear();
        _movies.addAll(itemsOf(data));
        _totalCount = data.totalCount ?? _movies.length;
        _page = page;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } on Exception catch (e) {
      if (!mounted || token != _requestToken) return;

      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _error = errorText(e);
      });
    }
  }

  void _clearResults() {
    // Anything still in flight belongs to a query that no longer exists.
    _requestToken++;

    setState(() {
      _movies.clear();
      _totalCount = 0;
      _page = 1;
      _isLoading = false;
      _isLoadingMore = false;
      _error = null;
    });
  }

  void _onQueryChanged(String _) {
    _debounceTimer?.cancel();

    // The button row and the previous-searches list both depend on whether the
    // box is empty, so a repaint is needed on every keystroke either way.
    setState(() {});

    if (!_isSearchActive) {
      _clearResults();
      return;
    }

    _debounceTimer = Timer(_debounce, () => _search());
  }

  void _onQuerySubmitted(String value) {
    _debounceTimer?.cancel();
    _rememberSearch(value);
    _search();
  }

  void _onFilterChanged(VoidCallback apply) {
    _debounceTimer?.cancel();

    setState(apply);

    if (_isSearchActive) {
      _search();
    } else {
      _clearResults();
    }
  }

  void _onScroll() {
    if (_isLoading || _isLoadingMore || !_hasMorePages) return;

    final double remaining =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;

    if (remaining <= _loadMoreThreshold) _search(loadMore: true);
  }

  // Keeps the most recent titles, newest first, without duplicates.
  void _rememberSearch(String value) {
    final String title = value.trim();
    if (title.isEmpty) return;

    setState(() {
      _previousSearches.removeWhere(
        (entry) => entry.toLowerCase() == title.toLowerCase(),
      );
      _previousSearches.insert(0, title);

      if (_previousSearches.length > _maxPreviousSearches) {
        _previousSearches.removeRange(
          _maxPreviousSearches,
          _previousSearches.length,
        );
      }
    });
  }

  void _onPreviousSearchTapped(String title) {
    _debounceTimer?.cancel();

    _titleController.text = title;
    _titleController.selection = TextSelection.collapsed(offset: title.length);

    _rememberSearch(title);
    _search();
  }

  void _onMovieTapped(Movie movie) {
    _rememberSearch(movie.title ?? "");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MovieDetails(movieId: movie.id)),
    );
  }

  void _clearQuery() {
    _debounceTimer?.cancel();
    _titleController.clear();

    if (_isSearchActive) {
      _search();
    } else {
      _clearResults();
    }
  }

  void _showError(Exception e) => showSnack(context, errorText(e));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FLIX")),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 14),
                  _buildFiltersButton(),
                  _buildFilterPanel(),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _isSearchActive
                  ? _buildResults()
                  : _buildPreviousSearches(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return TextField(
      controller: _titleController,
      textInputAction: TextInputAction.search,
      onChanged: _onQueryChanged,
      onSubmitted: _onQuerySubmitted,
      style: TextStyle(color: colors.onSurface, fontSize: 15),
      decoration: InputDecoration(
        hintText: "Search by title...",
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

  Widget _buildFiltersButton() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: () => setState(() => _filtersExpanded = !_filtersExpanded),
        icon: Icon(
          Icons.filter_alt_outlined,
          size: 20,
          color: _hasFilters ? colors.primary : colors.onSurfaceVariant,
        ),
        label: Text(
          "Filters",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: _hasFilters ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// The three dropdowns only exist once "Filters" has been tapped.
  Widget _buildFilterPanel() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      alignment: Alignment.topCenter,
      curve: Curves.easeOut,
      child: !_filtersExpanded
          ? const SizedBox(width: double.infinity)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 14),
                _buildDropdown<Genre>(
                  allLabel: "All Genres",
                  value: _selectedGenre,
                  items: _genres,
                  labelOf: (genre) => genre.name ?? "-",
                  onChanged: (genre) =>
                      _onFilterChanged(() => _selectedGenre = genre),
                ),
                const SizedBox(height: 10),
                _buildDropdown<Language>(
                  allLabel: "All Languages",
                  value: _selectedLanguage,
                  items: _languages,
                  labelOf: (language) => language.name ?? "-",
                  onChanged: (language) =>
                      _onFilterChanged(() => _selectedLanguage = language),
                ),
                const SizedBox(height: 10),
                _buildDropdown<Country>(
                  allLabel: "All Countries",
                  value: _selectedCountry,
                  items: _countries,
                  labelOf: (country) => country.name ?? "-",
                  onChanged: (country) =>
                      _onFilterChanged(() => _selectedCountry = country),
                ),
              ],
            ),
    );
  }

  /// One pill-shaped dropdown. The first entry (`null`) is the "no filter"
  /// option, which is also what the collapsed field shows.
  Widget _buildDropdown<T>({
    required String allLabel,
    required T? value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T?> onChanged,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: InputDecorator(
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T?>(
            value: value,
            isExpanded: true,
            isDense: true,
            alignment: AlignmentDirectional.centerStart,
            menuMaxHeight: 340,
            borderRadius: BorderRadius.circular(12),
            dropdownColor: colors.surfaceContainerHigh,
            icon: Icon(Icons.menu, size: 20, color: colors.onSurfaceVariant),
            style: TextStyle(color: colors.onSurface, fontSize: 15),
            hint: Text(
              _lookupsLoading ? "Loading..." : allLabel,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 15),
            ),
            items: [
              DropdownMenuItem<T?>(
                value: null,
                child: Text(
                  allLabel,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
              ),
              ...items.map(
                (item) => DropdownMenuItem<T?>(
                  value: item,
                  child: Text(labelOf(item), overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: _lookupsLoading ? null : onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviousSearches() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Text(
            "Previous searches",
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (_previousSearches.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Text(
              "Titles you search for show up here.",
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _previousSearches.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final String title = _previousSearches[index];

                return InkWell(
                  onTap: () => _onPreviousSearchTapped(title),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Text(
                      title,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildResults() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return buildMessage(
        context,
        _error!,
        action: TextButton(
          onPressed: () => _search(),
          child: const Text("Try again"),
        ),
      );
    }

    if (_movies.isEmpty) {
      return buildMessage(context, "No movies match your search.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Text(
            "$_totalCount ${_totalCount == 1 ? "match" : "matches"} found",
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            // One extra row carries the next-page spinner.
            itemCount: _movies.length + (_isLoadingMore ? 1 : 0),
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              if (index >= _movies.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return _buildMovieRow(_movies[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieRow(Movie movie) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int? year = movie.releaseDate?.year;

    return InkWell(
      onTap: () => _onMovieTapped(movie),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildPoster(
              context,
              movie.poster,
              width: _posterWidth,
              height: _posterHeight,
              iconSize: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title ?? "-",
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    year?.toString() ?? "-",
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  buildRating(
                    context,
                    movie.rating,
                    size: 18,
                    emptyLabel: "Not rated yet",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
