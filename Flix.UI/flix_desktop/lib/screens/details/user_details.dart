import 'package:flix_desktop/models/country.dart';
import 'package:flix_desktop/models/picked_image.dart';
import 'package:flix_desktop/models/role.dart';
import 'package:flix_desktop/models/user.dart';
import 'package:flix_desktop/providers/country_provider.dart';
import 'package:flix_desktop/providers/role_provider.dart';
import 'package:flix_desktop/providers/user_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserDetails extends StatefulWidget {
  const UserDetails({super.key, this.user});

  final User? user;

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  /// The country dropdown holds the whole list, same as the user list filter.
  static const int _countryPageSize = 200;

  static const int _nameMaxLength = 50;
  static const int _emailMaxLength = 150;
  static const int _usernameMaxLength = 100;
  static const int _phoneMaxLength = 25;
  static const int _bioMaxLength = 500;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static const int _rolePageSize = 50;

  static const String _defaultRoleName = "User";

  late UserProvider _userProvider;
  late CountryProvider _countryProvider;
  late RoleProvider _roleProvider;

  List<Country> _countries = List.empty();
  bool _countriesLoading = true;
  int? _selectedCountryId;

  List<Role> _roles = List.empty();
  bool _rolesLoading = true;
  int? _selectedRoleId;

  PickedImage? _profileImage;
  bool _isSaving = false;

  bool get _isNewUser => widget.user?.id == null;

  @override
  void initState() {
    super.initState();

    _firstNameController.text = widget.user?.firstName ?? "";
    _lastNameController.text = widget.user?.lastName ?? "";
    _emailController.text = widget.user?.email ?? "";
    _usernameController.text = widget.user?.username ?? "";
    _phoneNumberController.text = widget.user?.phoneNumber ?? "";
    _bioController.text = widget.user?.bio ?? "";
    _selectedCountryId = widget.user?.country?.id;
    _selectedRoleId = widget.user?.roleId;

    _userProvider = context.read<UserProvider>();
    _countryProvider = context.read<CountryProvider>();
    _roleProvider = context.read<RoleProvider>();

    _loadCountries();
    _loadRoles();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _bioController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _loadRoles() async {
    try {
      final data = await _roleProvider.get(
        filter: {"page": 1, "pageSize": _rolePageSize, "isActive": true},
      );

      if (!mounted) return;

      setState(() {
        _roles = data.items ?? List.empty();
        _rolesLoading = false;
        if (_isNewUser) {
          _selectedRoleId ??= _roles
              .where((role) => role.name == _defaultRoleName)
              .map((role) => role.id)
              .firstOrNull;
        }
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _rolesLoading = false;
      });
      alertBox(context, "Error", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNewUser ? "New User" : "Update user: ${widget.user!.username}",
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
                label: "Profile image",
                helperText: "JPG, PNG, GIF or WEBP, up to 5 MB.",
                placeholderIcon: Icons.person_outline,
                currentImageUrl: widget.user?.profileImage,
                enabled: !_isSaving,
                onChanged: (image) => _profileImage = image,
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
                        Expanded(
                          child: _buildTextField(
                            label: "Email",
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => emailValidator(
                              value,
                              maxLength: _emailMaxLength,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: "Username",
                            controller: _usernameController,
                            validator: (value) =>
                                requiredValidator(value) ??
                                maxLengthValidator(value, _usernameMaxLength),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "Phone number",
                            hint: "Optional",
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            validator: (value) => phoneValidator(
                              value,
                              maxLength: _phoneMaxLength,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCountryPicker()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildRolePicker()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPasswordField(
                  label: "Password",
                  helperText: _isNewUser
                      ? null
                      : "Leave blank to keep the current password.",
                  controller: _passwordController,
                  obscured: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (value) =>
                      passwordValidator(value, required: _isNewUser),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPasswordField(
                  label: "Confirm password",
                  controller: _confirmPasswordController,
                  obscured: _obscureConfirmPassword,
                  onToggle: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                  validator: (value) => value == _passwordController.text
                      ? null
                      : "Passwords do not match",
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Bio",
            hint: "Optional",
            controller: _bioController,
            maxLines: 4,
            validator: (value) => maxLengthValidator(value, _bioMaxLength),
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
                    : Text(_isNewUser ? "Create user" : "Save changes"),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscured,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    String? helperText,
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
          obscureText: obscured,
          validator: validator,
          style: TextStyle(color: colors.onSurface, fontSize: 14),
          decoration: InputDecoration(
            helperText: helperText,
            helperStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            suffixIcon: IconButton(
              icon: Icon(
                obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
              ),
              color: colors.onSurfaceVariant,
              tooltip: obscured ? "Show password" : "Hide password",
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<int?>> _buildCountryItems() {
    final List<Country> countries = List<Country>.from(_countries);
    final Country? current = widget.user?.country;

    if (current?.id != null &&
        !countries.any((country) => country.id == current!.id)) {
      countries.insert(0, current!);
    }

    return [
      const DropdownMenuItem<int?>(value: null, child: Text("No country")),
      ...countries.map(
        (country) => DropdownMenuItem<int?>(
          value: country.id,
          child: Text(country.name ?? "-"),
        ),
      ),
    ];
  }

  List<DropdownMenuItem<int?>> _buildRoleItems() {
    final List<Role> roles = List<Role>.from(_roles);
    final int? currentId = widget.user?.roleId;

    if (currentId != null && !roles.any((role) => role.id == currentId)) {
      roles.insert(0, Role(currentId, widget.user?.role, null, true));
    }

    return roles
        .map(
          (role) => DropdownMenuItem<int?>(
            value: role.id,
            child: Text(role.name ?? "-"),
          ),
        )
        .toList();
  }

  Widget _buildCountryPicker() {
    return _buildDropdownField(
      label: "Country",
      value: _selectedCountryId,
      items: _buildCountryItems(),
      hint: _countriesLoading ? "Loading countries..." : "Optional",
      enabled: !_countriesLoading,
      onChanged: (value) => setState(() => _selectedCountryId = value),
    );
  }

  Widget _buildRolePicker() {
    return _buildDropdownField(
      label: "Role",
      value: _selectedRoleId,
      items: _buildRoleItems(),
      hint: _rolesLoading ? "Loading roles..." : "Select a role",
      enabled: !_rolesLoading,
      onChanged: (value) => setState(() => _selectedRoleId = value),
      validator: (value) => value == null ? mField : null,
    );
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

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    final Map<String, dynamic> fields = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "email": _emailController.text.trim(),
      "username": _usernameController.text.trim(),
      // Blank means "keep the current password", which the API reads as an
      // omitted field. Never trimmed — the whitespace is part of the password.
      "password":
          _passwordController.text.isEmpty ? null : _passwordController.text,
      "phoneNumber": _nullIfBlank(_phoneNumberController.text),
      "bio": _nullIfBlank(_bioController.text),
      "countryId": _selectedCountryId,
      "roleId": _selectedRoleId,
    };

    final Map<String, PickedImage> files = {"profileImage": ?_profileImage};

    try {
      if (_isNewUser) {
        await _userProvider.insert(fields, files: files);
      } else {
        await _userProvider.update(widget.user!.id!, fields, files: files);
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
