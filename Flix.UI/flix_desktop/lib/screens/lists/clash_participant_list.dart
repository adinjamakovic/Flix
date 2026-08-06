import 'package:flix_desktop/enums/clash_status.dart';
import 'package:flix_desktop/models/clash.dart';
import 'package:flix_desktop/models/clash_entry.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/providers/clash_entry_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/paged_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Standings for a clash that is already running or has finished. Once a clash
/// is live it belongs to its participants, so there is nothing to edit here -
/// the screen only ranks the entries by the votes their lists have collected.
/// Upcoming clashes open `ClashDetails` instead.
class ClashParticipantList extends StatefulWidget {
  const ClashParticipantList({super.key, required this.clash});

  final Clash clash;

  @override
  State<ClashParticipantList> createState() => _ClashParticipantListState();
}

class _ClashParticipantListState extends State<ClashParticipantList> {
  static const int _pageSize = 8;

  static const int _rankFlex = 12;
  static const int _usernameFlex = 22;
  static const int _listFlex = 30;
  static const int _moviesFlex = 12;
  static const int _votesFlex = 12;
  static const int _submittedFlex = 16;

  // Podium colours for the first three places; everyone below stays neutral.
  static const Color _goldColor = Color(0xFFB8860B);
  static const Color _silverColor = Color(0xFF6E6E76);
  static const Color _bronzeColor = Color(0xFF9C5A2D);

  static const Color _activeColor = Color(0xFF15803D);

  static const double _rankBadgeSize = 30;

  late ClashEntryProvider _clashEntryProvider;
  SearchResult<ClashEntry>? result;
  bool isLoading = true;
  int _page = 1;

  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _clashEntryProvider = context.read<ClashEntryProvider>();

    initTable();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> initTable() async {
    await _search(page: 1);
  }

  Map<String, dynamic> _buildFilter(int page, int clashId) {
    final Map<String, dynamic> filter = {
      "page": page,
      "pageSize": _pageSize,
      "includeTotalCount": true,
      "includeUser": true,
      "includeMovieList": true,
      "clashId": clashId,
    };

    if (_usernameController.text.trim().isNotEmpty) {
      filter["username"] = _usernameController.text.trim();
    }

    return filter;
  }

  Future<void> _search({int? page}) async {
    final int? clashId = widget.clash.id;
    final int requestedPage = page ?? _page;

    // Without an id every entry in the database would come back, so an unsaved
    // clash simply shows as having no participants.
    if (clashId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final data = await _clashEntryProvider.get(
        filter: _buildFilter(requestedPage, clashId),
      );

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clash standings"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            _buildSummary(),
            const SizedBox(height: 22),
            _buildFilters(),
            const SizedBox(height: 22),
            Expanded(
              child: PagedTable<ClashEntry>(
                columns: _columns,
                items: result?.items ?? List.empty(),
                isLoading: isLoading,
                emptyMessage: "No one has entered this clash yet",
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
          widget.clash.name ?? "-",
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.clash.status == ClashStatus.completed
              ? "Final standings - the best rated lists in this clash"
              : "Live standings - the best rated lists in this clash right now",
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Row(
      children: [
        _buildStatusPill(),
        const SizedBox(width: 12),
        _buildMetaChip(
          Icons.date_range_outlined,
          "${formatDate(widget.clash.startDate)} - ${formatDate(widget.clash.endDate)}",
        ),
        const SizedBox(width: 12),
        _buildMetaChip(
          Icons.groups_outlined,
          "${widget.clash.participants ?? 0} participants",
        ),
      ],
    );
  }

  Widget _buildStatusPill() {
    final ClashStatus? status = widget.clash.status;
    final Color foreground = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status == null ? "-" : getClashStatus(status).toUpperCase(),
        style: TextStyle(
          color: foreground,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Color _statusColor(ClashStatus? status) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return status == ClashStatus.active ? _activeColor : colors.onSurfaceVariant;
  }

  Widget _buildMetaChip(IconData icon, String label) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: colors.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 13.5,
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
        const Spacer(flex: 78),
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
        _buildFieldLabel(label),
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

  List<TableColumn<ClashEntry>> get _columns => [
        TableColumn<ClashEntry>.custom(
          label: "RANK",
          flex: _rankFlex,
          builder: _buildRankBadge,
        ),
        TableColumn<ClashEntry>(
          label: "USERNAME",
          flex: _usernameFlex,
          value: (entry) => entry.user?.username ?? "-",
          bold: true,
        ),
        TableColumn<ClashEntry>(
          label: "LIST",
          flex: _listFlex,
          value: (entry) => entry.movieList?.name ?? "-",
        ),
        TableColumn<ClashEntry>(
          label: "MOVIES",
          flex: _moviesFlex,
          value: (entry) => entry.movieList?.movieCount?.toString() ?? "-",
          muted: true,
        ),
        TableColumn<ClashEntry>.custom(
          label: "VOTES",
          flex: _votesFlex,
          builder: _buildVotes,
        ),
        TableColumn<ClashEntry>(
          label: "SUBMITTED",
          flex: _submittedFlex,
          value: (entry) => formatDate(entry.createdAt),
          muted: true,
        ),
      ];

  /// The API hands the entries back already ordered best-first, so a row's
  /// place is its position in the page rather than anything it carries.
  int _rankOf(ClashEntry entry) {
    final List<ClashEntry> entries = result?.items ?? List.empty();

    return (_page - 1) * _pageSize + entries.indexOf(entry) + 1;
  }

  Widget _buildRankBadge(BuildContext context, ClashEntry entry) {
    final int rank = _rankOf(entry);
    final Color color = _rankColor(rank);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: _rankBadgeSize,
          height: _rankBadgeSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            rank.toString(),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // A completed clash flags its winner, which need not be the row sitting
        // at rank one on the page the admin happens to be looking at.
        if (entry.isWinner == true) ...[
          const SizedBox(width: 6),
          Tooltip(
            message: "Winner",
            child: Icon(Icons.emoji_events, color: _goldColor, size: 18),
          ),
        ],
      ],
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return _goldColor;
      case 2:
        return _silverColor;
      case 3:
        return _bronzeColor;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  Widget _buildVotes(BuildContext context, ClashEntry entry) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.favorite, size: 15, color: colors.primary),
        const SizedBox(width: 6),
        Text(
          (entry.votes ?? 0).toString(),
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
