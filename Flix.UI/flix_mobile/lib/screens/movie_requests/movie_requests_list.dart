import 'package:flix_mobile/enums/movie_request_status.dart';
import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/movie_request.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/movie_request_provider.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieRequestsList extends StatefulWidget {
  const MovieRequestsList({super.key});

  @override
  State<MovieRequestsList> createState() => _MovieRequestsListState();
}

class _MovieRequestsListState extends State<MovieRequestsList> {
  static const int _pageSize = 50;

  static const Color _approvedColor = Color(0xFF22C55E);
  static const Color _pendingColor = Color(0xFFF59E0B);

  static const double _posterWidth = 56;
  static const double _posterHeight = 84;

  static const double _cardAccentWidth = 3;

  static const List<MovieRequestStatus> _sections = [
    MovieRequestStatus.pending,
    MovieRequestStatus.approved,
    MovieRequestStatus.rejected,
    MovieRequestStatus.cancelled,
  ];

  late MovieRequestProvider _movieRequestProvider;

  Map<MovieRequestStatus, List<MovieRequest>> _requests = const {};

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _movieRequestProvider = context.read<MovieRequestProvider>();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<SearchResult<MovieRequest>> results = await Future.wait(
        _sections.map(
          (status) => _movieRequestProvider.getRequests(
            status: status,
            pageSize: _pageSize,
          ),
        ),
      );

      if (!mounted) return;

      setState(() {
        _requests = {
          for (int i = 0; i < _sections.length; i++)
            _sections[i]: itemsOf(results[i]),
        };
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

  Future<void> _cancel(MovieRequest request) async {
    final int? id = request.id;

    if (id == null || !await _confirmCancel(request.movie?.title)) return;

    try {
      await _movieRequestProvider.cancelRequest(id);

      if (!mounted) return;

      showSnack(context, "Request cancelled.");

      await _load();
    } on Exception catch (e) {
      if (!mounted) return;

      showSnack(context, errorText(e));
    }
  }

  Future<bool> _confirmCancel(String? title) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel request"),
        content: Text(
          "${title ?? "This movie"} will not be reviewed, and you will have to "
          "send it in again if you change your mind.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Keep it"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Cancel request"),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  bool get _isEmpty =>
      _requests.values.every((requests) => requests.isEmpty);

  Color _statusColor(MovieRequestStatus status) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    switch (status) {
      case MovieRequestStatus.approved:
        return _approvedColor;
      case MovieRequestStatus.rejected:
        return colors.error;
      case MovieRequestStatus.pending:
        return _pendingColor;
      case MovieRequestStatus.cancelled:
        return colors.onSurfaceVariant;
    }
  }

  String _emptyLabel(MovieRequestStatus status) {
    switch (status) {
      case MovieRequestStatus.approved:
        return "Nothing approved yet.";
      case MovieRequestStatus.rejected:
        return "Nothing rejected — so far, so good.";
      case MovieRequestStatus.pending:
        return "Nothing waiting on a review.";
      case MovieRequestStatus.cancelled:
        return "You haven't cancelled anything.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FLIX")),
      body: SafeArea(top: false, child: _buildBody()),
    );
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

    if (_isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          // Nothing here fills the screen, and a list that cannot be dragged
          // cannot be pulled to refresh either.
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            buildMessage(
              context,
              "You haven't requested a movie yet.\n"
              "Anything you send shows up here.",
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          for (final MovieRequestStatus status in _sections)
            buildSection(
              context,
              label: _sectionLabel(status),
              child: _buildRequests(status),
            ),
        ],
      ),
    );
  }

  String _sectionLabel(MovieRequestStatus status) {
    final int count = _requests[status]?.length ?? 0;

    return count == 0
        ? getMovieRequestStatus(status)
        : "${getMovieRequestStatus(status)} ($count)";
  }

  Widget _buildRequests(MovieRequestStatus status) {
    final List<MovieRequest> requests = _requests[status] ?? List.empty();

    if (requests.isEmpty) return buildEmpty(context, _emptyLabel(status));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final MovieRequest request in requests)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRequestCard(request, status),
          ),
      ],
    );
  }

  Widget _buildRequestCard(MovieRequest request, MovieRequestStatus status) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color accent = _statusColor(status);

    return Container(
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.only(left: _cardAccentWidth),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(4),
            right: Radius.circular(14),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequestRow(request, status),
            ?_buildAdminComment(request, status),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestRow(MovieRequest request, MovieRequestStatus status) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Movie? movie = request.movie;
    final int? year = movie?.releaseDate?.year;
    final String? genres = movie?.genreNames;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            buildPoster(
              context,
              movie?.poster,
              width: _posterWidth,
              height: _posterHeight,
              iconSize: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie?.title ?? "-",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      year?.toString(),
                      genres,
                    ].whereType<String>().join("  ·  "),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Requested: ${formatDate(request.createdAt)}",
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  if (status == MovieRequestStatus.pending)
                    TextButton.icon(
                      onPressed: () => _cancel(request),
                      icon: const Icon(Icons.close, size: 15),
                      label: const Text("Cancel request"),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.error,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: const Size(0, 34),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _buildStatusBadge(status),
      ],
    );
  }

  Widget? _buildAdminComment(
    MovieRequest request,
    MovieRequestStatus status,
  ) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final String comment = request.adminComment?.trim() ?? "";

    if (comment.isEmpty) return null;

    final String label = status == MovieRequestStatus.rejected
        ? "Why it was rejected"
        : "Admin note";

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              comment,
              style: TextStyle(color: colors.onSurface, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MovieRequestStatus status) {
    final Color accent = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        getMovieRequestStatus(status),
        style: TextStyle(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
