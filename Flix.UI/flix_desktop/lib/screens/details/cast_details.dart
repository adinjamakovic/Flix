import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flix_desktop/enums/cast_role.dart';
import 'package:flix_desktop/models/cast_member.dart';
import 'package:flix_desktop/models/country.dart';
import 'package:flix_desktop/models/picked_image.dart';
import 'package:flix_desktop/providers/cast_provider.dart';
import 'package:flix_desktop/providers/country_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CastDetails extends StatefulWidget {
  const CastDetails({super.key, this.cast});

  final CastMember? cast;

  @override
  State<CastDetails> createState() => _CastDetailsState();
}

class _CastDetailsState extends State<CastDetails> {
  /// The country dropdown holds the whole list, same as the cast list filter.
  static const int _countryPageSize = 200;

  /// The `CastMember` columns are `nvarchar(50)`; the validator on the API says
  /// 100, so the column is the tighter of the two and the one worth enforcing.
  static const int _nameMaxLength = 50;

  /// Nobody in the database was born before this, and a birth date in the
  /// future is always a typo.
  static final DateTime _minSelectableDate = DateTime(1900, 1, 1);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _biographyController = TextEditingController();

  late CastProvider _castProvider;
  late CountryProvider _countryProvider;

  List<Country> _countries = List.empty();
  bool _countriesLoading = true;
  int? _selectedCountryId;

  DateTime? _birthDate;

  PickedImage? _photo;
  bool _isSaving = false;

  bool get _isNewCastMember => widget.cast?.id == null;

  @override
  void initState() {
    super.initState();

    _firstNameController.text = widget.cast?.firstName ?? "";
    _lastNameController.text = widget.cast?.lastName ?? "";
    _biographyController.text = widget.cast?.biography ?? "";
    _selectedCountryId = widget.cast?.country?.id;
    _birthDate = widget.cast?.birthDate;

    _castProvider = context.read<CastProvider>();
    _countryProvider = context.read<CountryProvider>();

    _loadCountries();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _biographyController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    try {
      final data = await _countryProvider.get(
        filter: {"page": 1, "pageSize": _countryPageSize},
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNewCastMember
              ? "New Cast Member"
              : "Update cast member: ${widget.cast!.fullName ?? "-"}",
        ),
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
                label: "Photo",
                helperText: "JPG, PNG, GIF or WEBP, up to 5 MB.",
                placeholderIcon: Icons.person_outline,
                currentImageUrl: widget.cast?.photo,
                enabled: !_isSaving,
                onChanged: (image) => _photo = image,
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "First name",
                            controller: _firstNameController,
                            validator: (value) =>
                                requiredValidator(value) ??
                                maxLengthValidator(value, _nameMaxLength),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: "Last name",
                            controller: _lastNameController,
                            validator: (value) =>
                                requiredValidator(value) ??
                                maxLengthValidator(value, _nameMaxLength),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildCountryPicker()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildBirthDateField()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRoles(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Biography",
            hint: "Optional",
            controller: _biographyController,
            maxLines: 5,
            validator: (value) => null,
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
                    : Text(
                        _isNewCastMember ? "Create cast member" : "Save changes",
                      ),
              ),
            ],
          ),
        ],
      ),
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

  List<DropdownMenuItem<int?>> _buildCountryItems() {
    final List<Country> countries = List<Country>.from(_countries);
    final Country? current = widget.cast?.country;

    if (current?.id != null &&
        !countries.any((country) => country.id == current!.id)) {
      countries.insert(0, current!);
    }

    return countries
        .map(
          (country) => DropdownMenuItem<int?>(
            value: country.id,
            child: Text(country.name ?? "-"),
          ),
        )
        .toList();
  }

  Widget _buildCountryPicker() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Nationality"),
        const SizedBox(height: 6),
        DropdownButtonFormField<int?>(
          initialValue: _selectedCountryId,
          isExpanded: true,
          hint: Text(
            _countriesLoading ? "Loading countries..." : "Select a country",
          ),
          style: TextStyle(color: colors.onSurface, fontSize: 14),
          items: _buildCountryItems(),
          validator: (value) => value == null ? mField : null,
          onChanged: (_countriesLoading || _isSaving)
              ? null
              : (value) => setState(() => _selectedCountryId = value),
        ),
      ],
    );
  }

  Widget _buildBirthDateField() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Birth date"),
        const SizedBox(height: 6),
        InkWell(
          onTap: _isSaving ? null : _pickBirthDate,
          child: InputDecorator(
            decoration: InputDecoration(
              // The date is optional, so the field carries its own clear button
              // rather than leaving a wrong pick stuck on the record.
              suffixIcon: _birthDate == null
                  ? Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: colors.onSurfaceVariant,
                    )
                  : IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: colors.onSurfaceVariant,
                      tooltip: "Clear birth date",
                      onPressed: _isSaving
                          ? null
                          : () => setState(() => _birthDate = null),
                    ),
            ),
            child: Text(
              _birthDate == null ? "Optional" : formatDate(_birthDate),
              style: TextStyle(
                color: _birthDate == null
                    ? colors.onSurfaceVariant
                    : colors.onSurface,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickBirthDate() async {
    final DateTime today = DateUtils.dateOnly(DateTime.now());

    final DateTime? picked = await showDatePickerDialog(
      context: context,
      minDate: _minSelectableDate,
      maxDate: today,
      selectedDate: _birthDate,
      // Opening on today's month to pick a birth date means paging back decades,
      // so an empty field starts the calendar on a plausible year instead.
      initialPickerType: _birthDate == null
          ? PickerType.years
          : PickerType.days,
    );

    if (picked == null || !mounted) return;

    setState(() {
      _birthDate = picked;
    });
  }

  /// Roles come from the movie credits, not from the cast member itself, so
  /// they are shown for context but edited on the movie.
  Widget _buildRoles() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final List<String> roles = (widget.cast?.roles ?? const <CastRole?>[])
        .where((role) => role != null)
        .map((role) => getRoleName(role!))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Roles"),
        const SizedBox(height: 6),
        Text(
          roles.isEmpty
              ? "No credits yet — roles are assigned when the cast member is added to a movie."
              : roles.join(", "),
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
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
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "countryId": _selectedCountryId,
      "birthDate": _birthDate,
      "biography": _nullIfBlank(_biographyController.text),
    };

    final Map<String, PickedImage> files = {"photo": ?_photo};

    try {
      if (_isNewCastMember) {
        await _castProvider.insert(fields, files: files);
      } else {
        await _castProvider.update(widget.cast!.id!, fields, files: files);
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
