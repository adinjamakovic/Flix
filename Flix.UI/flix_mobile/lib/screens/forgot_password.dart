import 'package:flix_mobile/providers/auth_provider.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

enum _ResetStep { email, code, password }

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

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

          const SafeArea(child: _ForgotPasswordForm()),
        ],
      ),
    );
  }
}

class _ForgotPasswordForm extends StatefulWidget {
  const _ForgotPasswordForm();

  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  static const int _codeLength = 6;
  static const int _emailMaxLength = 150;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  _ResetStep _step = _ResetStep.email;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading || !(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    // The last step pops this screen, so the messenger that carries the
    // confirmation has to be read before the route goes away.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final email = _emailController.text.trim();

    try {
      switch (_step) {
        case _ResetStep.email:
          await authProvider.requestPasswordReset(email);
          if (!mounted) return;
          setState(() => _step = _ResetStep.code);
          showSnack(
            context,
            'If that email belongs to an account, a code is on its way. '
            'It is valid for 15 minutes.',
          );
        case _ResetStep.code:
          await authProvider.verifyResetToken(
            email,
            _codeController.text.trim(),
          );
          if (!mounted) return;
          setState(() => _step = _ResetStep.password);
        case _ResetStep.password:
          await authProvider.resetPassword(
            email,
            _codeController.text.trim(),
            _passwordController.text,
          );
          if (!mounted) return;
          navigator.pop();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Password changed. Sign in with the new one.'),
            ),
          );
      }
    } on Exception catch (e) {
      if (!mounted) return;
      showSnack(context, errorText(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Asking for a new code drops back to the first step rather than resending
  // silently: the server replaces any outstanding code, so the one already in
  // the mailbox stops working and the user has to be told which to use.
  void _startOver(_ResetStep step) {
    if (_isLoading) return;

    setState(() {
      _step = step;
      _codeController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  String? _codeValidator(String? value) {
    final code = value?.trim() ?? '';

    if (code.isEmpty) return 'The code is required';

    return code.length == _codeLength && int.tryParse(code) != null
        ? null
        : 'The code is $_codeLength digits';
  }

  String? _confirmPasswordValidator(String? value) =>
      value == _passwordController.text ? null : 'The passwords do not match';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Reset password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._fields(),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.onPrimary,
                                ),
                              )
                            : Text(_action()),
                      ),
                    ),
                    ..._secondaryActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _subtitle() => switch (_step) {
    _ResetStep.email =>
      'Enter the email on your account and we will send you a code.',
    _ResetStep.code =>
      'Enter the $_codeLength digit code sent to '
          '${_emailController.text.trim()}.',
    _ResetStep.password => 'Choose the password you will sign in with.',
  };

  String _action() => switch (_step) {
    _ResetStep.email => 'Send code',
    _ResetStep.code => 'Verify code',
    _ResetStep.password => 'Set new password',
  };

  List<Widget> _fields() => switch (_step) {
    _ResetStep.email => [
      TextFormField(
        controller: _emailController,
        enabled: !_isLoading,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        autocorrect: false,
        onFieldSubmitted: (_) => _submit(),
        decoration: const InputDecoration(
          hintText: 'Email',
          prefixIcon: Icon(Icons.mail_outline),
        ),
        validator: (value) =>
            emailValidator(value, maxLength: _emailMaxLength),
      ),
    ],
    _ResetStep.code => [
      TextFormField(
        controller: _codeController,
        enabled: !_isLoading,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        maxLength: _codeLength,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 22, letterSpacing: 8),
        onFieldSubmitted: (_) => _submit(),
        decoration: const InputDecoration(
          hintText: 'Code',
          counterText: '',
          prefixIcon: Icon(Icons.pin_outlined),
        ),
        validator: _codeValidator,
      ),
    ],
    _ResetStep.password => [
      TextFormField(
        controller: _passwordController,
        enabled: !_isLoading,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: 'New password',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        validator: passwordValidator,
      ),
      const SizedBox(height: 14),
      TextFormField(
        controller: _confirmPasswordController,
        enabled: !_isLoading,
        obscureText: _obscureConfirmPassword,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: 'Confirm new password',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
          ),
        ),
        validator: _confirmPasswordValidator,
      ),
    ],
  };

  List<Widget> _secondaryActions() => switch (_step) {
    _ResetStep.email => const [],
    _ResetStep.code => [
      TextButton(
        onPressed: _isLoading ? null : () => _startOver(_ResetStep.email),
        child: const Text('Send a new code'),
      ),
    ],
    _ResetStep.password => [
      TextButton(
        onPressed: _isLoading ? null : () => _startOver(_ResetStep.code),
        child: const Text('Enter a different code'),
      ),
    ],
  };
}
