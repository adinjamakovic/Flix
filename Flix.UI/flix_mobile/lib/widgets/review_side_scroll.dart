import 'package:flix_mobile/models/review.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';

class ReviewSideScroll extends StatefulWidget {
  const ReviewSideScroll({
    super.key,
    required this.title,
    required this.reviews,
    this.onReviewTap,
  });

  final String title;
  final List<Review> reviews;
  final ValueChanged<Review>? onReviewTap;

  @override
  _ReviewSideScrollState createState() => _ReviewSideScrollState();
}

class _ReviewSideScrollState extends State<ReviewSideScroll> {
  static const double _posterWidth = 100;
  static const double _posterHeight = 150;
  static const double _posterRadius = 6;
  static const double _bylineGap = 6;
  static const double _bylineHeight = 30;
  static const double _avatarRadius = 10;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: _posterHeight + _bylineGap + _bylineHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.reviews.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) =>
                  _buildReviewCard(widget.reviews[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final Widget card = SizedBox(
      width: _posterWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPoster(
            context,
            review.movie?.poster,
            width: _posterWidth,
            height: _posterHeight,
            iconSize: 32,
            borderRadius: _posterRadius,
          ),
          const SizedBox(height: _bylineGap),
          _buildByline(review),
        ],
      ),
    );

    final ValueChanged<Review>? onReviewTap = widget.onReviewTap;
    if (onReviewTap == null) return card;

    return Stack(
      children: [
        card,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onReviewTap(review),
              borderRadius: BorderRadius.circular(_posterRadius),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildByline(Review review) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildAvatar(
          context,
          review.user?.profileImage,
          review.user?.username,
          radius: _avatarRadius,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                review.user?.username ?? "-",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              buildRating(
                context,
                review.rating,
                size: 11,
                emptyLabel: "No rating",
                isLiked: review.isLiked == true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
