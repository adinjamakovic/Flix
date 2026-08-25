import 'package:flix_desktop/models/genre.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/providers/genre_provider.dart';
import 'package:flix_desktop/screens/details/genre_details.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/paged_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GenreList extends StatefulWidget {
  const GenreList({super.key});

  @override
  State<GenreList> createState() => _GenreListState();
}

class _GenreListState extends State<GenreList> {
  static const int _pageSize = 8;

  static const int _nameFlex = 40;
  static const int _actionsFlex = 14;

  late GenreProvider _genreProvider;
  SearchResult<Genre>? result;
  bool isLoading = true;
  int _page = 1;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _genreProvider = context.read<GenreProvider>();

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

  Future<void> _openDetails([Genre? genre]) async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => GenreDetails(genre: genre)),
    );

    if (saved == true && mounted) await _search();
  }

  Future<void> _deleteGenre(Genre genre) async {
    final int? id = genre.id;
    if (id == null) return;

    final String name = genre.name ?? "this genre";

    final bool confirmed = await confirmBox(
      context,
      "Delete genre",
      "Delete $name? Movies still tagged with it have to be retagged first.",
    );

    if (!confirmed || !mounted) return;

    try {
      await _genreProvider.delete(id);
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
      final data = await _genreProvider.get(filter: _buildFilter(requestedPage));

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
            child: PagedTable<Genre>(
              columns: _columns,
              items: result?.items ?? List.empty(),
              isLoading: isLoading,
              emptyMessage: "No genres found",
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
            child: const Text("Add a genre"),
          ),
        ),
      ],
    );
  }

  List<TableColumn<Genre>> get _columns => [
        TableColumn<Genre>(
          label: "NAME",
          flex: _nameFlex,
          value: (genre) => genre.name ?? "-",
          bold: true,
        ),
        TableColumn<Genre>.actions(
          flex: _actionsFlex,
          onEdit: (genre) => _openDetails(genre),
          onDelete: _deleteGenre,
        ),
      ];

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
