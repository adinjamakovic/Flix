import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flix_desktop/models/country.dart';
import 'package:flix_desktop/models/movie.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/providers/country_provider.dart';
import 'package:flix_desktop/providers/movie_provider.dart';
import 'package:flix_desktop/screens/details/movie_details.dart';
import 'package:flix_desktop/screens/lists/movie_request_list.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/paged_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieList extends StatefulWidget {
  const MovieList({super.key});

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  static const int _pageSize = 6;

  /// The country dropdown filters client-side, so it pulls the whole list once.
  static const int _countryPageSize = 200;

  static const int _earliestYear = 1900;

  static const int _posterFlex = 8;
  static const int _titleFlex = 26;
  static const int _directorFlex = 22;
  static const int _countryFlex = 10;
  static const int _releaseDateFlex = 16;
  static const int _genreFlex = 12;
  static const int _ratingFlex = 12;
  static const int _viewsFlex = 12;
  static const int _actionsFlex = 14;

  late MovieProvider _movieProvider;
  late CountryProvider _countryProvider;
  SearchResult<Movie>? result;
  bool isLoading = true;
  int _page = 1;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final FocusNode _countryFocusNode = FocusNode();

  static const String _anyCountryLabel = "Any country";

  List<Country> _countries = List.empty();
  bool _countriesLoading = true;
  Country? _selectedCountry;

  int? _selectedYear;
  late final List<int> _years;

  @override
  void initState() {
    super.initState();

    _movieProvider = context.read<MovieProvider>();
    _countryProvider = context.read<CountryProvider>();
    _countryFocusNode.addListener(_syncCountryText);

    final int currentYear = DateTime.now().year;
    _years = List<int>.generate(
      currentYear - _earliestYear + 1,
      (index) => currentYear - index,
    );

    initTable();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _directorController.dispose();
    _countryController.dispose();
    _countryFocusNode.removeListener(_syncCountryText);
    _countryFocusNode.dispose();
    super.dispose();
  }

  Future<void> initTable() async {
    await Future.wait([_loadCountries(), _search(page: 1)]);
  }

  Future<void> _loadCountries() async {
    try {
      final data = await _countryProvider.get(
        filter: {"page": 1, "pageSize": _countryPageSize},
      );

      if (!mounted) return;

      final List<Country> countries = data.items ?? List.empty();
      countries.sort(
        (a, b) => (a.name ?? "").toLowerCase().compareTo((b.name ?? "").toLowerCase()),
      );

      setState(() {
        _countries = countries;
        _countriesLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _countriesLoading = false;
      });
      alertBox(context, "Error", e.toString());
    }
  }

  Map<String, dynamic> _buildFilter(int page) {
    final Map<String, dynamic> filter = {
      "page": page,
      "pageSize": _pageSize,
      "includeTotalCount": true,
      // The DIRECTOR and RATING columns are projected from the credit/review
      // collections, which the API only loads when these are set.
      "includeCast": true,
      "includeReviews": true,
      "isEnabled": true,
    };

    if(_directorController.text.trim().isNotEmpty) {
      filter["directorName"] = _directorController.text.trim();
    }

    if (_titleController.text.trim().isNotEmpty) {
      filter["title"] = _titleController.text.trim();
    }

    final int? countryId = _selectedCountry?.id;
    if (countryId != null) {
      filter["countryId"] = countryId;
    }

    final int? year = _selectedYear;
    if (year != null) {
      filter["releasedAfter"] = DateTime(year, 1, 1);
      filter["releasedBefore"] = DateTime(year, 12, 31, 23, 59, 59);
    }

    return filter;
  }

  Future<void> _search({int? page}) async {
    final int requestedPage = page ?? _page;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await _movieProvider.get(filter: _buildFilter(requestedPage));

      if (!mounted) return;

      setState(() {
        result = data;
        _page = requestedPage;
        isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
      alertBox(context, "Error", e.toString());
    }
  }

  Future<void> _openDetails([Movie? movie]) async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => MovieDetails(movie: movie)),
    );

    if (saved == true && mounted) await _search();
  }

  /// A new movie can either come from a user submission or be typed in from
  /// scratch, so the button asks which before opening anything.
  Future<void> _showAddMovieDialog() async {
    final _AddMovieChoice? choice = await showDialog<_AddMovieChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add a movie"),
        content: const Text(
          "Review the movies users have submitted, or fill in a blank form "
          "yourself.",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _AddMovieChoice.reviewSubmissions),
            child: const Text("Review submissions"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _AddMovieChoice.blankForm),
            child: const Text("Create from scratch"),
          ),
        ],
      ),
    );

    if (choice == null || !mounted) return;

    switch (choice) {
      case _AddMovieChoice.reviewSubmissions:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MovieRequestList()),
        );

        if (mounted) await _search();
      case _AddMovieChoice.blankForm:
        await _openDetails();
    }
  }

  Future<void> _deleteMovie(Movie movie) async {
    final int? id = movie.id;
    if (id == null) return;

    final String title = movie.title ?? "this movie";

    final bool confirmed = await confirmBox(
      context,
      "Delete movie",
      "Delete $title? This also removes its cast and genres, and cannot be undone.",
    );

    if (!confirmed || !mounted) return;

    try {
      await _movieProvider.delete(id);
    } on Exception catch (e) {
      if (!mounted) return;

      alertBox(context, "Error", e.toString());
      return;
    }

    if (!mounted) return;

    // Deleting the only row on the last page would otherwise leave the table
    // sitting on a page that no longer exists.
    final bool wasLastOnPage = (result?.items?.length ?? 0) == 1 && _page > 1;

    await _search(page: wasLastOnPage ? _page - 1 : _page);
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "",
      destination: DrawerDestination.movies,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 22),
            Expanded(
              child: PagedTable<Movie>(
                columns: _columns,
                items: result?.items ?? List.empty(),
                isLoading: isLoading,
                emptyMessage: "No movies found",
                page: _page,
                pageSize: _pageSize,
                totalCount: result?.totalCount ?? 0,
                onPageChanged: (page) => _search(page: page),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Movie Management",
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Manage your movie database",
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 26,
          child: _buildFilterField(
            label: "Movie title",
            hint: "Search by title...",
            controller: _titleController,
            icon: Icons.search,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 26,
          child: _buildFilterField(
            label: "Director name",
            hint: "Search by director...",
            controller: _directorController,
            icon: Icons.search,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 26,
          child: _buildCountryPicker(),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 26,
          child: _buildYearPicker(),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: _showAddMovieDialog,
            child: const Text("Add a movie"),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Text(
      label,
      style: TextStyle(
        color: colors.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildYearPicker() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Year of release"),
        const SizedBox(height: 6),
        SizedBox(
          height: 46,
          child: InputDecorator(
            isEmpty: _selectedYear == null,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: _selectedYear,
                isExpanded: true,
                isDense: true,
                alignment: AlignmentDirectional.centerStart,
                menuMaxHeight: 320,
                borderRadius: BorderRadius.circular(10),
                icon: Icon(Icons.expand_more, color: colors.onSurfaceVariant),
                style: TextStyle(color: colors.onSurface, fontSize: 14),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      "Any year",
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ..._years.map(
                    (year) => DropdownMenuItem<int?>(
                      value: year,
                      child: Text(year.toString()),
                    ),
                  ),
                ],
                onChanged: (year) {
                  setState(() {
                    _selectedYear = year;
                  });
                  _search(page: 1);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryPicker() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Country of origin"),
        const SizedBox(height: 6),
        SizedBox(
          height: 46,
          child: DropdownMenu<Country?>(
            controller: _countryController,
            focusNode: _countryFocusNode,
            enabled: !_countriesLoading,
            expandedInsets: EdgeInsets.zero,
            enableFilter: true,
            requestFocusOnTap: true,
            menuHeight: 320,
            hintText: _countriesLoading
                ? "Loading countries..."
                : "Search by country...",
            textStyle: TextStyle(color: colors.onSurface, fontSize: 14),
            trailingIcon: Icon(Icons.expand_more, color: colors.onSurfaceVariant),
            selectedTrailingIcon:
                Icon(Icons.expand_less, color: colors.onSurfaceVariant),
            inputDecorationTheme:
                Theme.of(context).inputDecorationTheme.copyWith(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
            menuStyle: MenuStyle(
              backgroundColor:
                  WidgetStatePropertyAll(colors.surfaceContainerLowest),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            dropdownMenuEntries: [
              DropdownMenuEntry<Country?>(
                value: null,
                label: _anyCountryLabel,
                style: MenuItemButton.styleFrom(
                  foregroundColor: colors.onSurfaceVariant,
                ),
              ),
              ..._countries.map(
                (country) => DropdownMenuEntry<Country?>(
                  value: country,
                  label: country.name ?? "-",
                ),
              ),
            ],
            onSelected: (country) {
              setState(() {
                _selectedCountry = country;
              });
              _search(page: 1);
            },
          ),
        ),
      ],
    );
  }

  /// The dropdown leaves whatever was typed in the field, so on focus loss the
  /// text is snapped back to whatever is actually being filtered on.
  void _syncCountryText() {
    if (_countryFocusNode.hasFocus) return;

    final String text = _selectedCountry == null
        ? ""
        : (_selectedCountry!.name ?? "-");

    if (_countryController.text != text) {
      _countryController.text = text;
    }
  }

  Widget _buildFilterField({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 6),
        SizedBox(
          height: 46,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(color: colors.onSurface, fontSize: 14),
            onSubmitted: (_) => _search(page: 1),
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: icon == null
                  ? null
                  : IconButton(
                      icon: Icon(icon, size: 20),
                      color: colors.onSurfaceVariant,
                      onPressed: () => _search(page: 1),
                    ),
            ),
          ),
        ),
      ],
    );
  }
  List<TableColumn<Movie>> get _columns => [
        TableColumn<Movie>.custom(
          label: "POSTER",
          flex: _posterFlex,
          builder: (context, movie) => TableThumbnail(
            url: movie.poster,
            icon: Icons.movie_outlined,
            width: 30,
            height: 44,
            borderRadius: 4,
          ),
        ),
        TableColumn<Movie>(
          label: "TITLE",
          flex: _titleFlex,
          value: (movie) => movie.title ?? "-",
          bold: true,
        ),
        TableColumn<Movie>(
          label: "DIRECTOR",
          flex: _directorFlex,
          value: (movie) => movie.directorName ?? "-",
          muted: true,
        ),
        TableColumn<Movie>(
          label: "COUNTRY",
          flex: _countryFlex,
          value: (movie) => movie.country?.name ?? "-",
        ),
        TableColumn<Movie>(
          label: "RELEASE DATE",
          flex: _releaseDateFlex,
          value: (movie) => formatDate(movie.releaseDate),
        ),
        TableColumn<Movie>(
          label: "GENRE",
          flex: _genreFlex,
          value: (movie) => movie.genreNames ?? "-",
        ),
        TableColumn<Movie>(
          label: "RATING",
          flex: _ratingFlex,
          value: (movie) => "${movie.rating?.toStringAsFixed(1) ?? "-"}/5.0",
        ),
        TableColumn<Movie>(
          label: "VIEWS",
          flex: _viewsFlex,
          value: (movie) => movie.views?.toString() ?? "-",
        ),
        TableColumn<Movie>.actions(
          flex: _actionsFlex,
          onEdit: (movie) => _openDetails(movie),
          onDelete: _deleteMovie,
        ),
      ];
}

enum _AddMovieChoice { reviewSubmissions, blankForm }
