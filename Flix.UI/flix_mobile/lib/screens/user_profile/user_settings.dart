import 'package:flix_mobile/models/country.dart';
import 'package:flix_mobile/models/picked_image.dart';
import 'package:flix_mobile/models/search_result.dart';
import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/providers/country_provider.dart';
import 'package:flix_mobile/providers/user_provider.dart';
import 'package:flix_mobile/screens/user_profile/my_issue_reports.dart';
import 'package:flix_mobile/screens/user_profile/my_user_reports.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flix_mobile/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The signed in user's own account settings — the reports they have sent and
/// the form behind `PUT /User/{id}`.
class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  // Mirror `UserUpdateRequestValidator` so the form fails before a round trip.
  static const int _nameMaxLength = 50;
  static const int _emailMaxLength = 150;
  static const int _usernameMaxLength = 100;
  static const int _phoneMaxLength = 25;
  static const int _bioMaxLength = 500;

  static const int _countryPageSize = 300;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late UserProvider _userProvider;
  late CountryProvider _countryProvider;

  User? _user;
  List<Country> _countries = const [];
  int? _selectedCountryId;

  PickedImage? _profileImage;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _userProvider = context.read<UserProvider>();
    _countryProvider = context.read<CountryProvider>();

    _load();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _bioController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<dynamic> results = await Future.wait([
        _userProvider.getCurrentUserProfile(),
        _countryProvider.get(
          filter: {"page": 1, "pageSize": _countryPageSize},
        ),
      ]);

      if (!mounted) return;

      final User user = results[0] as User;
      final List<Country> countries = _sortedCountries(
        results[1] as SearchResult<Country>,
      );

      setState(() {
        _user = user;
        _countries = countries;
        _selectedCountryId = user.country?.id;
        _isLoading = false;
      });

      _firstNameController.text = user.firstName ?? "";
      _lastNameController.text = user.lastName ?? "";
      _usernameController.text = user.username ?? "";
      _emailController.text = user.email ?? "";
      _phoneNumberController.text = user.phoneNumber ?? "";
      _bioController.text = user.bio ?? "";
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = errorText(e);
      });
    }
  }

  List<Country> _sortedCountries(SearchResult<Country> result) {
    final List<Country> countries = itemsOf(result);

    countries.sort(
      (a, b) =>
          (a.name ?? "").toLowerCase().compareTo((b.name ?? "").toLowerCase()),
    );

    return countries;
  }

  Future<void> _save() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) return;

    final int? userId = _user?.id;
    if (userId == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      await _userProvider.update(
        userId,
        {
          "firstName": _firstNameController.text.trim(),
          "lastName": _lastNameController.text.trim(),
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
          "phoneNumber": _nullIfBlank(_phoneNumberController.text),
          "bio": _nullIfBlank(_bioController.text),
          "countryId": _selectedCountryId,
          // An empty password field means "keep the current one" — the API
          // only rehashes a password it was actually sent.
          "password": _nullIfBlank(_passwordController.text),
        },
        files: {"profileImage": ?_profileImage},
      );

      if (!mounted) return;

      navigator.pop(true);
      messenger.showSnackBar(const SnackBar(content: Text("Profile updated.")));
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);
      messenger.showSnackBar(SnackBar(content: Text(errorText(e))));
    }
  }

  String? _nullIfBlank(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(top: false, child: _buildBody()),
    );
  }

  Widget _buildBody() {
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

    return SingleChildScrollView(
      // Keeps the fields off the keyboard instead of overflowing behind it.
      padding: EdgeInsets.fromLTRB(
        16,
        14,
        16,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLinkTile(
            icon: Icons.flag_outlined,
            label: "My movie reports",
            subtitle: "Issues you reported on movies",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyIssueReports()),
            ),
          ),
          const SizedBox(height: 10),
          _buildLinkTile(
            icon: Icons.person_off_outlined,
            label: "My user reports",
            subtitle: "Reports you made on other users",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyUserReports()),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          _buildForm(),
        ],
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      color: colors.surfaceContainerLow,
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          label,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _isSaving ? null : onTap,
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ImageInput(
            currentImageUrl: _user?.profileImage,
            helperText: "Tap to change your profile photo",
            enabled: !_isSaving,
            onChanged: (image) => _profileImage = image,
          ),
          const SizedBox(height: 20),
          _buildLabel("Account"),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildField(
                  controller: _firstNameController,
                  hint: "First name",
                  icon: Icons.badge_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      requiredValidator(value, "First name") ??
                      maxLengthValidator(value, _nameMaxLength, "First name"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  controller: _lastNameController,
                  hint: "Last name",
                  icon: Icons.badge_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      requiredValidator(value, "Last name") ??
                      maxLengthValidator(value, _nameMaxLength, "Last name"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _usernameController,
            hint: "Username",
            icon: Icons.person_outline,
            validator: (value) =>
                requiredValidator(value, "Username") ??
                maxLengthValidator(value, _usernameMaxLength, "Username"),
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _emailController,
            hint: "Email",
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                emailValidator(value, maxLength: _emailMaxLength),
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _phoneNumberController,
            hint: "Phone number (optional)",
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) =>
                maxLengthValidator(value, _phoneMaxLength, "Phone number"),
          ),
          const SizedBox(height: 20),
          _buildLabel("Profile"),
          const SizedBox(height: 10),
          _buildCountryPicker(),
          const SizedBox(height: 14),
          _buildBio(),
          const SizedBox(height: 20),
          _buildLabel("Password"),
          const SizedBox(height: 4),
          _buildHint("Leave both fields empty to keep your current password."),
          const SizedBox(height: 10),
          _buildField(
            controller: _passwordController,
            hint: "New password",
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: _buildVisibilityToggle(
              obscured: _obscurePassword,
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: _newPasswordValidator,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _confirmPasswordController,
            hint: "Confirm new password",
            icon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            suffixIcon: _buildVisibilityToggle(
              obscured: _obscureConfirmPassword,
              onToggle: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
            validator: (value) => (value ?? "") == _passwordController.text
                ? null
                : "Passwords do not match",
          ),
          const SizedBox(height: 24),
          _buildSave(),
        ],
      ),
    );
  }

  // The API keeps the stored password when the request leaves it out, so an
  // empty field is valid here — anything typed is held to the insert rules.
  String? _newPasswordValidator(String? value) =>
      (value == null || value.isEmpty) ? null : passwordValidator(value);

  Widget _buildLabel(String label) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: colors.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildHint(String hint) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Text(
      hint,
      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
    );
  }

  Widget _buildCountryPicker() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return DropdownButtonFormField<int?>(
      initialValue: _selectedCountryId,
      isExpanded: true,
      menuMaxHeight: 340,
      borderRadius: BorderRadius.circular(12),
      dropdownColor: colors.surfaceContainerHigh,
      style: TextStyle(color: colors.onSurface, fontSize: 15),
      decoration: const InputDecoration(
        hintText: "Country",
        prefixIcon: Icon(Icons.public_outlined),
      ),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text("No country")),
        ..._countries.map(
          (country) => DropdownMenuItem<int?>(
            value: country.id,
            child: Text(country.name ?? "-", overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: _isSaving
          ? null
          : (countryId) => setState(() => _selectedCountryId = countryId),
    );
  }

  Widget _buildBio() {
    return TextFormField(
      controller: _bioController,
      enabled: !_isSaving,
      minLines: 4,
      maxLines: 8,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      decoration: const InputDecoration(
        hintText: "Bio (optional)",
        errorMaxLines: 2,
      ),
      validator: (value) => maxLengthValidator(value, _bioMaxLength, "Bio"),
    );
  }

  Widget _buildSave() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        child: _isSaving
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.onPrimary,
                ),
              )
            : const Text("Save changes"),
      ),
    );
  }

  Widget _buildVisibilityToggle({
    required bool obscured,
    required VoidCallback onToggle,
  }) {
    return IconButton(
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
      onPressed: onToggle,
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isSaving,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      autocorrect: false,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        errorMaxLines: 2,
      ),
    );
  }
}
