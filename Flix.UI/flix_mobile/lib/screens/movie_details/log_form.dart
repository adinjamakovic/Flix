import 'package:flix_mobile/models/movie.dart';
import 'package:flix_mobile/models/movie_user_state.dart';
import 'package:flix_mobile/providers/diary_provider.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flix_mobile/widgets/star_rating_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// "Review or log..." — one viewing, appended to the diary. Confirming it pops
/// with `true`, which the caller reads as "reload the movie".
class LogMovieForm extends StatefulWidget {
  const LogMovieForm({super.key, required this.movie, required this.state});

  final Movie movie;
  final MovieUserState state;

  @override
  State<LogMovieForm> createState() => _LogMovieFormState();
}

class _LogMovieFormState extends State<LogMovieForm> {
  static const double _fieldRadius = 14;

  static const double _posterWidth = 56;
  static const double _posterHeight = 84;

  static const int _earliestYear = 1900;

  late DiaryProvider _diaryProvider;

  final TextEditingController _contentController = TextEditingController();

  late DateTime _watchedOn = _today;
  late double _rating = widget.state.stars;
  late bool _isLiked = widget.state.liked;
  late bool _isRewatch = widget.state.isRewatch;

  bool _containsSpoilers = false;
  bool _isSubmitting = false;

  static DateTime get _today {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool get _hasReview => _contentController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    _diaryProvider = context.read<DiaryProvider>();

    // The spoiler switch only means anything next to written text, and the API
    // rejects the pair outright, so it follows the field.
    _contentController.addListener(() {
      if (_hasReview || !_containsSpoilers) {
        setState(() {});
        return;
      }

      setState(() => _containsSpoilers = false);
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickWatchedOn() async {
    FocusScope.of(context).unfocus();

    final DateTime last = _today;

    // A movie cannot have been seen before it came out, but one that has not
    // come out yet would leave the picker with no range at all.
    final DateTime release = widget.movie.releaseDate ?? DateTime(_earliestYear);
    final DateTime first = release.isAfter(last) ? last : release;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _watchedOn.isBefore(first) ? first : _watchedOn,
      firstDate: first,
      lastDate: last,
      helpText: "Watched on",
    );

    if (picked == null) return;

    setState(() => _watchedOn = picked);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    FocusScope.of(context).unfocus();

    final int? movieId = widget.movie.id;
    if (movieId == null) return;

    setState(() => _isSubmitting = true);

    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      await _diaryProvider.addToDiary(
        movieId: movieId,
        watchedOn: _watchedOn,
        rating: _rating == 0 ? null : _rating,
        isLiked: _isLiked,
        content: _hasReview ? _contentController.text.trim() : null,
        containsSpoilers: _containsSpoilers,
        isRewatch: _isRewatch,
      );

      if (!mounted) return;

      navigator.pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isRewatch ? "Rewatch added to your diary" : "Added to your diary",
          ),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);
      messenger.showSnackBar(SnackBar(content: Text(errorText(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review or log"),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: const Text("Save"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Keeps the fields off the keyboard instead of overflowing behind it.
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildWatchedOn(),
            const Divider(),
            _buildRewatch(),
            const Divider(),
            _buildRating(),
            const Divider(),
            const SizedBox(height: 12),
            _buildContent(),
            const SizedBox(height: 8),
            _buildSpoilers(),
            const SizedBox(height: 20),
            Center(child: _buildSubmit()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildPoster(
          context,
          widget.movie.poster,
          width: _posterWidth,
          height: _posterHeight,
          iconSize: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleWithYear(widget.movie.title, widget.movie.releaseDate),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.movie.director?.fullName ?? "Unknown director",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWatchedOn() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today_outlined, size: 22),
      title: const Text("Watched on", style: TextStyle(fontSize: 15)),
      trailing: Text(
        formatDate(_watchedOn),
        style: TextStyle(
          color: colors.primary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: _isSubmitting ? null : _pickWatchedOn,
    );
  }

  Widget _buildRewatch() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: const Icon(Icons.replay, size: 22),
      title: const Text("I've watched this before", style: TextStyle(fontSize: 15)),
      value: _isRewatch,
      onChanged: _isSubmitting
          ? null
          : (value) => setState(() => _isRewatch = value),
    );
  }

  Widget _buildRating() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Rating",
                  style: TextStyle(color: colors.onSurface, fontSize: 15),
                ),
              ),
              IconButton(
                tooltip: _isLiked ? "Liked" : "Like",
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? colors.primary : colors.onSurface,
                ),
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() => _isLiked = !_isLiked),
              ),
            ],
          ),
          const SizedBox(height: 4),
          StarRatingInput(
            rating: _rating,
            enabled: !_isSubmitting,
            onChanged: (value) => setState(() => _rating = value),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return TextField(
      controller: _contentController,
      enabled: !_isSubmitting,
      minLines: 6,
      maxLines: 12,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      decoration: _decoration("Add a review..."),
    );
  }

  Widget _buildSpoilers() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: const Icon(Icons.visibility_off_outlined, size: 22),
      title: Text(
        "Contains spoilers",
        style: TextStyle(
          fontSize: 15,
          color: _hasReview ? colors.onSurface : colors.onSurfaceVariant,
        ),
      ),
      value: _containsSpoilers,
      onChanged: _isSubmitting || !_hasReview
          ? null
          : (value) => setState(() => _containsSpoilers = value),
    );
  }

  Widget _buildSubmit() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submit,
      child: _isSubmitting
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.onPrimary,
              ),
            )
          : const Text("Save entry"),
    );
  }

  InputDecoration _decoration(String hint) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hint,
      border: _border(),
      enabledBorder: _border(),
      disabledBorder: _border(),
      focusedBorder: _border(colors.primary),
    );
  }

  OutlineInputBorder _border([Color? color]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(_fieldRadius),
    borderSide: color == null
        ? BorderSide.none
        : BorderSide(color: color, width: 1.5),
  );
}
