import 'package:flix_desktop/models/language.dart';
import 'package:flix_desktop/providers/language_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageDetails extends StatefulWidget {
  const LanguageDetails({super.key, this.language});

  final Language? language;

  @override
  State<LanguageDetails> createState() => _LanguageDetailsState();
}

class _LanguageDetailsState extends State<LanguageDetails> {
  static const int _nameMaxLength = 60;
  static const int _codeMaxLength = 5;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  late LanguageProvider _languageProvider;

  bool _isSaving = false;

  bool get _isNewLanguage => widget.language?.id == null;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.language?.name ?? "";
    _codeController.text = widget.language?.code ?? "";

    _languageProvider = context.read<LanguageProvider>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNewLanguage
              ? "New Language"
              : "Update language: ${widget.language!.name ?? "-"}",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
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
              Expanded(
                flex: 3,
                child: _buildTextField(
                  label: "Name",
                  controller: _nameController,
                  validator: (value) =>
                      requiredValidator(value) ??
                      maxLengthValidator(value, _nameMaxLength),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  label: "Code",
                  hint: "Optional, e.g. en",
                  controller: _codeController,
                  validator: (value) =>
                      maxLengthValidator(value, _codeMaxLength),
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
                    : Text(_isNewLanguage ? "Create language" : "Save changes"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    String? hint,
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
      "code": _nullIfBlank(_codeController.text),
    };

    try {
      if (_isNewLanguage) {
        await _languageProvider.insertJson(fields);
      } else {
        await _languageProvider.updateJson(widget.language!.id!, fields);
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
