import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';

class MovieSideScroll extends StatefulWidget {
  const MovieSideScroll({
    super.key,
    required this.title,
    required this.Movies,
    this.onMovieTap,
  });

  final String title;
  final List<Movie> Movies;
  final ValueChanged<Movie>? onMovieTap;

  @override
  _MovieSideScrollState createState() => _MovieSideScrollState();
}

class _MovieSideScrollState extends State<MovieSideScroll> {
  static const double _posterWidth = 100;
  static const double _posterHeight = 150;
  static const double _posterRadius = 6;

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
            height: _posterHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.Movies.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) =>
                  _buildPosterButton(widget.Movies[index]),
            ),
          ),
        ],
      ),
    );
  }

  /// The poster with the tap target over it — the ink has to sit on top of the
  /// image, not under it, or the image hides the splash.
  Widget _buildPosterButton(Movie movie) {
    final Widget poster = buildPoster(
      context,
      movie.poster,
      width: _posterWidth,
      height: _posterHeight,
      iconSize: 32,
      borderRadius: _posterRadius,
    );

    final ValueChanged<Movie>? onMovieTap = widget.onMovieTap;
    if (onMovieTap == null) return poster;

    return Stack(
      children: [
        poster,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onMovieTap(movie),
              borderRadius: BorderRadius.circular(_posterRadius),
            ),
          ),
        ),
      ],
    );
  }
}
