import 'package:flix_desktop/enums/cast_role.dart';
import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flix_desktop/models/cast_member.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/providers/cast_provider.dart';
import 'package:flix_desktop/screens/details/cast_details.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/paged_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CastList extends StatefulWidget {
  const CastList({ super.key, });

  @override
  _CastListState createState() => _CastListState();
}

class _CastListState extends State<CastList> {
  static const int _photoFlex = 8;
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

  Future<void> initTable() async {
    await Future.wait([_search(page: 1)]);
  }

  Future<void> _openDetails([CastMember? cast]) async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => CastDetails(cast: cast)),
    );

    if (saved == true && mounted) await _search();
  }

  Future<void> _deleteCastMember(CastMember cast) async {
    final int? id = cast.id;
    if (id == null) return;

    final String name = cast.fullName ?? "this cast member";

    final bool confirmed = await confirmBox(
      context,
      "Delete cast member",
      "Delete $name? This also removes their credits on every movie, and cannot be undone.",
    );

    if (!confirmed || !mounted) return;

    try {
      await _castProvider.delete(id);
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
            Expanded(
              child: PagedTable<CastMember>(
                columns: _columns,
                items: result?.items ?? List.empty(),
                isLoading: isLoading,
                emptyMessage: "No cast members found",
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
            onPressed: () => _openDetails(),
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

  List<TableColumn<CastMember>> get _columns => [
        TableColumn<CastMember>.custom(
          label: "PHOTO",
          flex: _photoFlex,
          builder: (context, cast) => TableThumbnail(
            url: cast.photo,
            icon: Icons.person_outline,
            borderRadius: 17,
          ),
        ),
        TableColumn<CastMember>(
          label: "NAME",
          flex: _nameFlex,
          value: (cast) => cast.fullName ?? "-",
          bold: true,
        ),
        TableColumn<CastMember>(
          label: "ROLE",
          flex: _roleFlex,
          value: _formatRoles,
          muted: true,
        ),
        TableColumn<CastMember>(
          label: "NATIONALITY",
          flex: _nationalityFlex,
          value: (cast) => cast.country?.name ?? "-",
        ),
        TableColumn<CastMember>(
          label: "BIRTH DATE",
          flex: _dateFlex,
          value: (cast) => formatDate(cast.birthDate),
        ),
        TableColumn<CastMember>.actions(
          flex: _actionsFlex,
          onEdit: (cast) => _openDetails(cast),
          onDelete: _deleteCastMember,
        ),
      ];

  /// Someone who both acted in and directed something carries both roles.
  String _formatRoles(CastMember cast) {
    final List<String> names = cast.roles
        .where((role) => role != null)
        .map((role) => getRoleName(role!))
        .toList();

    return names.isEmpty ? "-" : names.join(", ");
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
