import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flix_desktop/models/cast_member.dart';
import 'package:flix_desktop/models/country.dart';
import 'package:flix_desktop/models/genre.dart';
import 'package:flix_desktop/models/language.dart';
import 'package:flix_desktop/models/movie.dart';
import 'package:flix_desktop/models/movie_credit.dart';
import 'package:flix_desktop/models/movie_request.dart';
import 'package:flix_desktop/models/picked_image.dart';
import 'package:flix_desktop/models/studio.dart';
import 'package:flix_desktop/providers/cast_provider.dart';
import 'package:flix_desktop/providers/country_provider.dart';
import 'package:flix_desktop/providers/genre_provider.dart';
import 'package:flix_desktop/providers/language_provider.dart';
import 'package:flix_desktop/providers/movie_provider.dart';
import 'package:flix_desktop/providers/movie_request_provider.dart';
import 'package:flix_desktop/providers/studio_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieDetails extends StatefulWidget {
  const MovieDetails({super.key, this.movie}) : request = null;

  MovieDetails.review({super.key, required MovieRequest submission})
      : request = submission,
        movie = submission.movie;

  final Movie? movie;
  final MovieRequest? request;

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  /// The lookup dropdowns hold the whole list, same as the list-screen filters.
  static const int _lookupPageSize = 200;

  static const int _titleMaxLength = 200;
  static const int _trailerUrlMaxLength = 500;

  /// Mirrors `MovieCast.CharacterName`.
  static const int _characterNameMaxLength = 100;

  // `CastRole` serializes as its numeric value, same as everywhere else.
  static const int _actorRole = 0;
  static const int _directorRole = 1;

  // A movie can be dated back to the first films ever made, and forward far
  // enough to schedule an announced release.
  static final DateTime _minSelectableDate = DateTime(1900, 1, 1);
  static final DateTime _maxSelectableDate = DateTime(2100, 12, 31);

  static const int _directorNameMaxLength = 50;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _trailerUrlController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  late MovieProvider _movieProvider;
  late final MovieRequestProvider _movieRequestProvider;
  late CountryProvider _countryProvider;
  late LanguageProvider _languageProvider;
  late GenreProvider _genreProvider;
  late StudioProvider _studioProvider;
  late CastProvider _castProvider;

  List<Country> _countries = List.empty();
  bool _countriesLoading = true;
  int? _selectedCountryId;

  List<Language> _languages = List.empty();
  bool _languagesLoading = true;
  int? _selectedLanguageId;

  List<Genre> _genres = List.empty();
  bool _genresLoading = true;
  final Set<int> _selectedGenreIds = <int>{};

  List<Studio> _studios = List.empty();
  bool _studiosLoading = true;
  final Set<int> _selectedStudioIds = <int>{};

  List<CastMember> _castMembers = List.empty();
  bool _castMembersLoading = true;

  int? _directorId;
  final TextEditingController _directorNameController = TextEditingController();
  final FocusNode _directorFocusNode = FocusNode();

  int? _requestedDirectorId;
  final TextEditingController _directorFirstNameController =
      TextEditingController();
  final TextEditingController _directorLastNameController =
      TextEditingController();
  final TextEditingController _directorBiographyController =
      TextEditingController();
  int? _directorCountryId;
  DateTime? _directorBirthDate;
  PickedImage? _directorPhoto;

  final List<_CastCreditRow> _castRows = <_CastCreditRow>[];

  /// Names of the people already credited on the movie, so a cast member who
  /// did not come back with the dropdown's page still reads correctly.
  final Map<int, String> _knownCastNames = <int, String>{};

  DateTime? _releaseDate;
  bool _isEnabled = true;

  PickedImage? _poster;
  PickedImage? _headerImage;
  bool _isSaving = false;

  bool get _isNewMovie => widget.movie?.id == null;

  bool get _isReview => widget.request != null;

  bool get _editsRequestedDirector =>
      _requestedDirectorId != null && _directorId == _requestedDirectorId;

  @override
  void initState() {
    super.initState();

    _titleController.text = widget.movie?.title ?? "";
    _descriptionController.text = widget.movie?.description ?? "";
    _trailerUrlController.text = widget.movie?.trailerUrl ?? "";
    _durationController.text = widget.movie?.durationMinutes?.toString() ?? "";
    _releaseDate = widget.movie?.releaseDate;
    _isEnabled = _isReview ? true : (widget.movie?.isEnabled ?? true);
    _selectedCountryId = widget.movie?.country?.id;
    _selectedLanguageId = widget.movie?.language?.id;
    _selectedGenreIds.addAll(
      (widget.movie?.genres ?? const <Genre>[])
          .map((genre) => genre.id)
          .whereType<int>(),
    );
    _selectedStudioIds.addAll(
      (widget.movie?.studios ?? const <Studio>[])
          .map((studio) => studio.id)
          .whereType<int>(),
    );

    _directorId = widget.movie?.director?.id;
    _rememberName(widget.movie?.director);
    _directorNameController.text = widget.movie?.director?.fullName ?? "";
    _directorFocusNode.addListener(
      () => _syncMenuText(
        _directorFocusNode,
        _directorNameController,
        _directorId,
      ),
    );

    for (final MovieCredit credit in widget.movie?.cast ?? const <MovieCredit>[]) {
      _rememberName(credit.castMember);
      _castRows.add(_registerRow(_CastCreditRow(
        castMemberId: credit.castMember?.id,
        castMemberName: credit.castMember?.fullName,
        characterName: credit.characterName,
      )));
    }

    _prefillRequestedDirector();

    _movieProvider = context.read<MovieProvider>();
    if (_isReview) _movieRequestProvider = context.read<MovieRequestProvider>();
    _countryProvider = context.read<CountryProvider>();
    _languageProvider = context.read<LanguageProvider>();
    _genreProvider = context.read<GenreProvider>();
    _studioProvider = context.read<StudioProvider>();
    _castProvider = context.read<CastProvider>();

    _loadCountries();
    _loadLanguages();
    _loadGenres();
    _loadStudios();
    _loadCastMembers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _trailerUrlController.dispose();
    _durationController.dispose();
    _directorNameController.dispose();
    _directorFocusNode.dispose();
    _directorFirstNameController.dispose();
    _directorLastNameController.dispose();
    _directorBiographyController.dispose();
    for (final _CastCreditRow row in _castRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _prefillRequestedDirector() {
    final CastMember? director = widget.request?.requestedDirector;

    if (director == null) return;

    _requestedDirectorId = director.id;
    _directorFirstNameController.text = director.firstName ?? "";
    _directorLastNameController.text = director.lastName ?? "";
    _directorBiographyController.text = director.biography ?? "";
    _directorCountryId = director.country?.id;
    _directorBirthDate = director.birthDate;
  }

  void _rememberName(CastMember? member) {
    final int? id = member?.id;
    final String? name = member?.fullName;

    if (id != null && name != null) _knownCastNames[id] = name;
  }

  Future<void> _loadCountries() async {
    try {
      final data = await _countryProvider.get(
        filter: {"page": 1, "pageSize": _lookupPageSize},
      );

      if (!mounted) return;

      final List<Country> countries = data.items ?? List.empty();
      countries.sort(
        (a, b) =>
            (a.name ?? "").toLowerCase().compareTo((b.name ?? "").toLowerCase()),
      );

      setState(() {
        _countries = countries;
        _countriesLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _countriesLoading = false;
      });
      alertBox(context, "Error", e.toString());
    }
  }

  Future<void> _loadLanguages() async {
    try {
      final data = await _languageProvider.get(
        filter: {"page": 1, "pageSize": _lookupPageSize},
      );

      if (!mounted) return;

      final List<Language> languages = data.items ?? List.empty();
      languages.sort(
        (a, b) =>
            (a.name ?? "").toLowerCase().compareTo((b.name ?? "").toLowerCase()),
      );

      setState(() {
        _languages = languages;
        _languagesLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _languagesLoading = false;
      });
      alertBox(context, "Error", e.toString());
    }
  }

  Future<void> _loadGenres() async {
    try {
      final data = await _genreProvider.get(
        filter: {"page": 1, "pageSize": _lookupPageSize},
      );

      if (!mounted) return;

      final List<Genre> genres = data.items ?? List.empty();
      genres.sort(
        (a, b) =>
            (a.name ?? "").toLowerCase().compareTo((b.name ?? "").toLowerCase()),
      );

      setState(() {
        _genres = genres;
        _genresLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _genresLoading = false;
      });
      alertBox(context, "Error", e.toString());
    }
  }

  Future<void> _loadStudios() async {
    try {
      final data = await _studioProvider.get(
        filter: {"page": 1, "pageSize": _lookupPageSize},
      );

      if (!mounted) return;

      final List<Studio> studios = data.items ?? List.empty();
      studios.sort(
        (a, b) =>
            (a.name ?? "").toLowerCase().compareTo((b.name ?? "").toLowerCase()),
      );

      setState(() {
        _studios = studios;
        _studiosLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _studiosLoading = false;
      });
      alertBox(context, "Error", e.toString());
    }
  }

  // Deliberately unfiltered by role: the API derives a cast member's roles from
  // the credits they already have, so filtering on Director would hide anyone
  // directing for the first time — the credit created here is what makes them
  // a director in the first place.
  Future<void> _loadCastMembers() async {
    try {
      final data = await _castProvider.get(
        filter: {"page": 1, "pageSize": _lookupPageSize},
      );

      if (!mounted) return;

      final List<CastMember> castMembers = data.items ?? List.empty();
      castMembers.sort(
        (a, b) => (a.fullName ?? "")
            .toLowerCase()
            .compareTo((b.fullName ?? "").toLowerCase()),
      );

      setState(() {
        _castMembers = castMembers;
        _castMembersLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _castMembersLoading = false;
      });
      alertBox(context, "Error", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: _buildForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _appBarTitle() {
    final String title = widget.movie?.title ?? "";

    if (_isReview) return "Review submission: $title";

    return _isNewMovie ? "New Movie" : "Update movie: $title";
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isReview) ...[
            _buildSubmissionBanner(),
            const SizedBox(height: 24),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageInput(
                label: "Poster",
                helperText: "JPG, PNG, GIF or WEBP, up to 5 MB.",
                placeholderIcon: Icons.movie_outlined,
                currentImageUrl: widget.movie?.poster,
                enabled: !_isSaving,
                shape: ImageInputShape.rectangle,
                size: 180,
                onChanged: (image) => _poster = image,
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      label: "Title",
                      controller: _titleController,
                      validator: (value) =>
                          requiredValidator(value) ??
                          maxLengthValidator(value, _titleMaxLength),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            label: "Release date",
                            value: _releaseDate,
                            onChanged: (date) =>
                                setState(() => _releaseDate = date),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: "Duration (minutes)",
                            hint: "Optional",
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            validator: _durationValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildCountryPicker()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildLanguagePicker()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Trailer URL",
            hint: "Optional",
            controller: _trailerUrlController,
            keyboardType: TextInputType.url,
            validator: _trailerUrlValidator,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Description",
            hint: "Optional",
            controller: _descriptionController,
            maxLines: 4,
            validator: (_) => null,
          ),
          const SizedBox(height: 16),
          _buildGenrePicker(),
          const SizedBox(height: 16),
          _buildStudioPicker(),
          const SizedBox(height: 24),
          _buildCastAndCrew(),
          const SizedBox(height: 24),
          ImageInput(
            label: "Header image",
            helperText: "Wide banner shown on the movie page.",
            placeholderIcon: Icons.landscape_outlined,
            currentImageUrl: widget.movie?.headerImage,
            enabled: !_isSaving,
            shape: ImageInputShape.rectangle,
            size: 400,
            onChanged: (image) => _headerImage = image,
          ),
          const SizedBox(height: 16),
          _buildEnabledSwitch(),
          const SizedBox(height: 28),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        const SizedBox(width: 12),
        if (_isReview) ...[
          OutlinedButton.icon(
            onPressed: _isSaving ? null : () => _submitReview(false),
            icon: const Icon(Icons.block, size: 18),
            label: const Text("Reject"),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              side: BorderSide(color: colors.error),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        ElevatedButton(
          onPressed:
              _isSaving ? null : (_isReview ? () => _submitReview(true) : _save),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isReview
                  ? "Approve"
                  : _isNewMovie
                      ? "Create movie"
                      : "Save changes"),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Text(
      label,
      style: TextStyle(
        color: colors.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: !_isSaving,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: colors.onSurface, fontSize: 14),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required void Function(DateTime?) onChanged,
    DateTime? maxDate,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 6),
        FormField<DateTime>(
          initialValue: value,
          builder: (field) => InkWell(
            onTap: _isSaving
                ? null
                : () => _pickDate(field, value, onChanged, maxDate),
            child: InputDecorator(
              decoration: InputDecoration(
                errorText: field.errorText,
                suffixIcon: value == null
                    ? Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                        color: colors.onSurfaceVariant,
                      )
                    : IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: colors.onSurfaceVariant,
                        tooltip: "Clear the ${label.toLowerCase()}",
                        onPressed: _isSaving
                            ? null
                            : () {
                                onChanged(null);
                                field.didChange(null);
                              },
                      ),
              ),
              child: Text(
                value == null ? "Optional" : formatDate(value),
                style: TextStyle(
                  color: value == null
                      ? colors.onSurfaceVariant
                      : colors.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(
    FormFieldState<DateTime> field,
    DateTime? value,
    void Function(DateTime?) onChanged,
    DateTime? maxDate,
  ) async {
    final DateTime? date = await showDatePickerDialog(
      context: context,
      minDate: _minSelectableDate,
      maxDate: maxDate ?? _maxSelectableDate,
      selectedDate: value,
    );

    if (date == null || !mounted) return;

    onChanged(date);

    field.didChange(date);
  }

  Widget _buildCountryPicker() {
    return _buildDropdownField(
      label: "Country of origin",
      value: _selectedCountryId,
      items: _buildCountryItems(widget.movie?.country),
      hint: _countriesLoading ? "Loading countries..." : "Optional",
      enabled: !_countriesLoading,
      onChanged: (value) => setState(() => _selectedCountryId = value),
    );
  }

  Widget _buildLanguagePicker() {
    return _buildDropdownField(
      label: "Language",
      value: _selectedLanguageId,
      items: _buildLanguageItems(),
      hint: _languagesLoading ? "Loading languages..." : "Optional",
      enabled: !_languagesLoading,
      onChanged: (value) => setState(() => _selectedLanguageId = value),
    );
  }

  // The lookup lists are paged, so the value already on the movie is prepended
  // when it did not come back with the page the dropdown loaded.
  List<DropdownMenuItem<int?>> _buildCountryItems(
    Country? current, {
    String emptyLabel = "No country",
  }) {
    final List<Country> countries = List<Country>.from(_countries);

    if (current?.id != null &&
        !countries.any((country) => country.id == current!.id)) {
      countries.insert(0, current!);
    }

    return [
      DropdownMenuItem<int?>(value: null, child: Text(emptyLabel)),
      ...countries.map(
        (country) => DropdownMenuItem<int?>(
          value: country.id,
          child: Text(country.name ?? "-"),
        ),
      ),
    ];
  }

  List<DropdownMenuItem<int?>> _buildLanguageItems() {
    final List<Language> languages = List<Language>.from(_languages);
    final Language? current = widget.movie?.language;

    if (current?.id != null &&
        !languages.any((language) => language.id == current!.id)) {
      languages.insert(0, current!);
    }

    return [
      const DropdownMenuItem<int?>(value: null, child: Text("No language")),
      ...languages.map(
        (language) => DropdownMenuItem<int?>(
          value: language.id,
          child: Text(language.name ?? "-"),
        ),
      ),
    ];
  }

  Widget _buildDropdownField({
    required String label,
    required int? value,
    required List<DropdownMenuItem<int?>> items,
    required String hint,
    required bool enabled,
    required void Function(int?) onChanged,
    String? Function(int?)? validator,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<int?>(
          initialValue: value,
          isExpanded: true,
          hint: Text(hint),
          style: TextStyle(color: colors.onSurface, fontSize: 14),
          items: items,
          validator: validator,
          onChanged: (enabled && !_isSaving) ? onChanged : null,
        ),
      ],
    );
  }

  // A movie's genres are sent as a whole list, and the API leaves them
  // untouched when the list is missing, so there is no way to clear them once
  // set — the form keeps at least one selected instead.
  Widget _buildGenrePicker() {
    return _buildChipPicker(
      label: "Genres",
      options: _genres.map((genre) => (id: genre.id, name: genre.name)).toList(),
      selected: _selectedGenreIds,
      isLoading: _genresLoading,
      loadingLabel: "Loading genres...",
      validator: (value) =>
          (value == null || value.isEmpty) ? "Select at least one genre" : null,
    );
  }

  Widget _buildStudioPicker() {
    return _buildChipPicker(
      label: "Studios",
      options:
          _studios.map((studio) => (id: studio.id, name: studio.name)).toList(),
      selected: _selectedStudioIds,
      isLoading: _studiosLoading,
      loadingLabel: "Loading studios...",
    );
  }

  Widget _buildChipPicker({
    required String label,
    required List<({int? id, String? name})> options,
    required Set<int> selected,
    required bool isLoading,
    required String loadingLabel,
    String? Function(Set<int>?)? validator,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 6),
        FormField<Set<int>>(
          initialValue: selected,
          validator: validator,
          builder: (field) => InputDecorator(
            decoration: InputDecoration(
              errorText: field.errorText,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            child: isLoading
                ? Text(
                    loadingLabel,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: options.map((option) {
                      final int? id = option.id;
                      final bool isSelected =
                          id != null && selected.contains(id);

                      return FilterChip(
                        label: Text(option.name ?? "-"),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: colors.primary.withValues(alpha: 0.12),
                        side: BorderSide(
                          color: isSelected ? colors.primary : colors.outline,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? colors.primary : colors.onSurface,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        onSelected: (id == null || _isSaving)
                            ? null
                            : (value) {
                                setState(() {
                                  if (value) {
                                    selected.add(id);
                                  } else {
                                    selected.remove(id);
                                  }
                                });
                                field.didChange(selected);
                              },
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  // Director and cast are the same thing to the API — a credit row per person,
  // told apart by their role — so they are edited side by side.
  Widget _buildCastAndCrew() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cast & crew",
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _buildDirectorPicker(),
        if (_editsRequestedDirector) ...[
          const SizedBox(height: 16),
          _buildRequestedDirectorFields(),
        ],
        const SizedBox(height: 16),
        _buildFieldLabel("Cast"),
        const SizedBox(height: 6),
        FormField<int>(
          // Rebuilt on every change so the validator sees the current rows.
          initialValue: _castRows.length,
          validator: (_) => _castValidator(),
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_castRows.isEmpty)
                Text(
                  "No cast members assigned yet.",
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              for (int i = 0; i < _castRows.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _buildCastRow(i, field),
              ],
              if (field.errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  field.errorText!,
                  style: TextStyle(color: colors.error, fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: (_isSaving || _castMembersLoading)
                    ? null
                    : () {
                        setState(() {
                          _castRows.add(_registerRow(_CastCreditRow()));
                        });
                        field.didChange(_castRows.length);
                      },
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  _castMembersLoading
                      ? "Loading cast members..."
                      : "Add a cast member",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmissionBanner() {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final MovieRequest request = widget.request!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fact_check_outlined, size: 22, color: colors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Submitted by ${request.requestedByUser?.username ?? "-"} "
                  "on ${formatDate(request.createdAt)}",
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Everything below is what they sent in, and only partially "
                  "correct by design. Approving saves these fields onto the "
                  "movie the catalogue gets.",
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestedDirectorFields() {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final CastMember director = widget.request!.requestedDirector!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New cast member",
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "\"${director.fullName ?? "-"}\" matched nobody in the catalogue, "
            "so the submission created them. Fill them in, or pick an existing "
            "director above and they are dropped with the credit.",
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageInput(
                label: "Photo",
                helperText: "JPG, PNG, GIF or WEBP, up to 5 MB.",
                placeholderIcon: Icons.person_outline,
                enabled: !_isSaving,
                size: 132,
                onChanged: (image) => _directorPhoto = image,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "First name",
                            controller: _directorFirstNameController,
                            validator: (value) =>
                                requiredValidator(value) ??
                                maxLengthValidator(
                                    value, _directorNameMaxLength),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: "Last name",
                            controller: _directorLastNameController,
                            validator: (value) =>
                                maxLengthValidator(value, _directorNameMaxLength),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: "Nationality",
                            value: _directorCountryId,
                            items: _buildCountryItems(
                              director.country,
                              emptyLabel: "Leave as it is",
                            ),
                            hint: _countriesLoading
                                ? "Loading countries..."
                                : "Optional",
                            enabled: !_countriesLoading,
                            onChanged: (value) =>
                                setState(() => _directorCountryId = value),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateField(
                            label: "Birth date",
                            value: _directorBirthDate,
                            maxDate: DateTime.now(),
                            onChanged: (date) =>
                                setState(() => _directorBirthDate = date),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Biography",
            hint: "Optional",
            controller: _directorBiographyController,
            maxLines: 3,
            validator: (_) => null,
          ),
        ],
      ),
    );
  }

  Widget _buildDirectorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Director"),
        const SizedBox(height: 6),
        SizedBox(
          height: 52,
          child: _buildCastMemberMenu(
            controller: _directorNameController,
            focusNode: _directorFocusNode,
            selectedId: _directorId,
            emptyLabel: "No director",
            hintText: "Search by name...",
            onSelected: (id) => setState(() => _directorId = id),
          ),
        ),
      ],
    );
  }

  Widget _buildCastRow(int index, FormFieldState<int> field) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final _CastCreditRow row = _castRows[index];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 32,
          child: SizedBox(
            height: 52,
            child: _buildCastMemberMenu(
              controller: row.nameController,
              focusNode: row.focusNode,
              selectedId: row.castMemberId,
              emptyLabel: "No one selected",
              hintText: "Search by name...",
              onSelected: (id) {
                setState(() => row.castMemberId = id);
                field.didChange(_castRows.length);
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 32,
          child: TextFormField(
            controller: row.characterController,
            enabled: !_isSaving,
            style: TextStyle(color: colors.onSurface, fontSize: 14),
            decoration: const InputDecoration(hintText: "Character (optional)"),
            validator: (value) =>
                maxLengthValidator(value, _characterNameMaxLength),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          color: colors.error,
          tooltip: "Remove this cast member",
          onPressed: _isSaving
              ? null
              : () {
                  late final _CastCreditRow removed;
                  setState(() {
                    removed = _castRows.removeAt(index);
                  });
                  field.didChange(_castRows.length);

                  // The row's fields are still mounted for the rest of this
                  // frame, so its controllers outlive it by one.
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => removed.dispose(),
                  );
                },
        ),
      ],
    );
  }

  Widget _buildCastMemberMenu({
    required TextEditingController controller,
    required FocusNode focusNode,
    required int? selectedId,
    required String emptyLabel,
    required String hintText,
    required void Function(int?) onSelected,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return DropdownMenu<int?>(
      controller: controller,
      focusNode: focusNode,
      initialSelection: selectedId,
      enabled: !_castMembersLoading && !_isSaving,
      expandedInsets: EdgeInsets.zero,
      enableFilter: true,
      requestFocusOnTap: true,
      menuHeight: 320,
      hintText: _castMembersLoading ? "Loading cast members..." : hintText,
      textStyle: TextStyle(color: colors.onSurface, fontSize: 14),
      trailingIcon: Icon(Icons.expand_more, color: colors.onSurfaceVariant),
      selectedTrailingIcon: Icon(Icons.expand_less, color: colors.onSurfaceVariant),
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colors.surfaceContainerLowest),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      dropdownMenuEntries: [
        DropdownMenuEntry<int?>(
          value: null,
          label: emptyLabel,
          style: MenuItemButton.styleFrom(
            foregroundColor: colors.onSurfaceVariant,
          ),
        ),
        ..._castMembers.map(
          (member) => DropdownMenuEntry<int?>(
            value: member.id,
            label: member.fullName ?? "-",
          ),
        ),
      ],
      onSelected: onSelected,
    );
  }

  /// The menu leaves whatever was typed in the field, so on focus loss the text
  /// is snapped back to whoever is actually selected.
  _CastCreditRow _registerRow(_CastCreditRow row) {
    row.focusNode.addListener(
      () => _syncMenuText(row.focusNode, row.nameController, row.castMemberId),
    );

    return row;
  }

  void _syncMenuText(
    FocusNode focusNode,
    TextEditingController controller,
    int? selectedId,
  ) {
    if (focusNode.hasFocus) return;

    final String text = _castMemberName(selectedId) ?? "";

    if (controller.text != text) controller.text = text;
  }

  // Falls back to the name the movie was loaded with, for someone who is not on
  // the page of cast members the dropdown pulled.
  String? _castMemberName(int? id) {
    if (id == null) return null;

    for (final CastMember member in _castMembers) {
      if (member.id == id) return member.fullName;
    }

    return _knownCastNames[id];
  }

  String? _castValidator() {
    final List<int> ids = <int>[];

    for (final _CastCreditRow row in _castRows) {
      final int? id = row.castMemberId;

      if (id == null) return "Every cast row needs a cast member selected";
      if (ids.contains(id)) {
        return "${_castMemberName(id) ?? "That cast member"} is listed twice";
      }

      ids.add(id);
    }

    return null;
  }

  Widget _buildEnabledSwitch() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Switch(
          value: _isEnabled,
          onChanged:
              _isSaving ? null : (value) => setState(() => _isEnabled = value),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isReview ? "Publish on approval" : "Enabled",
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _isReview
                  ? "Turn this off to approve the movie into the catalogue but "
                      "keep it hidden from users for now."
                  : "Disabled movies stay in the catalogue but are hidden from users.",
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  // Mirrors `MovieInsertRequestValidator`: the duration is optional, but has to
  // be a whole number of minutes above zero when it is given.
  String? _durationValidator(String? value) {
    final String duration = value?.trim() ?? "";

    if (duration.isEmpty) return null;

    final int? minutes = int.tryParse(duration);

    if (minutes == null) return numericField;

    return minutes > 0 ? null : "The duration must be greater than 0";
  }

  String? _trailerUrlValidator(String? value) {
    final String url = value?.trim() ?? "";

    if (url.isEmpty) return null;

    final String? tooLong = maxLengthValidator(url, _trailerUrlMaxLength);
    if (tooLong != null) return tooLong;

    final Uri? uri = Uri.tryParse(url);
    final bool isWebUrl = uri != null &&
        (uri.scheme == "http" || uri.scheme == "https") &&
        uri.host.isNotEmpty;

    return isWebUrl ? null : "This field must be a valid http(s) URL";
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    final Map<String, dynamic> fields = _buildMovieFields();
    final Map<String, PickedImage> files = _buildMovieFiles();

    try {
      if (_isNewMovie) {
        await _movieProvider.insert(fields, files: files);
      } else {
        await _movieProvider.update(widget.movie!.id!, fields, files: files);
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

  Future<void> _submitReview(bool approved) async {
    if (approved && !(_formKey.currentState?.validate() ?? false)) return;

    if (!approved) {
      final String title = _titleController.text.trim();

      final bool confirmed = await confirmBox(
        context,
        "Reject submission",
        "Reject ${title.isEmpty ? "this submission" : title}? It stays out of "
            "the catalogue, and the requester cannot send it again for review.",
        confirmLabel: "Reject",
      );

      if (!confirmed || !mounted) return;
    }

    setState(() {
      _isSaving = true;
    });

    final Map<String, dynamic> fields = {
      ..._buildMovieFields(),
      "isApproved": approved,
      ..._buildRequestedDirectorFieldValues(),
    };

    final Map<String, PickedImage> files = {
      ..._buildMovieFiles(),
      if (_editsRequestedDirector && _directorPhoto != null)
        "directorPhoto": _directorPhoto!,
    };

    try {
      await _movieRequestProvider.review(
        widget.request!.id!,
        fields,
        files: files,
      );

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

  Map<String, dynamic> _buildMovieFields() {
    return {
      "title": _titleController.text.trim(),
      "description": _nullIfBlank(_descriptionController.text),
      "trailerUrl": _nullIfBlank(_trailerUrlController.text),
      "releaseDate": _releaseDate,
      "durationMinutes": _nullIfBlank(_durationController.text),
      "isEnabled": _isEnabled,
      "countryId": _selectedCountryId,
      "languageId": _selectedLanguageId,
      "genreIds": _selectedGenreIds.toList(),
      "studioIds": _selectedStudioIds.toList(),
      "credits": _buildCredits(),
    };
  }

  Map<String, PickedImage> _buildMovieFiles() {
    return {
      "moviePoster": ?_poster,
      "headerImage": ?_headerImage,
    };
  }

  Map<String, dynamic> _buildRequestedDirectorFieldValues() {
    if (!_editsRequestedDirector) return const {};

    return {
      "directorFirstName": _directorFirstNameController.text.trim(),
      "directorLastName": _directorLastNameController.text.trim(),
      "directorCountryId": _directorCountryId,
      "directorBirthDate": _directorBirthDate,
      "directorBiography": _nullIfBlank(_directorBiographyController.text),
    };
  }

  // The director is just another credit, so it goes out in the same list as the
  // cast, first and with the director role. `orderOfAppearence` follows the
  // order of the rows, which is the order the API reads them back in.
  List<Map<String, dynamic>> _buildCredits() {
    final List<Map<String, dynamic>> credits = <Map<String, dynamic>>[];

    final int? directorId = _directorId;
    if (directorId != null) {
      credits.add({
        "castMemberId": directorId,
        "role": _directorRole,
        "orderOfAppearence": 0,
      });
    }

    for (int i = 0; i < _castRows.length; i++) {
      final _CastCreditRow row = _castRows[i];
      final int? castMemberId = row.castMemberId;

      if (castMemberId == null) continue;

      credits.add({
        "castMemberId": castMemberId,
        "role": _actorRole,
        "characterName": _nullIfBlank(row.characterController.text),
        "orderOfAppearence": i,
      });
    }

    return credits;
  }

  String? _nullIfBlank(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

// One row of the cast editor: who they are, and who they played.
class _CastCreditRow {
  _CastCreditRow({
    this.castMemberId,
    String? castMemberName,
    String? characterName,
  })  : nameController = TextEditingController(text: castMemberName ?? ""),
        characterController = TextEditingController(text: characterName ?? ""),
        focusNode = FocusNode();

  int? castMemberId;
  final TextEditingController nameController;
  final TextEditingController characterController;
  final FocusNode focusNode;

  void dispose() {
    nameController.dispose();
    characterController.dispose();
    focusNode.dispose();
  }
}
