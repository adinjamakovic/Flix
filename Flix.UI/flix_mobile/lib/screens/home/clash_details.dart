import 'package:flix_mobile/models/clash.dart';
import 'package:flix_mobile/models/clash_entry.dart';
import 'package:flix_mobile/models/clash_vote_state.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/clash_entry_provider.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Fed the clash carried by the list it was opened from, so the header needs no
// request of its own - only the entries and the user's allowance are fetched.
class ClashDetails extends StatefulWidget {
  const ClashDetails({super.key, required this.clash});

  final Clash clash;

  @override
  State<ClashDetails> createState() => _ClashDetailsState();
}

class _ClashDetailsState extends State<ClashDetails> {
  // The entries are a leaderboard, and a clash has a handful of them - one page
  // is the whole board.
  static const int _pageSize = 50;

  static const Color _wonColor = Color(0xFF22C55E);

  static const double _bannerAspectRatio = 16 / 9;
  static const double _bannerRadius = 12;
  static const double _avatarRadius = 18;

  late ClashEntryProvider _clashEntryProvider;
  late AuthProvider _authProvider;

  List<ClashEntry> _entries = List.empty();

  ClashVoteState? _voteState;

  /// The entries this user's votes are sitting on. A tap on one of them takes
  /// the vote back instead of spending another.
  Set<int> _votedEntryIds = const {};

  /// The entry whose vote is in flight, which locks every button until the
  /// counts come back.
  int? _pendingEntryId;

  bool _isLoading = true;
  String? _error;

  Clash get _clash => widget.clash;

  @override
  void initState() {
    super.initState();

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
      await _fetch();

      if (!mounted) return;

      setState(() => _isLoading = false);
      // Everything, not just Exception: a payload the models cannot parse throws
      // a TypeError, and letting that escape leaves _isLoading true forever -
      // the screen spins instead of saying what went wrong.
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = errorText(e);
      });
    }
  }

  Future<void> _fetch() async {
    final List<Object?> results = await Future.wait<Object?>([
      _clashEntryProvider.get(filter: _entryFilter()),
      _loadVoteState(),
    ]);

    if (!mounted) return;

    final ClashVoteState? voteState = results[1] as ClashVoteState?;

    setState(() {
      _entries = itemsOf(results[0] as SearchResult<ClashEntry>);
      _voteState = voteState;
      _votedEntryIds = (voteState?.votedEntryIds ?? const <int>[]).toSet();
    });
  }

  Map<String, dynamic> _entryFilter() => {
    "page": 1,
    "pageSize": _pageSize,
    "clashId": _clash.id,
    "includeUser": true,
    "includeMovieList": true,
  };

  Future<ClashVoteState?> _loadVoteState() async {
    final int? clashId = _clash.id;
    if (clashId == null || _authProvider.userId == null) return null;

    return _clashEntryProvider.getVoteState(clashId);
  }

  Future<void> _toggleVote(ClashEntry entry) async {
    final int? entryId = entry.id;
    if (entryId == null || _pendingEntryId != null) return;

    final bool hasVoted = _votedEntryIds.contains(entryId);

    setState(() => _pendingEntryId = entryId);

    try {
      if (hasVoted) {
        await _clashEntryProvider.removeVote(entryId);
      } else {
        await _clashEntryProvider.vote(entryId);
      }

      // The vote changes both the entry's tally and its place on the board, so
      // the whole thing is read back rather than patched here.
      await _fetch();
    } catch (e) {
      if (!mounted) return;

      showSnack(context, errorText(e));
    } finally {
      if (mounted) setState(() => _pendingEntryId = null);
    }
  }

  bool get _isVotingOpen {
    final DateTime? start = _clash.startDate?.toLocal();
    final DateTime? end = _clash.endDate?.toLocal();

    if (start == null || end == null) return false;

    final DateTime now = DateTime.now();

    return !now.isBefore(start) && !now.isAfter(end);
  }

  bool _isOwnEntry(ClashEntry entry) {
    final int? userId = _authProvider.userId;

    return userId != null && entry.user?.id == userId;
  }

  int get _votesRemaining => _voteState?.votesRemaining ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: SafeArea(child: _buildBody()));
  }

  Widget _buildBody() {
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
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: _buildHeader(),
          ),
          buildSection(context, label: "Entries", child: _buildEntries()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBanner(colors),
        const SizedBox(height: 16),
        Text(
          _clash.name ?? "-",
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _clash.description ?? "-",
          style: TextStyle(color: colors.onSurface, fontSize: 15, height: 1.3),
        ),
        const SizedBox(height: 10),
        Text(
          "Closes: ${formatDate(_clash.endDate)}",
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(height: 14),
        _buildVoteAllowance(colors),
      ],
    );
  }

  Widget _buildBanner(ColorScheme colors) {
    final Uri? uri = httpUri(_clash.bannerImage);

    return ClipRRect(
      borderRadius: BorderRadius.circular(_bannerRadius),
      child: AspectRatio(
        aspectRatio: _bannerAspectRatio,
        child: uri == null
            ? _buildBannerPlaceholder(colors)
            : Image.network(
                uri.toString(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildBannerPlaceholder(colors),
              ),
      ),
    );
  }

  Widget _buildBannerPlaceholder(ColorScheme colors) {
    return ColoredBox(
      color: colors.surfaceContainer,
      child: Icon(
        Icons.workspace_premium_outlined,
        color: colors.onSurfaceVariant,
        size: 40,
      ),
    );
  }

  Widget _buildVoteAllowance(ColorScheme colors) {
    final ClashVoteState? state = _voteState;

    final String label;
    if (state == null) {
      label = "Sign in to vote in this clash";
    } else if (!_isVotingOpen) {
      label = "Voting is closed";
    } else {
      label =
          "Votes left: $_votesRemaining of ${state.votesAllowed ?? _votesRemaining}";
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.how_to_vote_outlined,
            size: 16,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntries() {
    if (_entries.isEmpty) {
      return buildEmpty(context, "Nobody has entered this clash yet.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final ClashEntry entry in _entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildEntry(entry),
          ),
      ],
    );
  }

  Widget _buildEntry(ClashEntry entry) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final int movieCount = entry.movieList?.movieCount ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              buildAvatar(
                context,
                entry.user?.profileImage,
                entry.user?.username,
                radius: _avatarRadius,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.movieList?.name ?? "-",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (entry.isWinner == true) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.emoji_events,
                            size: 16,
                            color: _wonColor,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${entry.user?.username ?? "-"} · $movieCount ${movieCount == 1 ? "movie" : "movies"}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildVoteCount(colors, entry),
            ],
          ),
          const SizedBox(height: 12),
          _buildVoteAction(colors, entry),
        ],
      ),
    );
  }

  Widget _buildVoteCount(ColorScheme colors, ClashEntry entry) {
    final int votes = entry.votes ?? 0;

    return Column(
      children: [
        Text(
          "$votes",
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          votes == 1 ? "vote" : "votes",
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildVoteAction(ColorScheme colors, ClashEntry entry) {
    final int? entryId = entry.id;
    if (entryId == null) return const SizedBox.shrink();

    if (_isOwnEntry(entry)) return _buildNote(colors, "Your entry");

    if (_voteState == null || !_isVotingOpen) return const SizedBox.shrink();

    final bool hasVoted = _votedEntryIds.contains(entryId);
    final bool isPending = _pendingEntryId == entryId;

    final bool isEnabled =
        _pendingEntryId == null && (hasVoted || _votesRemaining > 0);

    final VoidCallback? onPressed = isEnabled ? () => _toggleVote(entry) : null;

    final Widget label = isPending
        ? const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(hasVoted ? "Remove vote" : "Vote for this entry");

    return hasVoted
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.how_to_vote, size: 18),
            label: label,
          )
        : FilledButton(onPressed: onPressed, child: label);
  }

  Widget _buildNote(ColorScheme colors, String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
    );
  }
}
