import 'package:flix_mobile/enums/clash_status.dart';
import 'package:flix_mobile/models/clash.dart';
import 'package:flix_mobile/models/clash_entry.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/clash_entry_provider.dart';
import 'package:flix_mobile/providers/clash_provider.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClashList extends StatefulWidget {
  const ClashList({super.key});

  @override
  _ClashListState createState() => _ClashListState();
}

class _ClashListState extends State<ClashList> {
  // A clash runs for weeks, so there are never many of them - one page per
  // status covers the whole screen and there is nothing to page through.
  static const int _pageSize = 50;

  static const Color _wonColor = Color(0xFF22C55E);

  static const double _cardAccentHeight = 3;
  static const double _actionWidth = 140;

  // The API has no voting endpoint yet, so there is nothing to read a
  // remaining-vote count off - this is the per-clash allowance, not a live
  // count, until one exists.
  static const int _votesPerClash = 5;

  late ClashProvider _clashProvider;
  late ClashEntryProvider _clashEntryProvider;
  late AuthProvider _authProvider;

  Clash? _currentClash;
  Clash? _upcomingClash;
  List<Clash> _previousClashes = List.empty();

  /// The user's own entries, keyed by the clash they were made in. Drives both
  /// which completed clashes count as "previous" and which of them was won.
  Map<int, ClashEntry> _entriesByClashId = const {};

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _clashProvider = context.read<ClashProvider>();
    _clashEntryProvider = context.read<ClashEntryProvider>();
    _authProvider = context.read<AuthProvider>();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // One request per status, plus the user's entries, all in flight together.
      final Future<List<SearchResult<Clash>>> clashRequests = Future.wait([
        _clashProvider.get(filter: _clashFilter(ClashStatus.active)),
        _clashProvider.get(filter: _clashFilter(ClashStatus.upcoming)),
        _clashProvider.get(filter: _clashFilter(ClashStatus.completed)),
      ]);
      final Future<Map<int, ClashEntry>> entriesRequest = _loadEntries();

      final List<SearchResult<Clash>> clashes = await clashRequests;
      final Map<int, ClashEntry> entries = await entriesRequest;

      if (!mounted) return;

      setState(() {
        _currentClash = _soonest(itemsOf(clashes[0]), (clash) => clash.endDate);
        _upcomingClash = _soonest(
          itemsOf(clashes[1]),
          (clash) => clash.startDate,
        );
        _previousClashes = _participatedIn(itemsOf(clashes[2]), entries);
        _entriesByClashId = entries;
        _isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = errorText(e);
      });
    }
  }

  Map<String, dynamic> _clashFilter(ClashStatus status) => {
    "page": 1,
    "pageSize": _pageSize,
    "status": status.index,
  };

  Future<Map<int, ClashEntry>> _loadEntries() async {
    final String username = _authProvider.username?.trim() ?? "";
    if (username.isEmpty) return const {};

    final SearchResult<ClashEntry> result = await _clashEntryProvider.get(
      filter: {"page": 1, "pageSize": _pageSize, "username": username},
    );

    final Map<int, ClashEntry> byClashId = <int, ClashEntry>{};

    for (final ClashEntry entry in result.items ?? List<ClashEntry>.empty()) {
      final int? clashId = entry.clashId;
      if (clashId != null) byClashId[clashId] = entry;
    }

    return byClashId;
  }

  /// Nothing orders clashes on the API side, so the one that matters is picked
  /// here: the active clash closing first, the upcoming one starting soonest.
  Clash? _soonest(List<Clash> clashes, DateTime? Function(Clash) dateOf) {
    if (clashes.isEmpty) return null;

    final List<Clash> sorted = clashes.toList()
      ..sort((a, b) => _compareDates(dateOf(a), dateOf(b)));

    return sorted.first;
  }

  /// Completed clashes the user entered, the most recently finished first.
  List<Clash> _participatedIn(
    List<Clash> completed,
    Map<int, ClashEntry> entries,
  ) {
    return completed.where((clash) => entries.containsKey(clash.id)).toList()
      ..sort((a, b) => _compareDates(b.endDate, a.endDate));
  }

  // A clash with no date sorts last.
  int _compareDates(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    return a.compareTo(b);
  }

  bool _hasWon(Clash clash) => _entriesByClashId[clash.id]?.isWinner == true;

  // Neither voting nor entering a clash has an endpoint on the API yet, so the
  // buttons the design calls for are here but say so when tapped.
  void _onVote() => showSnack(context, "Voting isn't available yet.");

  void _onParticipate() =>
      showSnack(context, "Entering a clash isn't available yet.");

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return buildMessage(
        context,
        _error!,
        action: TextButton(onPressed: _load, child: const Text("Try again")),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          buildSection(
            context,
            label: "Current Clash",
            child: _buildCurrentClash(),
          ),
          buildSection(
            context,
            label: "Upcoming Clash",
            child: _buildUpcomingClash(),
          ),
          buildSection(
            context,
            label: "Previous clashes",
            child: _buildPreviousClashes(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentClash() {
    final Clash? clash = _currentClash;

    if (clash == null) {
      return buildEmpty(context, "No clash is running right now.");
    }

    return _buildClashCard(
      clash: clash,
      accent: Theme.of(context).colorScheme.primary,
      footer: "Closes: ${formatDate(clash.endDate)}",
      actions: _buildActions(),
    );
  }

  Widget _buildUpcomingClash() {
    final Clash? clash = _upcomingClash;

    if (clash == null) {
      return buildEmpty(context, "Nothing lined up yet.");
    }

    return _buildClashCard(
      clash: clash,
      accent: Theme.of(context).colorScheme.primary,
      footer: "Starts: ${formatDate(clash.startDate)}",
    );
  }

  Widget _buildPreviousClashes() {
    if (_previousClashes.isEmpty) {
      return buildEmpty(
        context,
        _authProvider.username == null
            ? "Sign in to see the clashes you took part in."
            : "You haven't taken part in a clash yet.",
      );
    }

    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final Clash clash in _previousClashes)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildClashCard(
              clash: clash,
              // The one thing a previous clash has to say is whether it was won.
              accent: _hasWon(clash) ? _wonColor : colors.primary,
            ),
          ),
      ],
    );
  }

  // A clash card: a coloured hairline along the top edge, the award mark, and
  // the clash itself. `actions` sits to the right of the text when given.
  Widget _buildClashCard({
    required Clash clash,
    required Color accent,
    String? footer,
    Widget? actions,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.only(top: _cardAccentHeight),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(12),
            bottom: Radius.circular(14),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    color: accent,
                    size: 30,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    clash.name ?? "-",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 20,
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
                      fontSize: 15,
                      height: 1.25,
                    ),
                  ),
                  if (footer != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      footer,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actions != null) ...[const SizedBox(width: 12), actions],
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        _buildActionButton(
          label: "Vote",
          caption: "Votes left: $_votesPerClash",
          onPressed: _onVote,
        ),
        const SizedBox(height: 10),
        _buildActionButton(label: "Participate", onPressed: _onParticipate),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    String? caption,
    required VoidCallback onPressed,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: _actionWidth,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: colors.onSurface,
          backgroundColor: colors.surfaceContainerHigh,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(0, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            if (caption != null)
              Text(
                caption,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }
}
