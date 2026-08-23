import 'package:flix_mobile/models/user.dart';
import 'package:flix_mobile/providers/user_network_provider.dart';
import 'package:flix_mobile/utils/utils_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportUser extends StatefulWidget {
  const ReportUser({super.key, required this.user});

  final User user;

  @override
  State<ReportUser> createState() => _ReportUserState();
}

class _ReportUserState extends State<ReportUser> {
  static const String _otherHeader = "Other";

  static const int _descriptionMaxLength = 2000;

  static const double _fieldRadius = 14;

  static const double _avatarRadius = 28;

  static const List<String> _headers = [
    "Harassment or bullying",
    "Hate speech",
    "Spam or advertising",
    "Impersonation",
    "Inappropriate profile photo",
    "Inappropriate reviews or lists",
    "Deliberate spoilers",
    "Suspected bot account",
    _otherHeader,
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();

  late UserNetworkProvider _networkProvider;

  String? _selectedHeader;
  bool _isSubmitting = false;

  bool get _isOther => _selectedHeader == _otherHeader;

  @override
  void initState() {
    super.initState();

    _networkProvider = context.read<UserNetworkProvider>();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) return;

    final int? userId = widget.user.id;
    final String? header = _selectedHeader;

    if (userId == null || header == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      await _networkProvider.report(
        reportedUserId: userId,
        header: header,
        description: _nullIfBlank(_descriptionController.text),
      );

      if (!mounted) return;

      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text("Report sent. An admin will review it.")),
      );
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);
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
      appBar: AppBar(title: const Text("Report user")),
      body: SingleChildScrollView(
        // Keeps the fields off the keyboard instead of overflowing behind it.
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildReasonPicker(),
              const SizedBox(height: 14),
              _buildDescription(),
              const SizedBox(height: 20),
              Center(child: _buildSubmit()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildAvatar(
          context,
          widget.user.profileImage,
          widget.user.username,
          radius: _avatarRadius,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.username ?? "-",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Tell us what this account is doing and an admin will look "
                "into it.",
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReasonPicker() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return DropdownButtonFormField<String>(
      initialValue: _selectedHeader,
      isExpanded: true,
      menuMaxHeight: 340,
      borderRadius: BorderRadius.circular(12),
      dropdownColor: colors.surfaceContainerHigh,
      icon: Icon(Icons.menu, size: 20, color: colors.onSurfaceVariant),
      style: TextStyle(color: colors.onSurface, fontSize: 15),
      decoration: _decoration("Why are you reporting this user?"),
      items: _headers
          .map(
            (header) => DropdownMenuItem<String>(
              value: header,
              child: Text(header, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: _isSubmitting
          ? null
          : (header) => setState(() => _selectedHeader = header),
      validator: (value) =>
          value == null ? "Pick why you are reporting this user" : null,
    );
  }

  Widget _buildDescription() {
    return TextFormField(
      controller: _descriptionController,
      enabled: !_isSubmitting,
      minLines: 6,
      maxLines: 12,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      decoration: _decoration(
        _isOther ? "Describe what happened..." : "Add more detail (optional)",
      ),
      // The reason carries the report on its own, except for "Other" - there
      // the description is the only thing telling the admin what happened.
      validator: (value) =>
          (_isOther ? requiredValidator(value, "Description") : null) ??
          maxLengthValidator(value, _descriptionMaxLength, "Description"),
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
          : const Text("Submit Report"),
    );
  }

  InputDecoration _decoration(String hint) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hint,
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
}
