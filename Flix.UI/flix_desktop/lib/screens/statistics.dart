import 'package:flix_desktop/enums/activity_type.dart';
import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flix_desktop/models/activity.dart';
import 'package:flix_desktop/models/admin_statistics.dart';
import 'package:flix_desktop/models/movie.dart';
import 'package:flix_desktop/models/user.dart';
import 'package:flix_desktop/providers/statistics_provider.dart';
import 'package:flix_desktop/screens/report_preview.dart';
import 'package:flix_desktop/utils/reports.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/genre_pie_chart.dart';
import 'package:flix_desktop/widgets/infinite_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  static const double _panelHeight = 380;

  static const Color _usersAccent = Color(0xFF3B82F6);
  static const Color _reviewsAccent = Color(0xFFF59E0B);
  static const Color _clashesAccent = Color(0xFF8B5CF6);
  static const Color _positiveTrend = Color(0xFF16A34A);

  late StatisticsProvider _statisticsProvider;

  AdminStatistics? _statistics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _statisticsProvider = context.read<StatisticsProvider>();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final AdminStatistics data = await _statisticsProvider.getStatistics();

      if (!mounted) return;

      setState(() {
        _statistics = data;
        _isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "",
      destination: DrawerDestination.statistics,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Statistics",
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Overview of site users and movies",
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 46,
          child: ElevatedButton.icon(
            onPressed: _statistics == null ? null : _showReportDialog,
            icon: const Icon(Icons.description_outlined, size: 18),
            label: const Text("Generate Report"),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final String? error = _error;
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error, style: TextStyle(color: colors.onSurfaceVariant)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text("Try again")),
          ],
        ),
      );
    }

    final AdminStatistics statistics = _statistics!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(statistics),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPanel(
                  title: "Most Active Users",
                  child: _buildUsersTable(statistics),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildPanel(
                  title: "Movies by Genre",
                  child: GenrePieChart(
                    genres: statistics.genrePercentages ?? List.empty(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPanel(
                  title: "Most Popular Movies",
                  child: _buildMoviesTable(statistics),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildPanel(
                  title: "Recent Activity",
                  child: _buildRecentActivity(statistics),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(AdminStatistics statistics) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: "Active Users",
            value: statistics.activeUsers,
            trend: statistics.userPercentage,
            icon: Icons.groups_outlined,
            accent: _usersAccent,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            label: "Total Movies",
            value: statistics.totalMovies,
            trend: statistics.moviePercentage,
            icon: Icons.movie_filter_outlined,
            accent: colors.primary,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            label: "Total Reviews",
            value: statistics.totalReviews,
            trend: statistics.reviewPercentage,
            icon: Icons.star_border,
            accent: _reviewsAccent,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            label: "Clashes Organised",
            value: statistics.totalClashes,
            trend: statistics.clashPercentage,
            icon: Icons.emoji_events_outlined,
            accent: _clashesAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required int? value,
    required double? trend,
    required IconData icon,
    required Color accent,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatCount(value),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                _buildTrend(trend),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
        ],
      ),
    );
  }

  // The API sends the last seven days measured against the seven before them,
  // so a flat week and a week with nothing in it both come back as 0.
  Widget _buildTrend(double? trend) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double percentage = trend ?? 0;

    final String label = percentage == 0
        ? "No change this week"
        : "${percentage > 0 ? "+" : ""}${formatPercentage(percentage)}% this week";

    return Text(
      label,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: percentage == 0
            ? colors.onSurfaceVariant
            : percentage > 0
                ? _positiveTrend
                : colors.error,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPanel({required String title, required Widget child}) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      height: _panelHeight,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildUsersTable(AdminStatistics statistics) {
    return _buildTable<User>(
      columns: [
        _StatColumn<User>(
          label: "Username",
          flex: 40,
          value: (user) => user.username ?? "-",
          bold: true,
        ),
        _StatColumn<User>(
          label: "Movies Watched",
          flex: 30,
          value: (user) => (user.moviesWatched ?? 0).toString(),
        ),
        _StatColumn<User>(
          label: "Reviews",
          flex: 30,
          value: (user) => (user.reviewsWritten ?? 0).toString(),
        ),
      ],
      items: statistics.mostActiveUsers ?? List.empty(),
      emptyMessage: "No users yet",
    );
  }

  Widget _buildMoviesTable(AdminStatistics statistics) {
    return _buildTable<Movie>(
      columns: [
        _StatColumn<Movie>(
          label: "Movie Title",
          flex: 44,
          value: (movie) => movie.title ?? "-",
          bold: true,
        ),
        _StatColumn<Movie>(
          label: "Views",
          flex: 28,
          value: (movie) => (movie.views ?? 0).toString(),
        ),
        _StatColumn<Movie>(
          label: "Rating",
          flex: 28,
          value: (movie) =>
              movie.rating == null ? "-" : formatRating(movie.rating!),
        ),
      ],
      items: statistics.mostPopularMovies ?? List.empty(),
      emptyMessage: "No movies yet",
    );
  }

  Widget _buildTable<T>({
    required List<_StatColumn<T>> columns,
    required List<T> items,
    required String emptyMessage,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            height: 42,
            color: colors.surfaceContainer,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (final _StatColumn<T> column in columns)
                  Expanded(
                    flex: column.flex,
                    child: Text(
                      column.label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: InfiniteList<T>(
              items: items,
              emptyMessage: emptyMessage,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: colors.outlineVariant,
              ),
              itemBuilder: (context, item, index) => Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    for (final _StatColumn<T> column in columns)
                      Expanded(
                        flex: column.flex,
                        child: Text(
                          column.value(item),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 13.5,
                            fontWeight:
                                column.bold ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(AdminStatistics statistics) {
    return InfiniteList<Activity>(
      items: statistics.recentActivity ?? List.empty(),
      emptyMessage: "Nothing has happened yet",
      initialCount: 4,
      step: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, activity, index) => _buildActivityRow(activity),
    );
  }

  Widget _buildActivityRow(Activity activity) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color accent = _activityAccent(activity.type);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_activityIcon(activity.type), color: accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _activityTitle(activity.type),
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _activitySentence(activity),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _timeAgo(activity.createdAt),
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _activityTitle(ActivityType? type) {
    switch (type) {
      case ActivityType.joinedPlatform:
        return "New user joined";
      case ActivityType.watchedMovie:
        return "Movie watched";
      case ActivityType.reviewedMovie:
        return "New review written";
      case ActivityType.likedMovie:
        return "Movie liked";
      case ActivityType.addedToWatchlist:
        return "Movie added to a watchlist";
      case ActivityType.createdList:
        return "New list created";
      case ActivityType.followedUser:
        return "New follow";
      case ActivityType.requestedMovie:
        return "New movie request submitted";
      case ActivityType.joinedClash:
        return "Clash participation";
      case ActivityType.wonClash:
        return "Clash won";
      case ActivityType.votedOnClash:
        return "Clash vote cast";
      case null:
        return "Activity";
    }
  }

  String _activitySentence(Activity activity) {
    final String user = activity.user?.username ?? "Someone";
    final String movie = activity.relatedMovie?.title ?? "a movie";
    final String clash = activity.clash?.name ?? "a clash";

    switch (activity.type) {
      case ActivityType.joinedPlatform:
        return "$user joined the platform";
      case ActivityType.watchedMovie:
        return "$user watched \"$movie\"";
      case ActivityType.reviewedMovie:
        return "$user reviewed \"$movie\"";
      case ActivityType.likedMovie:
        return "$user liked \"$movie\"";
      case ActivityType.addedToWatchlist:
        return "$user added \"$movie\" to their watchlist";
      case ActivityType.createdList:
        return "$user created \"${activity.movieList?.name ?? "a list"}\"";
      case ActivityType.followedUser:
        return "$user followed ${activity.targetUser?.username ?? "someone"}";
      case ActivityType.requestedMovie:
        return "$user requested \"$movie\"";
      case ActivityType.joinedClash:
        return "$user joined \"$clash\"";
      case ActivityType.wonClash:
        return "$user won \"$clash\"";
      case ActivityType.votedOnClash:
        return "$user voted in \"$clash\"";
      case null:
        return "$user did something";
    }
  }

  IconData _activityIcon(ActivityType? type) {
    switch (type) {
      case ActivityType.joinedPlatform:
        return Icons.person_add_alt_1_outlined;
      case ActivityType.watchedMovie:
        return Icons.visibility_outlined;
      case ActivityType.reviewedMovie:
        return Icons.rate_review_outlined;
      case ActivityType.likedMovie:
        return Icons.favorite_border;
      case ActivityType.addedToWatchlist:
        return Icons.bookmark_add_outlined;
      case ActivityType.createdList:
        return Icons.playlist_add;
      case ActivityType.followedUser:
        return Icons.group_add_outlined;
      case ActivityType.requestedMovie:
        return Icons.movie_filter_outlined;
      case ActivityType.joinedClash:
        return Icons.sports_kabaddi_outlined;
      case ActivityType.wonClash:
        return Icons.emoji_events_outlined;
      case ActivityType.votedOnClash:
        return Icons.how_to_vote_outlined;
      case null:
        return Icons.circle_outlined;
    }
  }

  Color _activityAccent(ActivityType? type) {
    switch (type) {
      case ActivityType.joinedPlatform:
      case ActivityType.followedUser:
        return _usersAccent;
      case ActivityType.reviewedMovie:
      case ActivityType.likedMovie:
        return _reviewsAccent;
      case ActivityType.joinedClash:
      case ActivityType.wonClash:
      case ActivityType.votedOnClash:
        return _clashesAccent;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  // A feed reads by how recent something is, so anything inside a week is
  // relative and everything older falls back to the app-wide dd/mm/yyyy.
  String _timeAgo(DateTime? date) {
    if (date == null) return "-";

    final Duration age = DateTime.now().difference(date.toLocal());

    if (age.inMinutes < 1) return "Just now";
    if (age.inHours < 1) return "${age.inMinutes} minutes ago";
    if (age.inDays < 1) return "${age.inHours} hours ago";
    if (age.inDays < 7) return "${age.inDays} days ago";

    return formatDate(date);
  }

  /// A report is either about the people or about the catalog, so the button
  /// asks which before building anything.
  Future<void> _showReportDialog() async {
    final _ReportKind? kind = await showDialog<_ReportKind>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Generate a report"),
        content: const Text(
          "A user report covers the most active members of the platform. A "
          "movie report covers the most watched and the best rated movies.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _ReportKind.users),
            child: const Text("Users report"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _ReportKind.movies),
            child: const Text("Movies report"),
          ),
        ],
      ),
    );

    final AdminStatistics? statistics = _statistics;
    if (kind == null || statistics == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => switch (kind) {
          _ReportKind.users => ReportPreview(
              title: "Users report",
              fileName: "flix-users-report.pdf",
              buildReport: () => buildUsersReport(statistics),
            ),
          _ReportKind.movies => ReportPreview(
              title: "Movies report",
              fileName: "flix-movies-report.pdf",
              buildReport: () => buildMoviesReport(statistics),
            ),
        },
      ),
    );
  }
}

enum _ReportKind { users, movies }


class _StatColumn<T> {
  const _StatColumn({
    required this.label,
    required this.flex,
    required this.value,
    this.bold = false,
  });

  final String label;
  final int flex;
  final String Function(T item) value;
  final bool bold;
}
