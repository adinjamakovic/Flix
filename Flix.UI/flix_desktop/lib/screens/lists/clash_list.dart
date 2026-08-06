import 'package:flix_desktop/enums/clash_status.dart';
import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flix_desktop/models/clash.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/providers/clash_provider.dart';
import 'package:flix_desktop/screens/details/clash_details.dart';
import 'package:flix_desktop/screens/lists/clash_participant_list.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/paged_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class ClashList extends StatefulWidget {
  const ClashList({super.key});

  @override
  _ClashListState createState() => _ClashListState();
}

// Clashes are shown as a grid of cards rather than a table - a clash carries a
// status, a date range and a participant count that read better stacked than
// they do as columns. Paging is still server-side, same as every other list.
class _ClashListState extends State<ClashList> {
  static const int _pageSize = 8;

  static const double _cardMaxWidth = 340;
  static const double _cardHeight = 320;
  static const double _cardSpacing = 20;

  static const double _cardAccentHeight = 6;

  static const double _cardButtonHeight = 34;

  static const Color _activeColor = Color(0xFF15803D);
  static const Color _upcomingColor = Color(0xFF2563EB);

  static const Color _detailsForeground = Color(0xFF1D4ED8);
  static const Color _detailsBackground = Color(0xFFBFDBFE);

  late ClashProvider _clashProvider;
  SearchResult<Clash>? result;
  bool isLoading = true;
  int _page = 1;

  final TextEditingController _nameController = TextEditingController();
  ClashStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();

    _clashProvider = context.read<ClashProvider>();

    initGrid();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> initGrid() async {
    await _search(page: 1);
  }

  Future<void> _openForm([Clash? clash]) async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => ClashDetails(clash: clash))
      );

      if(saved == true && mounted) await _search();
  }

  // "Details" means two different things depending on the status: an upcoming
  // clash is still the admin's to edit, while an active or completed one is
  // only there to be looked at - who is currently placing where.
  Future<void> _openDetails(Clash clash) async {
    if (clash.status == ClashStatus.upcoming) {
      await _openForm(clash);
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClashParticipantList(clash: clash),
      ),
    );
  }

  Map<String, dynamic> _buildFilter(int page) {
    final Map<String, dynamic> filter = {
      "page": page,
      "pageSize": _pageSize,
      "includeTotalCount": true,
      "includeEntries": true,
    };

    if (_nameController.text.trim().isNotEmpty) {
      filter["name"] = _nameController.text.trim();
    }

    final ClashStatus? status = _selectedStatus;
    if (status != null) {
      filter["status"] = status.index;
    }

    return filter;
  }

  Future<void> _search({int? page}) async {
    final int requestedPage = page ?? _page;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await _clashProvider.get(filter: _buildFilter(requestedPage));

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

  Future<void> _deleteClash(Clash clash) async {
    final int? id = clash.id;
    if(id == null) return;

    final String name = clash.name ?? "this clash";

    final bool confirmed = await confirmBox(
      context,
      "Delete clash",
      "Delete $name? This will delete all the related lists aswell.");

      if(!confirmed || !mounted) return;

      try {
        await _clashProvider.delete(id);
      } on Exception catch (e) {
        if(!mounted) return;

        alertBox(context, "Error", e.toString());
        return;
      }

      if (!mounted) return;

    final bool wasLastOnPage = (result?.items?.length ?? 0) == 1 && _page > 1;

    await _search(page: wasLastOnPage ? _page - 1 : _page);
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "",
      destination: DrawerDestination.clashes,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 22),
            Expanded(child: _buildGrid()),
            const SizedBox(height: 12),
            Pagination(
              page: _page,
              pageSize: _pageSize,
              totalCount: result?.totalCount ?? 0,
              onPageChanged: (page) => _search(page: page),
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
          "Clashes",
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Manage themed movie competitions",
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
      children: [
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: () => _openForm(),
            child: const Text("Create a new clash"),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 240,
          height: 46,
          child: _buildNameField(),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 240,
          height: 46,
          child: _buildStatusPicker(),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return TextField(
      controller: _nameController,
      style: TextStyle(color: colors.onSurface, fontSize: 14),
      onSubmitted: (_) => _search(page: 1),
      decoration: InputDecoration(
        hintText: "Search by clash name...",
        suffixIcon: IconButton(
          icon: const Icon(Icons.search, size: 20),
          color: colors.onSurfaceVariant,
          onPressed: () => _search(page: 1),
        ),
      ),
    );
  }

  Widget _buildStatusPicker() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InputDecorator(
      isEmpty: _selectedStatus == null,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ClashStatus?>(
          value: _selectedStatus,
          isExpanded: true,
          isDense: true,
          alignment: AlignmentDirectional.centerStart,
          borderRadius: BorderRadius.circular(10),
          icon: Icon(Icons.expand_more, color: colors.onSurfaceVariant),
          style: TextStyle(color: colors.onSurface, fontSize: 14),
          hint: Text(
            "Search by clash status...",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
          ),
          items: [
            DropdownMenuItem<ClashStatus?>(
              value: null,
              child: Text(
                "Any status",
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
            ...ClashStatus.values.map(
              (status) => DropdownMenuItem<ClashStatus?>(
                value: status,
                child: Text(getClashStatus(status)),
              ),
            ),
          ],
          onChanged: (status) {
            setState(() {
              _selectedStatus = status;
            });
            _search(page: 1);
          },
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<Clash> clashes = result?.items ?? List.empty();

    if (clashes.isEmpty) {
      return Center(
        child: Text(
          "No clashes found",
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _cardMaxWidth,
        mainAxisExtent: _cardHeight,
        crossAxisSpacing: _cardSpacing,
        mainAxisSpacing: _cardSpacing,
      ),
      itemCount: clashes.length,
      itemBuilder: (context, index) => _buildClashCard(clashes[index]),
    );
  }

  Widget _buildClashCard(Clash clash) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.only(top: _cardAccentHeight),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(12),
            bottom: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(clash),
            const SizedBox(height: 14),
            Text(
              clash.name ?? "-",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              clash.description ?? "-",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            _buildCardRow("Start Date:", formatDate(clash.startDate)),
            _buildCardRow("End Date:", formatDate(clash.endDate)),
            _buildCardRow("Participants:", (clash.participants ?? 0).toString()),
            const Spacer(),
            Divider(height: 1, thickness: 1, color: colors.outlineVariant),
            const SizedBox(height: 12),
            _buildCardActions(clash),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(Clash clash) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final ClashStatus? status = clash.status;

    return Row(
      children: [
        Icon(Icons.workspace_premium_outlined, color: colors.primary, size: 26),
        const Spacer(),
        Text(
          status == null ? "-" : getClashStatus(status),
          style: TextStyle(
            color: _statusColor(status),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _statusColor(ClashStatus? status) {
    switch (status) {
      case ClashStatus.active:
        return _activeColor;
      case ClashStatus.upcoming:
        return _upcomingColor;
      case ClashStatus.completed:
      case null:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  Widget _buildCardRow(String label, String value) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Divider(height: 1, thickness: 1, color: colors.outlineVariant),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardActions(Clash clash) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildCardButton(
            icon: clash.status == ClashStatus.upcoming
                ? Icons.edit_square
                : Icons.leaderboard_outlined,
            label: "Details",
            foreground: _detailsForeground,
            background: _detailsBackground,
            onPressed: () => _openDetails(clash),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCardButton(
            icon: Icons.delete_outline,
            label: "Delete",
            foreground: colors.error,
            background: colors.error.withValues(alpha: 0.22),
            onPressed: () => {
              if(clash.status == ClashStatus.completed){
                alertBox(
                  context, "User Error", "You cant delete this clash!")
              } else {
              _deleteClash(clash)
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCardButton({
    required IconData icon,
    required String label,
    required Color foreground,
    required Color background,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(
        label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      style: TextButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: background,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, _cardButtonHeight),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
