import 'package:flix_mobile/models/picked_image.dart';
import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/screens/login.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flix_mobile/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/login.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.15, 0.3, 1.0],
                colors: [
                  Colors.transparent,
                  colors.surface.withValues(alpha: 0.6),
                  colors.surface.withValues(alpha: 0.8),
                  colors.surface,
                ],
              ),
            ),
          ),

          const SafeArea(child: _RegisterForm()),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  // Mirror `UserInsertRequestValidator` so the form fails before a round trip.
  // The rules themselves live in `utils_widget.dart`; these are the lengths only
  // this form has fields for.
  static const int _nameMaxLength = 50;
  static const int _emailMaxLength = 150;
  static const int _usernameMaxLength = 100;
  static const int _phoneMaxLength = 25;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  PickedImage? _profileImage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isLoading || !(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.register(
        {
          "firstName": _firstNameController.text.trim(),
          "lastName": _lastNameController.text.trim(),
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
          "phoneNumber": _nullIfBlank(_phoneNumberController.text),
          "password": _passwordController.text,
        },
        files: {"profileImage": ?_profileImage},
      );

      if (!mounted) return;

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => route.isFirst,
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Account created. Sign in to continue.')),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(errorText(e))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _nullIfBlank(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        // Keeps the card off the keyboard instead of overflowing behind it.
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            color: colors.surfaceContainerLow.withValues(alpha: 0.92),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colors.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'FLIX',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ImageInput(
                      helperText: 'Add a profile photo (optional)',
                      enabled: !_isLoading,
                      onChanged: (image) => _profileImage = image,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _firstNameController,
                            hint: 'First name',
                            icon: Icons.badge_outlined,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) =>
                                requiredValidator(value, 'First name') ??
                                maxLengthValidator(
                                  value,
                                  _nameMaxLength,
                                  'First name',
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _lastNameController,
                            hint: 'Last name',
                            icon: Icons.badge_outlined,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) =>
                                requiredValidator(value, 'Last name') ??
                                maxLengthValidator(
                                  value,
                                  _nameMaxLength,
                                  'Last name',
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _usernameController,
                      hint: 'Username',
                      icon: Icons.person_outline,
                      validator: (value) =>
                          requiredValidator(value, 'Username') ??
                          maxLengthValidator(
                            value,
                            _usernameMaxLength,
                            'Username',
                          ),
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _emailController,
                      hint: 'Email',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          emailValidator(value, maxLength: _emailMaxLength),
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _phoneNumberController,
                      hint: 'Phone number (optional)',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) => maxLengthValidator(
                        value,
                        _phoneMaxLength,
                        'Phone number',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: _buildVisibilityToggle(
                        obscured: _obscurePassword,
                        onToggle: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: passwordValidator,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _confirmPasswordController,
                      hint: 'Confirm password',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _register(),
                      suffixIcon: _buildVisibilityToggle(
                        obscured: _obscureConfirmPassword,
                        onToggle: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                      validator: (value) => value == _passwordController.text
                          ? null
                          : 'Passwords do not match',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.onPrimary,
                                ),
                              )
                            : const Text('Register'),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Already have an account? Log in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
      enabled: !_isLoading,
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
