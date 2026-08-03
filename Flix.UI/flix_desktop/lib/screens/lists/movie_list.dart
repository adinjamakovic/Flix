import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flix_desktop/models/country.dart';
import 'package:flix_desktop/models/movie.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/providers/country_provider.dart';
import 'package:flix_desktop/providers/movie_provider.dart';
import 'package:flix_desktop/screens/details/movie_details.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
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
  static const int _countryPageSize = 1000;

  static const int _earliestYear = 1900;

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

  int get _totalPages {
    final int totalCount = result?.totalCount ?? 0;
    final int pages = (totalCount / _pageSize).ceil();
    return pages < 1 ? 1 : pages;
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

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return "$day/$month/${date.year}";
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
            Expanded(child: _buildTable()),
            const SizedBox(height: 12),
            _buildPagination(),
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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MovieDetails(movie: null,),
                  )
              );
            },
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

  Widget _buildTable() {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<Movie> movies = result?.items ?? List.empty();

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : movies.isEmpty
                    ? Center(
                        child: Text(
                          "No movies found",
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      )
                    : ListView.separated(
                        itemCount: movies.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: colors.outlineVariant,
                        ),
                        itemBuilder: (context, index) => _buildRow(movies[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      height: 46,
      color: colors.tertiary,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _buildHeaderCell("TITLE", _titleFlex),
          _buildHeaderCell("DIRECTOR", _directorFlex),
          _buildHeaderCell("COUNTRY", _countryFlex),
          _buildHeaderCell("RELEASE DATE", _releaseDateFlex),
          _buildHeaderCell("GENRE", _genreFlex),
          _buildHeaderCell("RATING", _ratingFlex),
          _buildHeaderCell("VIEWS", _viewsFlex),
          _buildHeaderCell("ACTIONS", _actionsFlex),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, int flex) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colors.onTertiary,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildRow(Movie movie) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _buildCell(movie.title ?? "-", _titleFlex, bold: true),
          _buildCell(movie.directorName ?? "-", _directorFlex, muted: true),
          _buildCell(movie.country?.name ?? "-", _countryFlex),
          _buildCell(_formatDate(movie.releaseDate), _releaseDateFlex),
          _buildCell(movie.genreNames ?? "-", _genreFlex),
          _buildCell("${movie.rating?.toStringAsFixed(1) ?? "-"}/5.0", _ratingFlex),
          _buildCell(movie.views?.toString() ?? "-", _viewsFlex),
          Expanded(
            flex: _actionsFlex,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MovieDetails(movie: movie,))
                    );
                  },
                  icon: const Icon(Icons.edit_square, size: 20),
                  color: colors.onSurface,
                  tooltip: "Edit",
                  splashRadius: 20,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: colors.onSurface,
                  tooltip: "Delete",
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String value, int flex,
      {bool bold = false, bool muted = false}) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Expanded(
      flex: flex,
      child: Text(
        value,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: muted ? colors.onSurfaceVariant : colors.onSurface,
          fontSize: 13.5,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int totalPages = _totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: _page > 1 ? () => _search(page: _page - 1) : null,
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text("Previous"),
          style: TextButton.styleFrom(
            foregroundColor: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        ..._pageNumbers(totalPages).map((page) => page == null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  "...",
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              )
            : _buildPageButton(page)),
        const SizedBox(width: 4),
        TextButton.icon(
          onPressed: _page < totalPages ? () => _search(page: _page + 1) : null,
          icon: const Icon(Icons.arrow_forward, size: 16),
          label: const Text("Next"),
          iconAlignment: IconAlignment.end,
          style: TextButton.styleFrom(
            foregroundColor: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPageButton(int page) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool selected = page == _page;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: selected ? null : () => _search(page: page),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            page.toString(),
            style: TextStyle(
              color: selected ? colors.onSecondary : colors.onSurfaceVariant,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  List<int?> _pageNumbers(int totalPages) {
    if (totalPages <= 7) {
      return List<int?>.generate(totalPages, (index) => index + 1);
    }

    final Set<int> pages = {1, 2, 3, totalPages - 1, totalPages};
    for (int page = _page - 1; page <= _page + 1; page++) {
      if (page >= 1 && page <= totalPages) pages.add(page);
    }

    final List<int> sorted = pages.toList()..sort();
    final List<int?> withGaps = [];
    for (int i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) withGaps.add(null);
      withGaps.add(sorted[i]);
    }

    return withGaps;
  }
}
