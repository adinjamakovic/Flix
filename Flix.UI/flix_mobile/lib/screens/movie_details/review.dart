import 'package:flix_mobile/models/review.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/review_provider.dart';
import 'package:flix_mobile/screens/review_details.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewTab extends StatefulWidget {
  const ReviewTab({super.key, required this.movieId});

  final int movieId;

  @override
  State<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {
  static const int _pageSize = 20;

  static const double _avatarRadius = 14;

  late ReviewProvider _reviewProvider;

  List<Review> _reviews = List.empty();

  final Set<int> _revealedSpoilers = <int>{};

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _reviewProvider = context.read<ReviewProvider>();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final SearchResult<Review> result = await _reviewProvider.get(
        filter: {
          "page": 1,
          "pageSize": _pageSize,
          "includeUser": true,
          "includeMovie": true,
          "movieId": widget.movieId,
        },
      );

      if (!mounted) return;

      setState(() {
        _reviews = itemsOf(result);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = errorText(e);
      });
    }
  }

  void _onReviewTapped(Review review) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReviewDetails(review: review)),
    );
  }

  void _toggleSpoilers(Review review) {
    final int? id = review.id;
    if (id == null) return;

    setState(() {
      if (!_revealedSpoilers.remove(id)) _revealedSpoilers.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return buildMessage(
        context,
        _error!,
        action: TextButton(onPressed: _load, child: const Text("Try again")),
      );
    }

    if (_reviews.isEmpty) {
      return buildEmpty(context, "Nobody has reviewed this movie yet.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < _reviews.length; i++) ...[
          if (i > 0) const Divider(),
          _buildReview(_reviews[i]),
        ],
      ],
    );
  }

  Widget _buildReview(Review review) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _onReviewTapped(review),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                buildAvatar(
                  context,
                  review.user?.profileImage,
                  review.user?.username,
                  radius: _avatarRadius,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    review.user?.username ?? "-",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatDate(review.createdAt),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            buildRating(
              context,
              review.rating,
              isLiked: review.isLiked == true,
              isRewatch: review.isRewatch == true,
            ),
            const SizedBox(height: 8),
            _buildContent(review),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Review review) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final String content = review.content?.trim() ?? "";
    if (content.isEmpty) {
      return Text(
        "No written review.",
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
      );
    }

    if (review.containsSpoilers == true &&
        !_revealedSpoilers.contains(review.id)) {
      return _buildSpoilerCover(review);
    }

    return Text(
      content,
      style: TextStyle(color: colors.onSurface, fontSize: 14, height: 1.3),
    );
  }

  Widget _buildSpoilerCover(Review review) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _toggleSpoilers(review),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.visibility_off_outlined,
              size: 16,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Contains spoilers. Tap to read.",
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
