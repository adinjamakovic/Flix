import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/movie_list_details.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/screens/movie_details/movie_details.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flix_mobile/widgets/expandable_text.dart';
import 'package:flutter/material.dart';

/// Someone else's list, read-only — the owner edits theirs in `ListForm`.
class ListDetails extends StatelessWidget {
  const ListDetails({super.key, required this.list, this.owner});

  final MovieListDetails list;
  final User? owner;

  static const double _posterWidth = 60;
  static const double _posterHeight = 90;

  String? get _ownerName => owner?.username ?? list.user?.username;

  List<Movie> get _movies => list.movies ?? List<Movie>.empty();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List")),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: _movies.length + 1,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) => index == 0
            ? _buildHeader(context)
            : _buildMovieRow(context, _movies[index - 1]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String? description = list.description?.trim();
    final String? username = _ownerName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            list.name ?? "-",
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (owner != null || list.user != null) ...[
                buildAvatar(
                  context,
                  owner?.profileImage ?? list.user?.profileImage,
                  username,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  [
                    if (username != null && username.isNotEmpty) "by $username",
                    "${_movies.length} ${_movies.length == 1 ? "movie" : "movies"}",
                  ].join("  ·  "),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 14),
            ExpandableText(
              text: description,
              style: TextStyle(color: colors.onSurface, fontSize: 14),
            ),
          ],
          if (_movies.isEmpty) ...[
            const SizedBox(height: 20),
            buildEmpty(context, "No movies on this list yet."),
          ],
        ],
      ),
    );
  }

  Widget _buildMovieRow(BuildContext context, Movie movie) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MovieDetails(movieId: movie.id)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            buildPoster(
              context,
              movie.poster,
              width: _posterWidth,
              height: _posterHeight,
              iconSize: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleWithYear(movie.title, movie.releaseDate),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
