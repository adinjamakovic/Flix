import 'package:flix_mobile/models/search_result.dart';
import 'package:flutter/material.dart';

// A centred message with an optional button under it — what a screen shows
// instead of its content when a load failed or matched nothing.
Widget buildMessage(BuildContext context, String message, {Widget? action}) {
  final ColorScheme colors = Theme.of(context).colorScheme;

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
          ),
          ?action,
        ],
      ),
    ),
  );
}

Widget buildEmpty(BuildContext context, String message) {
  final ColorScheme colors = Theme.of(context).colorScheme;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Text(
      message,
      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
    ),
  );
}

Widget buildSection(
  BuildContext context, {
  required String label,
  required Widget child,
}) {
  final ColorScheme colors = Theme.of(context).colorScheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const Divider(),
      Padding(padding: const EdgeInsets.fromLTRB(12, 14, 12, 0), child: child),
    ],
  );
}

// ---------------------------------------------------------------------------
// Images and links
// ---------------------------------------------------------------------------

Uri? httpUri(String? url) {
  final Uri? uri = Uri.tryParse(url ?? "");
  if (uri == null) return null;

  return (uri.scheme == "http" || uri.scheme == "https") ? uri : null;
}

// A movie poster, or the placeholder when there is no image or it fails to
// load.
Widget buildPoster(
  BuildContext context,
  String? posterUrl, {
  double width = 64,
  double height = 96,
  double iconSize = 26,
  double borderRadius = 6,
}) {
  final ColorScheme colors = Theme.of(context).colorScheme;
  final Uri? uri = httpUri(posterUrl);

  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: SizedBox(
      width: width,
      height: height,
      child: uri == null
          ? _buildPosterPlaceholder(colors, iconSize)
          : Image.network(
              uri.toString(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPosterPlaceholder(colors, iconSize),
            ),
    ),
  );
}

Widget _buildPosterPlaceholder(ColorScheme colors, double iconSize) {
  return ColoredBox(
    color: colors.surfaceContainer,
    child: Icon(
      Icons.movie_outlined,
      color: colors.onSurfaceVariant,
      size: iconSize,
    ),
  );
}

// "Sigourney Weaver" -> "SW", a single-word username -> its first letter.
String initialsOf(String? name) {
  final List<String> words = (name ?? "")
      .trim()
      .split(RegExp(r"\s+"))
      .where((word) => word.isNotEmpty)
      .toList();

  if (words.isEmpty) return "?";

  return words
      .take(2)
      .map((word) => word.characters.first.toUpperCase())
      .join();
}

// A user's or cast member's photo. The initials stand in while the image is
// missing or fails to load, so they are drawn as the child rather than swapped
// in afterwards.
Widget buildAvatar(
  BuildContext context,
  String? imageUrl,
  String? name, {
  double radius = 11,
}) {
  final ColorScheme colors = Theme.of(context).colorScheme;

  final Uri? uri = httpUri(imageUrl);

  return CircleAvatar(
    radius: radius,
    backgroundColor: colors.surfaceContainerHigh,
    foregroundImage: uri == null ? null : NetworkImage(uri.toString()),
    child: Text(
      initialsOf(name),
      style: TextStyle(
        color: colors.onSurfaceVariant,
        fontSize: radius * 0.8,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Ratings and dates
// ---------------------------------------------------------------------------

Widget buildRating(
  BuildContext context,
  double? rating, {
  double size = 16,
  String emptyLabel = "Not rated",
  bool isLiked = false,
  bool isRewatch = false,
}) {
  final ColorScheme colors = Theme.of(context).colorScheme;

  final int halfStars = (((rating ?? 0).clamp(0, 5)) * 2).round();
  final int fullStars = halfStars ~/ 2;

  return Row(
    children: [
      if (halfStars == 0)
        Text(
          emptyLabel,
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
        )
      else ...[
        ...List.generate(
          fullStars,
          (index) => Icon(Icons.star, size: size, color: colors.onSurface),
        ),
        if (halfStars.isOdd)
          Icon(Icons.star_half, size: size, color: colors.onSurface),
      ],
      if (isLiked) ...[
        const SizedBox(width: 8),
        Icon(Icons.favorite, size: size - 2, color: colors.primary),
      ],
      if (isRewatch) ...[
        const SizedBox(width: 8),
        Icon(Icons.replay, size: size - 2, color: colors.onSurfaceVariant),
      ],
    ],
  );
}

String titleWithYear(String? title, DateTime? releaseDate) {
  final String name = title ?? "-";
  final int? year = releaseDate?.year;

  return year == null ? name : "$name ($year)";
}

// Dates are shown as dd/mm/yyyy everywhere. The API sends UTC, so this is also
// the one place the conversion to local time happens.
String formatDate(DateTime? date) {
  if (date == null) return "-";

  final DateTime local = date.toLocal();
  final String day = local.day.toString().padLeft(2, '0');
  final String month = local.month.toString().padLeft(2, '0');

  return "$day/$month/${local.year}";
}

String formatDateTime(DateTime? date) {
  if (date == null) return "-";

  final DateTime local = date.toLocal();
  final String hour = local.hour.toString().padLeft(2, '0');
  final String minute = local.minute.toString().padLeft(2, '0');

  return "${formatDate(date)} $hour:$minute";
}

// ---------------------------------------------------------------------------
// API results and errors
// ---------------------------------------------------------------------------

List<T> itemsOf<T>(SearchResult<T> result) => result.items ?? List<T>.empty();

String errorText(Object error) =>
    error.toString().replaceFirst("Exception: ", "");

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

// ---------------------------------------------------------------------------
// Validators
// ---------------------------------------------------------------------------

const int passwordMinLength = 8;

String? requiredValidator(String? value, String field) =>
    (value == null || value.trim().isEmpty) ? '$field is required' : null;

String? maxLengthValidator(String? value, int maxLength, String field) =>
    (value != null && value.trim().length > maxLength)
    ? '$field must be $maxLength characters or fewer'
    : null;

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? emailValidator(String? value, {int maxLength = 150}) =>
    requiredValidator(value, 'Email') ??
    maxLengthValidator(value, maxLength, 'Email') ??
    (_emailPattern.hasMatch(value!.trim())
        ? null
        : 'Enter a valid email address');

final RegExp _passwordPattern = RegExp(
  r'(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9])',
);

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';

  if (value.length < passwordMinLength) {
    return 'Password must be at least $passwordMinLength characters';
  }

  if (!_passwordPattern.hasMatch(value)) {
    return 'Password must contain upper, lower, a digit and a special character';
  }

  return null;
}
