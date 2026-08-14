import 'package:flix_mobile/models/cast_member.dart';
import 'package:flix_mobile/models/genre.dart';
import 'package:flix_mobile/models/picked_image.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/providers/cast_member_provider.dart';
import 'package:flix_mobile/providers/genre_provider.dart';
import 'package:flix_mobile/providers/movie_request_provider.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flix_mobile/widgets/poster_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddMovie extends StatefulWidget {
  const AddMovie({super.key});

  @override
  State<AddMovie> createState() => _AddMovieState();
}

class _AddMovieState extends State<AddMovie> {
  static const int _titleMaxLength = 200;
  static const int _directorMaxLength = 101;

  static const int _lookupPageSize = 200;

  static const int _earliestYear = 1900;

  static const double _fieldRadius = 14;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late MovieRequestProvider _movieRequestProvider;
  late GenreProvider _genreProvider;
  late CastMemberProvider _castMemberProvider;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Genre> _genres = List.empty();
  List<String> _directorNames = List.empty();
  bool _lookupsLoading = true;

  Genre? _selectedGenre;
  int? _selectedYear;
  PickedImage? _poster;

  // `PosterInput` owns the picked file, so clearing the form after a submit
  // means giving it a fresh state rather than reaching into it.
  int _formGeneration = 0;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _movieRequestProvider = context.read<MovieRequestProvider>();
    _genreProvider = context.read<GenreProvider>();
    _castMemberProvider = context.read<CastMemberProvider>();

    _loadLookups();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _directorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    try {
      final List<dynamic> results = await Future.wait([
        _genreProvider.get(filter: _lookupFilter),
        _castMemberProvider.get(filter: _lookupFilter),
      ]);

      if (!mounted) return;

      final List<Genre> genres = itemsOf(results[0] as SearchResult<Genre>)
        ..sort(
          (a, b) => (a.name ?? "").toLowerCase().compareTo(
            (b.name ?? "").toLowerCase(),
          ),
        );

      final List<String> directors =
          itemsOf(results[1] as SearchResult<CastMember>)
              .map((member) => member.fullName)
              .whereType<String>()
              .where((name) => name.trim().isNotEmpty)
              .toSet()
              .toList()
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      setState(() {
        _genres = genres;
        _directorNames = directors;
        _lookupsLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() => _lookupsLoading = false);
      showSnack(context, errorText(e));
    }
  }

  Map<String, dynamic> get _lookupFilter => {
    "page": 1,
    "pageSize": _lookupPageSize,
  };

  static final List<int> _years = [
    for (int year = DateTime.now().year + 1; year >= _earliestYear; year--)
      year,
  ];

  Future<void> _submit() async {
    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      await _movieRequestProvider.submitRequest(
        title: _titleController.text.trim(),
        directorName: _nullIfBlank(_directorController.text),
        description: _nullIfBlank(_descriptionController.text),
        // The form only asks for a year; the admin corrects the exact date
        // during review.
        dateOfRelease: _selectedYear == null
            ? null
            : DateTime.utc(_selectedYear!),
        genreId: _selectedGenre?.id,
        poster: _poster,
      );

      if (!mounted) return;

      _resetForm();
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Request submitted. An admin will review it."),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(errorText(e))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();

    _titleController.clear();
    _directorController.clear();
    _descriptionController.clear();

    setState(() {
      _selectedGenre = null;
      _selectedYear = null;
      _poster = null;
      _formGeneration++;
    });
  }

  String? _nullIfBlank(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  // The cast the API already knows about, as a picker. The field stays free
  // text either way — a director nobody has heard of yet is exactly what a
  // request is for, and the API creates a draft cast member for one.
  Future<void> _openDirectorPicker() async {
    FocusScope.of(context).unfocus();

    if (_directorNames.isEmpty) {
      showSnack(
        context,
        _lookupsLoading
            ? "Still loading directors..."
            : "No cast members to pick from — type the name instead.",
      );
      return;
    }

    final ColorScheme colors = Theme.of(context).colorScheme;

    final String? name = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _directorNames.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) => ListTile(
              title: Text(_directorNames[index]),
              onTap: () => Navigator.pop(context, _directorNames[index]),
            ),
          ),
        ),
      ),
    );

    if (name == null) return;

    _directorController.text = name;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      // Keeps the fields off the keyboard instead of overflowing behind it.
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Add a new movie",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              enabled: !_isSubmitting,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: _decoration(hint: "Movie title..."),
              validator: (value) =>
                  requiredValidator(value, "Movie title") ??
                  maxLengthValidator(value, _titleMaxLength, "Movie title"),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _directorController,
              enabled: !_isSubmitting,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: _decoration(
                hint: "Director",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.menu, size: 20),
                  tooltip: "Pick from the cast the API knows",
                  onPressed: _isSubmitting ? null : _openDirectorPicker,
                ),
              ),
              validator: (value) =>
                  maxLengthValidator(value, _directorMaxLength, "Director"),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionController,
              enabled: !_isSubmitting,
              minLines: 6,
              maxLines: 10,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              decoration: _decoration(hint: "Description"),
            ),
            const SizedBox(height: 14),
            _buildDropdown<int>(
              hint: "Year of release",
              value: _selectedYear,
              items: _years,
              labelOf: (year) => year.toString(),
              onChanged: (year) => setState(() => _selectedYear = year),
            ),
            const SizedBox(height: 14),
            _buildDropdown<Genre>(
              hint: "Movie genre...",
              value: _selectedGenre,
              items: _genres,
              labelOf: (genre) => genre.name ?? "-",
              onChanged: _lookupsLoading
                  ? null
                  : (genre) => setState(() => _selectedGenre = genre),
            ),
            const SizedBox(height: 14),
            PosterInput(
              key: ValueKey(_formGeneration),
              enabled: !_isSubmitting,
              onChanged: (image) => _poster = image,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
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
                    : const Text("Submit Request"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration({
    String? hint,
    Widget? suffixIcon,
    EdgeInsets? contentPadding,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding,
      errorMaxLines: 2,
      border: _border(),
      enabledBorder: _border(),
      disabledBorder: _border(),
      focusedBorder: _border(colors.primary),
      errorBorder: _border(colors.error),
      focusedErrorBorder: _border(colors.error),
    );
  }

  OutlineInputBorder _border([Color? color]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(_fieldRadius),
    borderSide: color == null
        ? BorderSide.none
        : BorderSide(color: color, width: 1.5),
  );

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T?>? onChanged,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool enabled = onChanged != null && !_isSubmitting;

    return InputDecorator(
      decoration: _decoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: value,
          isExpanded: true,
          isDense: true,
          alignment: AlignmentDirectional.centerStart,
          menuMaxHeight: 340,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: colors.surfaceContainerHigh,
          icon: Icon(Icons.menu, size: 20, color: colors.onSurfaceVariant),
          style: TextStyle(color: colors.onSurface, fontSize: 15),
          hint: Text(
            _lookupsLoading && items.isEmpty ? "Loading..." : hint,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 15),
          ),
          items: [
            DropdownMenuItem<T?>(
              value: null,
              child: Text(
                hint,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 15),
              ),
            ),
            ...items.map(
              (item) => DropdownMenuItem<T?>(
                value: item,
                child: Text(labelOf(item), overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}
