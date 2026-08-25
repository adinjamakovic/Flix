import 'package:flix_desktop/enums/movie_request_status.dart';
import 'package:flix_desktop/layouts/master_screen.dart';
import 'package:flix_desktop/models/movie_request.dart';
import 'package:flix_desktop/models/search_result.dart';
import 'package:flix_desktop/providers/movie_request_provider.dart';
import 'package:flix_desktop/screens/details/movie_details.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/paged_table.dart';
import 'package:flix_desktop/widgets/submission_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieRequestList extends StatefulWidget {
  const MovieRequestList({super.key});

  @override
  State<MovieRequestList> createState() => _MovieRequestListState();
}

class _MovieRequestListState extends State<MovieRequestList> {
  static const int _pageSize = 4;

  late MovieRequestProvider _requestProvider;

  SearchResult<MovieRequest>? result;
  bool isLoading = true;
  int _page = 1;

  MovieRequestStatus? _status = MovieRequestStatus.pending;

  @override
  void initState() {
    super.initState();

    _requestProvider = context.read<MovieRequestProvider>();

    _search(page: 1);
  }

  Map<String, dynamic> _buildFilter(int page) {
    final Map<String, dynamic> filter = {
      "page": page,
      "pageSize": _pageSize,
      "includeTotalCount": true,
      "includeUser": true,
      "includeMovie": true,
    };

    final MovieRequestStatus? status = _status;
    if (status != null) {
      filter["status"] = status.index;
    }

    return filter;
  }

  Future<void> _search({int? page}) async {
    final int requestedPage = page ?? _page;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await _requestProvider.get(filter: _buildFilter(requestedPage));

      if (!mounted) return;

      setState(() {
        result = data;
        _page = requestedPage;
        isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
      alertBox(context, "Error", e.toString());
    }
  }

  Future<void> _review(MovieRequest request) async {
    if (request.id == null || request.movie == null) return;

    final bool? reviewed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetails.review(submission: request),
      ),
    );

    if (reviewed != true || !mounted) return;

    // A reviewed submission drops out of the Pending filter, which can empty
    // the page the admin is standing on.
    final bool wasLastOnPage = (result?.items?.length ?? 0) == 1 && _page > 1;

    await _search(page: wasLastOnPage ? _page - 1 : _page);
  }

  Future<void> _openMovie(MovieRequest request) async {
    if (request.movie?.id == null) return;

    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => MovieDetails(movie: request.movie)),
    );

    if (saved == true && mounted) await _search();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "",
      destination: DrawerDestination.submissions,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 22),
            Expanded(child: _buildList()),
            const SizedBox(height: 12),
            Pagination(
              page: _page,
              pageSize: _pageSize,
              totalCount: result?.totalCount ?? 0,
              onPageChanged: (page) => _search(page: page),
            ),
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
          "Submissions",
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Go through the movies your users have asked you to add, correct what "
          "they sent in, and decide what reaches the catalogue",
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(flex: 26, child: _buildStatusFilter()),
        const Spacer(flex: 60),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _countLabel(),
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _countLabel() {
    final int count = result?.totalCount ?? 0;
    final String noun = count == 1 ? "submission" : "submissions";
    final String status =
        _status == null ? "" : " ${getMovieRequestStatus(_status!).toLowerCase()}";

    return "$count$status $noun";
  }

  Widget _buildStatusFilter() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Status",
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 46,
          child: InputDecorator(
            isEmpty: _status == null,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MovieRequestStatus?>(
                value: _status,
                isExpanded: true,
                isDense: true,
                alignment: AlignmentDirectional.centerStart,
                borderRadius: BorderRadius.circular(10),
                icon: Icon(Icons.expand_more, color: colors.onSurfaceVariant),
                style: TextStyle(color: colors.onSurface, fontSize: 14),
                items: [
                  DropdownMenuItem<MovieRequestStatus?>(
                    value: null,
                    child: Text(
                      "All submissions",
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ...MovieRequestStatus.values.map(
                    (status) => DropdownMenuItem<MovieRequestStatus?>(
                      value: status,
                      child: Text(getMovieRequestStatus(status)),
                    ),
                  ),
                ],
                onChanged: (status) {
                  setState(() {
                    _status = status;
                  });
                  _search(page: 1);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<MovieRequest> requests = result?.items ?? List.empty();

    if (requests.isEmpty) {
      return Center(
        child: Text(
          "No submissions found",
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => SubmissionCard(
        request: requests[index],
        onReview: () => _review(requests[index]),
        onOpenMovie: () => _openMovie(requests[index]),
      ),
    );
  }
}
