import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/review.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/providers/diary_provider.dart';
import 'package:flix_mobile/screens/review_details.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Diary extends StatefulWidget {
  const Diary({ super.key, required this.user });

  final User user;

  @override
  _DiaryState createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
  static const int _pageSize = 50;

  static const double _dayBoxSize = 44;
  static const double _dayBoxRadius = 6;

  static const double _posterWidth = 36;
  static const double _posterHeight = 54;
  static const double _posterRadius = 3;

  static const double _bottomInset = 88;

  static const List<String> _monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  late AuthProvider _authProvider;
  late DiaryProvider _diaryProvider;

  List<_DiaryMonth> _months = List.empty();

  bool _isLoading = true;
  String? _error;

  bool get _isCurrentUser =>
      widget.user.id != null && widget.user.id == _authProvider.userId;

  @override
  void initState() {
    super.initState();

    _authProvider = context.read<AuthProvider>();
    _diaryProvider = context.read<DiaryProvider>();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final int? userId = widget.user.id;

    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error = "User not found";
      });
      return;
    }

    try {
      final List<Review> entries = itemsOf(
        await _diaryProvider.getUserDiary(
          userId: userId,
          pageSize: _pageSize,
          includeTotalCount: false,
        ),
      );

      if (!mounted) return;

      setState(() {
        _months = _groupByMonth(entries);
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

  List<_DiaryMonth> _groupByMonth(List<Review> entries) {
    final List<_DiaryMonth> months = List.empty(growable: true);

    for (final Review entry in entries) {
      final String label = _monthLabel(entry.loggedOn);

      if (months.isEmpty || months.last.label != label) {
        months.add(_DiaryMonth(label, List.empty(growable: true)));
      }

      months.last.entries.add(entry);
    }

    return months;
  }

  String _monthLabel(DateTime? date) {
    if (date == null) return "Undated";

    final DateTime local = date.toLocal();

    return "${_monthNames[local.month - 1]} ${local.year}";
  }

  String _dayLabel(DateTime? date) =>
      date == null ? "-" : date.toLocal().day.toString();

  String _titleLabel(Review entry) =>
      titleWithYear(entry.movie?.title, entry.movie?.releaseDate);

  void _onEntryTapped(Review entry) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReviewDetails(review: entry)),
    );
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

    if (_months.isEmpty) {
      return buildMessage(
        context,
        _isCurrentUser
            ? "Your diary is empty. Movies you log show up here, newest first."
            : "${widget.user.username ?? "This user"} hasn't logged a movie yet.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: _bottomInset),
      itemCount: _months.length,
      itemBuilder: (context, index) => _buildMonth(_months[index]),
    );
  }

  Widget _buildMonth(_DiaryMonth month) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMonthHeader(month.label),
        ...month.entries.map(_buildEntry),
      ],
    );
  }

  Widget _buildMonthHeader(String label) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: Text(
          label,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEntry(Review entry) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Movie? movie = entry.movie;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => _onEntryTapped(entry),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildDayBox(entry),
                const SizedBox(width: 12),
                buildPoster(
                  context,
                  movie?.poster,
                  width: _posterWidth,
                  height: _posterHeight,
                  iconSize: 18,
                  borderRadius: _posterRadius,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _titleLabel(entry),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      buildRating(
                        context,
                        entry.rating,
                        size: 15,
                        emptyLabel: "No rating",
                        isLiked: entry.isLiked == true,
                        isRewatch: entry.isRewatch == true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildDayBox(Review entry) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: _dayBoxSize,
      height: _dayBoxSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(_dayBoxRadius),
      ),
      child: Text(
        _dayLabel(entry.loggedOn),
        style: TextStyle(
          color: colors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _DiaryMonth {
  _DiaryMonth(this.label, this.entries);

  final String label;
  final List<Review> entries;
}
