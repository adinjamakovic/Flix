import 'package:flix_mobile/enums/activity_type.dart';
import 'package:flix_mobile/models/activity.dart';
import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/activity_provider.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: ActivityFeedSource.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FLIX'),
          bottom: const TabBar(
            tabs: <Widget>[Tab(text: 'Followers'), Tab(text: 'You')],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            _ActivityFeed(source: ActivityFeedSource.followers),
            _ActivityFeed(source: ActivityFeedSource.self),
          ],
        ),
      ),
    );
  }
}

enum ActivityFeedSource { followers, self }

class _ActivityFeed extends StatefulWidget {
  const _ActivityFeed({required this.source});

  final ActivityFeedSource source;

  @override
  State<_ActivityFeed> createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<_ActivityFeed> {
  static const int _pageSize = 20;

  // How close to the bottom the list gets before the next page goes out.
  static const double _loadMoreExtent = 300;

  static const double _posterWidth = 44;
  static const double _posterHeight = 66;
  static const double _avatarRadius = 18;
  static const double _badgeRadius = 9;

  late ActivityProvider _activityProvider;
  late AuthProvider _authProvider;

  final ScrollController _scrollController = ScrollController();

  List<Activity> _activities = List.empty();

  int _page = 1;
  bool _hasMore = true;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  bool get _isSelf => widget.source == ActivityFeedSource.self;

  bool get _isSignedIn => _authProvider.userId != null;

  @override
  void initState() {
    super.initState();

    _activityProvider = context.read<ActivityProvider>();
    _authProvider = context.read<AuthProvider>();

    _scrollController.addListener(_onScroll);

    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<SearchResult<Activity>> _fetch(int page) => _isSelf
      ? _activityProvider.getFromSelf(page: page, pageSize: _pageSize)
      : _activityProvider.getFromFollowers(page: page, pageSize: _pageSize);

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (!_isSignedIn) {
      setState(() {
        _activities = List.empty();
        _hasMore = false;
        _isLoading = false;
      });
      return;
    }

    try {
      final List<Activity> activities = itemsOf(await _fetch(1));

      if (!mounted) return;

      setState(() {
        _activities = activities;
        _page = 1;
        _hasMore = activities.length >= _pageSize;
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

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final ScrollPosition position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - _loadMoreExtent) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final List<Activity> activities = itemsOf(await _fetch(_page + 1));

      if (!mounted) return;

      setState(() {
        _page += 1;
        _activities = [..._activities, ...activities];
        _hasMore = activities.length >= _pageSize;
        _isLoadingMore = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
        _hasMore = false;
      });

      showSnack(context, errorText(e));
    }
  }

  String get _emptyMessage {
    if (!_isSignedIn) {
      return _isSelf
          ? "Sign in to see your activity."
          : "Sign in to see what the people you follow are up to.";
    }

    return _isSelf
        ? "Nothing here yet.\nWatch, rate or review a movie and it'll show up."
        : "Nothing from the people you follow yet.\n"
              "Follow a few more and this fills up.";
  }

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

    if (_activities.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            buildMessage(context, _emptyMessage),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
        itemCount: _activities.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => index < _activities.length
            ? _buildActivityCard(_activities[index])
            : const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Movie? movie = activity.relatedMovie;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeading(activity),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSentence(activity),
                const SizedBox(height: 6),
                Text(
                  _timeAgo(activity.createdAt),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                ?_buildDetail(activity),
              ],
            ),
          ),
          if (movie != null) ...[
            const SizedBox(width: 12),
            buildPoster(
              context,
              movie.poster,
              width: _posterWidth,
              height: _posterHeight,
              iconSize: 18,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeading(Activity activity) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (_isSelf) {
      return CircleAvatar(
        radius: _avatarRadius,
        backgroundColor: colors.surfaceContainerHigh,
        child: Icon(
          _icon(activity.type),
          size: _avatarRadius,
          color: colors.primary,
        ),
      );
    }

    return SizedBox(
      width: _avatarRadius * 2,
      height: _avatarRadius * 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          buildAvatar(
            context,
            activity.user?.profileImage,
            activity.user?.username,
            radius: _avatarRadius,
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: CircleAvatar(
              radius: _badgeRadius,
              backgroundColor: colors.primary,
              child: Icon(
                _icon(activity.type),
                size: _badgeRadius + 2,
                color: colors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // "emmaclarke reviewed Dune" — the actor and whatever the activity is about
  // stand out, the verb between them does not.
  Widget _buildSentence(Activity activity) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final TextStyle plain = TextStyle(
      color: colors.onSurfaceVariant,
      fontSize: 14,
      height: 1.3,
    );
    final TextStyle strong = TextStyle(
      color: colors.onSurface,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.3,
    );

    final ({String verb, String? subject, String? suffix}) phrase = _phrase(
      activity,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: _isSelf ? "You" : (activity.user?.username ?? "-"),
              style: strong),
          TextSpan(text: " ${phrase.verb}", style: plain),
          if (phrase.subject != null)
            TextSpan(text: " ${phrase.subject}", style: strong),
          if (phrase.suffix != null)
            TextSpan(text: " ${phrase.suffix}", style: plain),
        ],
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  ({String verb, String? subject, String? suffix}) _phrase(Activity activity) {
    final String? movieTitle = activity.relatedMovie?.title;
    final String possessive = _isSelf ? "your" : "their";

    switch (activity.type) {
      case ActivityType.joinedPlatform:
        return (verb: "joined FLIX", subject: null, suffix: null);
      case ActivityType.watchedMovie:
        return (verb: "watched", subject: movieTitle, suffix: null);
      case ActivityType.reviewedMovie:
        return (verb: "reviewed", subject: movieTitle, suffix: null);
      case ActivityType.likedMovie:
        return (verb: "liked", subject: movieTitle, suffix: null);
      case ActivityType.addedToWatchlist:
        return (
          verb: "added",
          subject: movieTitle,
          suffix: "to $possessive watchlist",
        );
      case ActivityType.createdList:
        return (
          verb: "created the list",
          subject: activity.movieList?.name,
          suffix: null,
        );
      case ActivityType.followedUser:
        return (
          verb: "followed",
          subject: activity.targetUser?.username,
          suffix: null,
        );
      case ActivityType.requestedMovie:
        return (verb: "requested", subject: movieTitle, suffix: null);
      case ActivityType.joinedClash:
        return (
          verb: "joined the clash",
          subject: activity.clash?.name,
          suffix: null,
        );
      case ActivityType.wonClash:
        return (verb: "won", subject: activity.clash?.name, suffix: null);
      case ActivityType.votedOnClash:
        return (
          verb: "voted in",
          subject: activity.clash?.name,
          suffix: null,
        );
      case null:
        return (verb: "was here", subject: null, suffix: null);
    }
  }

  IconData _icon(ActivityType? type) {
    switch (type) {
      case ActivityType.joinedPlatform:
        return Icons.celebration_outlined;
      case ActivityType.watchedMovie:
        return Icons.visibility_outlined;
      case ActivityType.reviewedMovie:
        return Icons.rate_review_outlined;
      case ActivityType.likedMovie:
        return Icons.favorite;
      case ActivityType.addedToWatchlist:
        return Icons.bookmark_add_outlined;
      case ActivityType.createdList:
        return Icons.playlist_add;
      case ActivityType.followedUser:
        return Icons.person_add_alt_1_outlined;
      case ActivityType.requestedMovie:
        return Icons.add_circle_outline;
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

  // A review is the one activity that carries something worth reading, so it is
  // the only one with anything under the sentence.
  Widget? _buildDetail(Activity activity) {
    if (activity.type != ActivityType.reviewedMovie) return null;

    final ColorScheme colors = Theme.of(context).colorScheme;

    final String content = activity.review?.content?.trim() ?? "";
    final bool isHidden = activity.review?.containsSpoilers == true;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildRating(
            context,
            activity.review?.rating,
            isLiked: activity.review?.isLiked == true,
            isRewatch: activity.review?.isRewatch == true,
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              isHidden ? "Contains spoilers." : content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isHidden ? colors.onSurfaceVariant : colors.onSurface,
                fontSize: 13,
                height: 1.3,
                fontStyle: isHidden ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // A feed reads by how recent something is rather than by the date it landed
  // on, so anything inside a week is relative and everything older falls back
  // to the app-wide dd/mm/yyyy.
  String _timeAgo(DateTime? date) {
    if (date == null) return "-";

    final Duration age = DateTime.now().difference(date.toLocal());

    if (age.inMinutes < 1) return "Just now";
    if (age.inHours < 1) return "${age.inMinutes}m ago";
    if (age.inDays < 1) return "${age.inHours}h ago";
    if (age.inDays < 7) return "${age.inDays}d ago";

    return formatDate(date);
  }
}
