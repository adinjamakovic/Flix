import 'package:flix_desktop/models/movie.dart';
import 'package:flix_desktop/models/picked_image.dart';
import 'package:flix_desktop/models/studio.dart';
import 'package:flix_desktop/providers/movie_provider.dart';
import 'package:flix_desktop/providers/studio_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudioDetails extends StatefulWidget {
  const StudioDetails({super.key, this.studio});

  final Studio? studio;

  @override
  State<StudioDetails> createState() => _StudioDetailsState();
}

class _StudioDetailsState extends State<StudioDetails> {
  static const int _nameMaxLength = 100;

  static const int _filmographyPageSize = 100;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late StudioProvider _studioProvider;
  late MovieProvider _movieProvider;

  List<Movie> _movies = List.empty();
  int _movieCount = 0;
  bool _moviesLoading = false;
  bool _moviesFailed = false;

  PickedImage? _logo;
  bool _isSaving = false;

  bool get _isNewStudio => widget.studio?.id == null;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.studio?.name ?? "";
    _descriptionController.text = widget.studio?.description ?? "";

    _studioProvider = context.read<StudioProvider>();
    _movieProvider = context.read<MovieProvider>();

    if (!_isNewStudio) _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _moviesLoading = true;
      _moviesFailed = false;
    });

    try {
      final data = await _movieProvider.get(filter: {
        "page": 1,
        "pageSize": _filmographyPageSize,
        "includeTotalCount": true,
        "studioId": widget.studio!.id,
        "includeCast": true,
        "includeReviews": true,
      });

      if (!mounted) return;

      final List<Movie> movies = data.items ?? List.empty();
      // Newest first, with the undated ones after everything that has a date.
      movies.sort((a, b) {
        final DateTime? left = a.releaseDate;
        final DateTime? right = b.releaseDate;

        if (left == null && right == null) return 0;
        if (left == null) return 1;
        if (right == null) return -1;

        return right.compareTo(left);
      });

      setState(() {
        _movies = movies;
        _movieCount = data.totalCount ?? movies.length;
        _moviesLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _moviesLoading = false;
        _moviesFailed = true;
      });
      alertBox(context, "Error", e.toString());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNewStudio
              ? "New Studio"
              : "Update studio: ${widget.studio!.name ?? "-"}",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: _buildForm(),
                  ),
                ),
                if (!_isNewStudio) ...[
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: _buildFilmography(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageInput(
                label: "Logo",
                helperText: "JPG, PNG, GIF or WEBP, up to 5 MB.",
                placeholderIcon: Icons.business_outlined,
                shape: ImageInputShape.rectangle,
                currentImageUrl: widget.studio?.logo,
                enabled: !_isSaving,
                onChanged: (image) => _logo = image,
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    _buildTextField(
                      label: "Name",
                      controller: _nameController,
                      validator: (value) =>
                          requiredValidator(value) ??
                          maxLengthValidator(value, _nameMaxLength),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: "Description",
                      hint: "Optional",
                      controller: _descriptionController,
                      maxLines: 5,
                      validator: (value) => null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isNewStudio ? "Create studio" : "Save changes"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilmography() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Movies",
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            if (!_moviesLoading && !_moviesFailed)
              Text(
                formatCount(_movieCount),
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Everything ${widget.studio?.name ?? "this studio"} is credited on.",
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: 18),
        _buildFilmographyBody(),
      ],
    );
  }

  Widget _buildFilmographyBody() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (_moviesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_moviesFailed) {
      return Row(
        children: [
          Text(
            "The movies could not be loaded.",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(width: 8),
          TextButton(onPressed: _loadMovies, child: const Text("Try again")),
        ],
      );
    }

    if (_movies.isEmpty) {
      return Text(
        "No movies are credited to this studio yet.",
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
      );
    }

    final int notShown = _movieCount - _movies.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _movies.length; i++) ...[
          if (i > 0) Divider(height: 1, color: colors.outlineVariant),
          _buildMovieRow(_movies[i]),
        ],
        if (notShown > 0) ...[
          const SizedBox(height: 12),
          Text(
            "and ${formatCount(notShown)} more",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _buildMovieRow(Movie movie) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final int? year = movie.releaseDate?.year;
    final String director = movie.directorName ?? "-";
    final double? rating = movie.rating;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _buildPoster(movie),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title ?? "-",
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${year?.toString() ?? "Unreleased"} · $director",
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (movie.isEnabled == false) ...[
            Text(
              "Disabled",
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Row(
            children: [
              Icon(Icons.star_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 4),
              Text(
                rating == null ? "-" : formatRating(rating),
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPoster(Movie movie) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Uri? uri = Uri.tryParse(movie.poster ?? "");
    final bool isNetworkImage =
        uri != null && (uri.scheme == "http" || uri.scheme == "https");

    final Widget placeholder = Icon(
      Icons.movie_outlined,
      size: 18,
      color: colors.onSurfaceVariant,
    );

    return Container(
      width: 40,
      height: 58,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: isNetworkImage
          ? Image.network(
              uri.toString(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => placeholder,
            )
          : placeholder,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    String? hint,
    int maxLines = 1,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: !_isSaving,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(color: colors.onSurface, fontSize: 14),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    final Map<String, dynamic> fields = {
      "name": _nameController.text.trim(),
      "description": _nullIfBlank(_descriptionController.text),
    };

    final Map<String, PickedImage> files = {"logo": ?_logo};

    try {
      if (_isNewStudio) {
        await _studioProvider.insert(fields, files: files);
      } else {
        await _studioProvider.update(widget.studio!.id!, fields, files: files);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });
      alertBox(context, "Error", e.toString());
    }
  }

  String? _nullIfBlank(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
