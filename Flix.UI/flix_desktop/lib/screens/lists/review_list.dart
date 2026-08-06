import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flix_desktop/models/review.dart';
import 'package:flix_desktop/providers/review_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewList extends StatefulWidget {
  const ReviewList({super.key});

  @override
  _ReviewListState createState() => _ReviewListState();
}

// Unlike the other list screens this one is not paginated with a table - the
// reviews are appended to a single scrolling feed as the admin reaches the
// bottom of it. Reviews are user-written, so there is no create/edit here.
class _ReviewListState extends State<ReviewList> {
  static const int _pageSize = 8;

  static const double _loadMoreThreshold = 240;

  // Ratings go from 0.5 to 5.0 in half-star steps, highest first.
  static const List<double> _ratings = [
    5.0, 4.5, 4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.0, 0.5
  ];

  static const Color _starColor = Color(0xFFF5B301);

  late ReviewProvider _reviewProvider;

  final ScrollController _scrollController = ScrollController();
  final List<Review> _reviews = [];

  int _totalCount = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _movieTitleController = TextEditingController();
  double? _selectedRating;

  @override
  void initState() {
    super.initState();

    _reviewProvider = context.read<ReviewProvider>();
    _scrollController.addListener(_onScroll);

    _search();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _movieTitleController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildFilter(int page) {
    final Map<String, dynamic> filter = {
      "page": page,
      "pageSize": _pageSize,
      "includeTotalCount": true,
      "includeUser": true,
      "includeMovie": true,
    };

    if (_usernameController.text.trim().isNotEmpty) {
      filter["username"] = _usernameController.text.trim();
    }

    if (_movieTitleController.text.trim().isNotEmpty) {
      filter["movieTitle"] = _movieTitleController.text.trim();
    }

    final double? rating = _selectedRating;
    if (rating != null) {
      filter["reviewRating"] = rating;
    }

    return filter;
  }

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    await _fetch(page: 1, reset: true);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final ScrollPosition position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // The page to ask for is derived from what is actually on screen rather than
    // from the last page number requested: deleting a review shifts every later
    // review up a slot on the server, and "the page after the last one" would skip
    // whatever moved across the page boundary.
    await _fetch(page: (_reviews.length ~/ _pageSize) + 1, reset: false);
  }

  Future<void> _fetch({required int page, required bool reset}) async {
    try {
      final data = await _reviewProvider.get(filter: _buildFilter(page));

      if (!mounted) return;

      final List<Review> items = data.items ?? List.empty();

      setState(() {
        if (reset) _reviews.clear();

        // After a deletion the next page can overlap what is already on screen, so
        // reviews the feed is already showing are dropped from the incoming page.
        final Set<int?> loaded = _reviews.map((review) => review.id).toSet();
        _reviews.addAll(items.where((review) => !loaded.contains(review.id)));

        _totalCount = data.totalCount ?? _reviews.length;
        _hasMore = items.length == _pageSize && _reviews.length < _totalCount;
        _isLoading = false;
        _isLoadingMore = false;
      });

      _loadMoreIfFeedDoesNotScroll();
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _hasMore = false;
      });
      alertBox(context, "Error", e.toString());
    }
  }

  Future<void> _deleteReview(Review review) async {
    final int? id = review.id;
    if (id == null) return;

    final String author = review.user?.username ?? "this user";
    final String title = review.movie?.title ?? "this movie";

    final bool confirmed = await confirmBox(
      context,
      "Delete review",
      "Delete $author's review of $title? This cannot be undone.",
    );

    if (!confirmed || !mounted) return;

    try {
      await _reviewProvider.delete(id);
    } on Exception catch (e) {
      if (!mounted) return;

      alertBox(context, "Error", e.toString());
      return;
    }

    if (!mounted) return;

    // The feed is one long scroll rather than a page of a table, so the deleted
    // card is dropped where it stands - reloading from page 1 would throw the
    // admin back to the top of the list they were reading.
    setState(() {
      _reviews.removeWhere((item) => item.id == id);
      if (_totalCount > 0) _totalCount--;
    });

    _loadMoreIfFeedDoesNotScroll();
  }

  void _loadMoreIfFeedDoesNotScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent > 0) return;

      _loadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "",
      destination: DrawerDestination.reviews,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 22),
            Expanded(child: _buildFeed()),
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
          "Reviews",
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "View and manage user reviews",
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
        const SizedBox(width: 16),
        Expanded(
          flex: 26,
          child: _buildFilterField(
            label: "Movie Title",
            hint: "Search by movie title...",
            controller: _movieTitleController,
            icon: Icons.search,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 26,
          child: _buildRatingPicker(),
        ),
        const Spacer(flex: 26),
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
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: icon == null
                  ? null
                  : IconButton(
                      icon: Icon(icon, size: 20),
                      color: colors.onSurfaceVariant,
                      onPressed: _search,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingPicker() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Rating"),
        const SizedBox(height: 6),
        SizedBox(
          height: 46,
          child: InputDecorator(
            isEmpty: _selectedRating == null,
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<double?>(
                value: _selectedRating,
                isExpanded: true,
                isDense: true,
                alignment: AlignmentDirectional.centerStart,
                menuMaxHeight: 320,
                borderRadius: BorderRadius.circular(10),
                icon: Icon(Icons.expand_more, color: colors.onSurfaceVariant),
                style: TextStyle(color: colors.onSurface, fontSize: 14),
                items: [
                  DropdownMenuItem<double?>(
                    value: null,
                    child: Text(
                      "All ratings",
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ..._ratings.map(
                    (rating) => DropdownMenuItem<double?>(
                      value: rating,
                      child: Text("${formatRating(rating)} / 5"),
                    ),
                  ),
                ],
                onChanged: (rating) {
                  setState(() {
                    _selectedRating = rating;
                  });
                  _search();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeed() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviews.isEmpty) {
      return Center(
        child: Text(
          "No reviews found",
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: _reviews.length + (_hasMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index >= _reviews.length) return _buildFeedFooter();

        return _buildReviewCard(_reviews[index]);
      },
    );
  }

  Widget _buildFeedFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.movie?.title ?? "-",
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                _buildByline(review),
                const SizedBox(height: 16),
                Text(
                  review.content?.trim().isNotEmpty == true
                      ? review.content!.trim()
                      : "This review has no written content.",
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildRating(review),
              const SizedBox(height: 16),
              _buildDeleteButton(review),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildByline(Review review) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final TextStyle base = TextStyle(
      color: colors.onSurface,
      fontSize: 14,
    );

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: "Reviewed by "),
          TextSpan(
            text: review.user?.username ?? "-",
            style: base.copyWith(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: " on ${formatDate(review.createdAt)}"),
        ],
      ),
    );
  }

  Widget _buildRating(Review review) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double? rating = review.rating;

    if (rating == null) {
      return Text(
        "Not rated",
        style: TextStyle(
          color: colors.onSurfaceVariant,
          fontSize: 14,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int star = 1; star <= 5; star++)
          Icon(_starIcon(rating, star), color: _starColor, size: 22),
        const SizedBox(width: 8),
        Text(
          "${formatRating(rating)}/5",
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _starIcon(double rating, int star) {
    if (rating >= star) return Icons.star;
    if (rating >= star - 0.5) return Icons.star_half;
    return Icons.star_border;
  }

  Widget _buildDeleteButton(Review review) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: "Delete review",
      child: InkWell(
        onTap: () => _deleteReview(review),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: colors.error, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.delete_outline, color: colors.error, size: 22),
        ),
      ),
    );
  }

}
