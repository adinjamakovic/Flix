import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flix_desktop/models/country.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/models/user.dart';
import 'package:flix_desktop/providers/country_provider.dart';
import 'package:flix_desktop/providers/user_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/paged_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserList extends StatefulWidget {
  const UserList({ super.key, });

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  static const int _pageSize = 6;
  int _page = 1;

  /// The country dropdown filters client-side, so it pulls the whole list once.
  static const int _countryPageSize = 200;

  static const int _emailFlex = 26;
  static const int _usernameFlex = 22;
  static const int _countryFlex = 10;
  static const int _joinDateFlex = 16;
  static const int _moviesWatchedFlex = 12;
  static const int _reviewsCreatedFlex = 12;
  static const int _statusFlex = 12;
  static const int _actionsFlex = 14;

  late UserProvider _userProvider;
  late CountryProvider _countryProvider;
  SearchResult<User>? result;
  bool isLoading = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final FocusNode _countryFocusNode = FocusNode();

  static const String _anyCountryLabel = "Any Country";

  List<Country> _countries = List.empty();
  bool _countriesLoading = true;
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();

    _userProvider = context.read<UserProvider>();
    _countryProvider = context.read<CountryProvider>();
    _countryFocusNode.addListener(_syncCountryText);

    initTable();
  }

  @override
  void dispose() {
    _usernameController.dispose();
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
      // COUNTRY reads the code off the country navigation property, and MOVIES
      // WATCHED / REVIEWS are projected from the review collection, which the
      // API only loads when these are set.
      "includeCountry": true,
      "includeReviews": true,
    };

    if (_usernameController.text.trim().isNotEmpty) {
      filter["username"] = _usernameController.text.trim();
    }

    final int? countryId = _selectedCountry?.id;
    if (countryId != null) {
      filter["countryId"] = countryId;
    }

    return filter;
  }

  Future<void> _search({int? page}) async {
    final int requestedPage = page ?? _page;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await _userProvider.get(filter: _buildFilter(requestedPage));

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

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "",
      destination: DrawerDestination.users,
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
              child: PagedTable<User>(
                columns: _columns,
                items: result?.items ?? List.empty(),
                isLoading: isLoading,
                emptyMessage: "No users found",
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
          "User Management",
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Manage your registered users",
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
            label: "Username",
            hint: "Search by username...",
            controller: _usernameController,
            icon: Icons.search,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 26,
          child: _buildCountryPicker(),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: () {
              print("TODO: implement user_details.dart");
            },
            child: const Text("Add a user"),
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

  Widget _buildCountryPicker() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Country"),
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

  List<TableColumn<User>> get _columns => [
        TableColumn<User>(
          label: "USERNAME",
          flex: _usernameFlex,
          value: (user) => user.username ?? "-",
          bold: true,
        ),
        TableColumn<User>(
          label: "EMAIL",
          flex: _emailFlex,
          value: (user) => user.email ?? "-",
          muted: true,
        ),
        TableColumn<User>(
          label: "COUNTRY",
          flex: _countryFlex,
          value: (user) => user.country?.code ?? "-",
        ),
        TableColumn<User>(
          label: "JOIN DATE",
          flex: _joinDateFlex,
          value: (user) => _formatDate(user.createdAt),
        ),
        TableColumn<User>(
          label: "MOVIES WATCHED",
          flex: _moviesWatchedFlex,
          value: (user) => user.moviesWatched?.toString() ?? "-",
        ),
        TableColumn<User>(
          label: "REVIEWS",
          flex: _reviewsCreatedFlex,
          value: (user) => user.reviewsWritten?.toString() ?? "-",
        ),
        TableColumn<User>.custom(
          label: "STATUS",
          flex: _statusFlex,
          builder: _buildStatusBadge,
        ),
        TableColumn<User>.actions(
          flex: _actionsFlex,
          onEdit: (user) {
            print("TODO: implement user_details.dart");
          },
          onDelete: (user) {},
        ),
      ];

  Widget _buildStatusBadge(BuildContext context, User user) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isActive = user.isActive ?? false;

    // The palette has no "success" colour, so ACTIVE stays neutral and only
    // INACTIVE is tinted.
    final Color foreground = isActive ? colors.onSurface : colors.error;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isActive ? "ACTIVE" : "INACTIVE",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foreground,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return "$day/$month/${date.year}";
  }

  /// The dropdown leaves whatever was typed in the field, so on focus loss the
  /// text is snapped back to whatever is actually being filtered on.
  void _syncCountryText() {
    if(_countryFocusNode.hasFocus) return;

    final String text = _selectedCountry == null
      ? ""
      : (_selectedCountry!.name ?? "-");


    if(_countryController.text != text) {
      _countryController.text = text;
    }
  }
}
