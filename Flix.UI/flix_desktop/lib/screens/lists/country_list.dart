import 'package:flix_desktop/models/country.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/providers/country_provider.dart';
import 'package:flix_desktop/screens/details/country_details.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/paged_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CountryList extends StatefulWidget {
  const CountryList({super.key});

  @override
  State<CountryList> createState() => _CountryListState();
}

class _CountryListState extends State<CountryList> {
  static const int _pageSize = 8;

  static const int _flagFlex = 10;
  static const int _nameFlex = 34;
  static const int _codeFlex = 14;
  static const int _actionsFlex = 14;

  late CountryProvider _countryProvider;
  SearchResult<Country>? result;
  bool isLoading = true;
  int _page = 1;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _countryProvider = context.read<CountryProvider>();

    initTable();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> initTable() async {
    await _search(page: 1);
  }

  Future<void> _openDetails([Country? country]) async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => CountryDetails(country: country)),
    );

    if (saved == true && mounted) await _search();
  }

  Future<void> _deleteCountry(Country country) async {
    final int? id = country.id;
    if (id == null) return;

    final String name = country.name ?? "this country";

    final bool confirmed = await confirmBox(
      context,
      "Delete country",
      "Delete $name? Movies and users still set to it have to be moved first.",
    );

    if (!confirmed || !mounted) return;

    try {
      await _countryProvider.delete(id);
    } on Exception catch (e) {
      if (!mounted) return;

      alertBox(context, "Error", e.toString());
      return;
    }

    if (!mounted) return;

    final bool wasLastOnPage = (result?.items?.length ?? 0) == 1 && _page > 1;

    await _search(page: wasLastOnPage ? _page - 1 : _page);
  }

  Map<String, dynamic> _buildFilter(int page) {
    final Map<String, dynamic> filter = {
      "page": page,
      "pageSize": _pageSize,
      "includeTotalCount": true,
    };

    if (_nameController.text.trim().isNotEmpty) {
      filter["name"] = _nameController.text.trim();
    }

    return filter;
  }

  Future<void> _search({int? page}) async {
    final int requestedPage = page ?? _page;

    setState(() {
      isLoading = true;
    });

    try {
      final data =
          await _countryProvider.get(filter: _buildFilter(requestedPage));

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 18, 32, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(),
          const SizedBox(height: 22),
          Expanded(
            child: PagedTable<Country>(
              columns: _columns,
              items: result?.items ?? List.empty(),
              isLoading: isLoading,
              emptyMessage: "No countries found",
              page: _page,
              pageSize: _pageSize,
              totalCount: result?.totalCount ?? 0,
              onPageChanged: (page) => _search(page: page),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 40,
          child: _buildFilterField(
            label: "Name",
            hint: "Search by name...",
            controller: _nameController,
            icon: Icons.search,
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: () => _openDetails(),
            child: const Text("Add a country"),
          ),
        ),
      ],
    );
  }

  List<TableColumn<Country>> get _columns => [
        TableColumn<Country>.custom(
          label: "FLAG",
          flex: _flagFlex,
          builder: _buildFlag,
        ),
        TableColumn<Country>(
          label: "NAME",
          flex: _nameFlex,
          value: (country) => country.name ?? "-",
          bold: true,
        ),
        TableColumn<Country>(
          label: "CODE",
          flex: _codeFlex,
          value: (country) => country.code ?? "-",
          muted: true,
        ),
        TableColumn<Country>.actions(
          flex: _actionsFlex,
          onEdit: (country) => _openDetails(country),
          onDelete: _deleteCountry,
        ),
      ];

  Widget _buildFlag(BuildContext context, Country country) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    // Flags arrive as expiring SAS URLs, so anything that is not an http(s)
    // URL, or that fails to load, falls back to the placeholder.
    final Uri? uri = Uri.tryParse(country.flagImage ?? "");
    final bool isNetworkImage =
        uri != null && (uri.scheme == "http" || uri.scheme == "https");

    final Widget placeholder = Icon(
      Icons.flag_outlined,
      size: 16,
      color: colors.onSurfaceVariant,
    );

    return Center(
      child: Container(
        width: 38,
        height: 26,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: isNetworkImage
            ? Image.network(
                uri.toString(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => placeholder,
              )
            : placeholder,
      ),
    );
  }

  Widget _buildFilterField({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? icon,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 46,
          child: TextField(
            controller: controller,
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
}
