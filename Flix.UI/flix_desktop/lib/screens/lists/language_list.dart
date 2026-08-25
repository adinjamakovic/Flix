import 'package:flix_desktop/models/language.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/providers/language_provider.dart';
import 'package:flix_desktop/screens/details/language_details.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/paged_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageList extends StatefulWidget {
  const LanguageList({super.key});

  @override
  State<LanguageList> createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  static const int _pageSize = 8;

  static const int _nameFlex = 34;
  static const int _codeFlex = 14;
  static const int _actionsFlex = 14;

  late LanguageProvider _languageProvider;
  SearchResult<Language>? result;
  bool isLoading = true;
  int _page = 1;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _languageProvider = context.read<LanguageProvider>();

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

  Future<void> _openDetails([Language? language]) async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (context) => LanguageDetails(language: language)),
    );

    if (saved == true && mounted) await _search();
  }

  Future<void> _deleteLanguage(Language language) async {
    final int? id = language.id;
    if (id == null) return;

    final String name = language.name ?? "this language";

    final bool confirmed = await confirmBox(
      context,
      "Delete language",
      "Delete $name? Movies still set to it have to be moved first.",
    );

    if (!confirmed || !mounted) return;

    try {
      await _languageProvider.delete(id);
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
          await _languageProvider.get(filter: _buildFilter(requestedPage));

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
            child: PagedTable<Language>(
              columns: _columns,
              items: result?.items ?? List.empty(),
              isLoading: isLoading,
              emptyMessage: "No languages found",
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
            child: const Text("Add a language"),
          ),
        ),
      ],
    );
  }

  List<TableColumn<Language>> get _columns => [
        TableColumn<Language>(
          label: "NAME",
          flex: _nameFlex,
          value: (language) => language.name ?? "-",
          bold: true,
        ),
        TableColumn<Language>(
          label: "CODE",
          flex: _codeFlex,
          value: (language) => language.code ?? "-",
          muted: true,
        ),
        TableColumn<Language>.actions(
          flex: _actionsFlex,
          onEdit: (language) => _openDetails(language),
          onDelete: _deleteLanguage,
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
