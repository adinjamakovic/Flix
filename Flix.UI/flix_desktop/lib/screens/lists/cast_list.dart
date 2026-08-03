import 'package:flix_desktop/enums/cast_role.dart';
import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flix_desktop/models/cast_member.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/providers/cast_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CastList extends StatefulWidget {
  const CastList({ super.key, });

  @override
  _CastListState createState() => _CastListState();
}

class _CastListState extends State<CastList> {
  static const int _nameFlex = 22;
  static const int _roleFlex = 12;
  static const int _nationalityFlex = 12;
  static const int _dateFlex = 12;
  static const int _actionsFlex = 14;

  late CastProvider _castProvider;
  SearchResult<CastMember>? result;
  bool isLoading = true;
  int _page = 1;
  static const int _pageSize = 6;

  final TextEditingController _nameController = TextEditingController();

  CastRole? _selectedRole;

  @override
  void initState() {
    super.initState();

    _castProvider = context.read<CastProvider>();

    initTable();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int get _totalPages {
    final int totalCount = result?.totalCount ?? 0;
    final int pages = (totalCount / _pageSize).ceil();
    return pages < 1 ? 1 : pages;
  }

  Future<void> initTable() async {
    await Future.wait([_search(page: 1)]);
  }

  Map<String, dynamic> _buildFilter(int page) {
    final Map<String, dynamic> filter = {
      "page": page,
      "pageSize": _pageSize,
      "includeTotalCount": true,
      "includeCountry": true,
      "includeRoles": true
    };

    if(_nameController.text.trim().isNotEmpty){
      filter["name"] = _nameController.text.trim();
    }

    // The API takes a list of roles; the picker is single-select, so it sends a
    // one-element list and omits the key entirely for "Any role".
    if (_selectedRole != null) {
      filter["roles"] = [getRoleName(_selectedRole!)];
    }

    return filter;
  }

  Future<void> _search({int? page}) async {
    final int requestedPage = page ?? _page;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await _castProvider.get(filter: _buildFilter(requestedPage));

      if(!mounted) return;

      setState(() {
        result = data;
        _page = requestedPage;
        isLoading = false;
      });
    } on Exception catch (e) {
      if(!mounted) return;

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
      destination: DrawerDestination.cast,
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
          "Cast Management",
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Manage your movie cast database",
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 14
          )
        )
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
            label: "Full name",
            hint: "Search by name...",
            controller: _nameController,
            icon: Icons.search
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 26,
          child: _buildRolePicker(),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: () {
              print("TODO: implement cast_details.dart");
            }, 
            child: const Text("Add a cast member")),
        )
      ],
    );
  }


  Widget _buildRolePicker() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Role"),
        const SizedBox(height: 6),
        SizedBox(
          height: 46,
          child: InputDecorator(
            isEmpty: _selectedRole == null,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CastRole?>(
                value: _selectedRole,
                isExpanded: true,
                isDense: true,
                alignment: AlignmentDirectional.centerStart,
                borderRadius: BorderRadius.circular(10),
                icon: Icon(Icons.expand_more, color: colors.onSurfaceVariant),
                style: TextStyle(color: colors.onSurface, fontSize: 14),
                items: [
                  DropdownMenuItem<CastRole?>(
                    value: null,
                    child: Text(
                      "Any role",
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ...CastRole.values.map(
                    (role) => DropdownMenuItem<CastRole?>(
                      value: role,
                      child: Text(getRoleName(role)),
                    ),
                  ),
                ],
                onChanged: (role) {
                  setState(() {
                    _selectedRole = role;
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

  Widget _buildTable() {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<CastMember> cast = result?.items ?? List.empty();

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        children: [
          _buildTableHeaders(),
          Expanded(
            child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : cast.isEmpty
              ? Center(
                child: Text(
                  "No cast members found",
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              )
              : ListView.separated(
                itemBuilder: (context, index) => _buildRow(cast[index]),
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.outlineVariant,
                ),
                 itemCount: cast.length)
              ),
        ],
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

  Widget _buildTableHeaders() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      height: 46,
      color: colors.tertiary,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _buildHeaderCell("NAME", _nameFlex),
          _buildHeaderCell("ROLE", _roleFlex),
          _buildHeaderCell("NATIONALITY", _nationalityFlex),
          _buildHeaderCell("BIRTH DATE", _dateFlex),
          _buildHeaderCell("ACTIONS", _actionsFlex),
        ],
      ),
    );
  }

  Widget _buildRow(CastMember cast) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _buildCell(cast.fullName ?? "-", _nameFlex, bold: true),
          _buildCell(_formatRoles(cast), _roleFlex, muted: true),
          _buildCell(cast.country?.name ?? "-", _nationalityFlex),
          _buildCell(_formatDate(cast.birthDate), _dateFlex),
          Expanded(
            flex: _actionsFlex,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    print("TODO: implement cast_details.dart");
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

  /// Someone who both acted in and directed something carries both roles.
  String _formatRoles(CastMember cast) {
    final List<String> names = cast.roles
        .where((role) => role != null)
        .map((role) => getRoleName(role!))
        .toList();

    return names.isEmpty ? "-" : names.join(", ");
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return "$day/$month/${date.year}";
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
      )
    );
  }

  Widget _buildFieldLabel(String label){
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Text(
      label,
      style: TextStyle(
        color: colors.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w500
      ),
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
                  icon: Icon(icon, size: 20,),
                  color: colors.onSurfaceVariant,
                  onPressed: () => _search(page: 1))
            ),
          ),
        )
      ],
    );
  }
}