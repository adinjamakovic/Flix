import 'package:flix_desktop/models/country.dart';
import 'package:flix_desktop/models/picked_image.dart';
import 'package:flix_desktop/providers/country_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CountryDetails extends StatefulWidget {
  const CountryDetails({super.key, this.country});

  final Country? country;

  @override
  State<CountryDetails> createState() => _CountryDetailsState();
}

class _CountryDetailsState extends State<CountryDetails> {
  static const int _nameMaxLength = 100;
  static const int _codeMaxLength = 5;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  late CountryProvider _countryProvider;

  PickedImage? _flag;
  bool _isSaving = false;

  bool get _isNewCountry => widget.country?.id == null;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.country?.name ?? "";
    _codeController.text = widget.country?.code ?? "";

    _countryProvider = context.read<CountryProvider>();
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
          _isNewCountry
              ? "New Country"
              : "Update country: ${widget.country!.name ?? "-"}",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
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
                label: "Flag",
                helperText: "JPG, PNG, GIF or WEBP, up to 5 MB.",
                placeholderIcon: Icons.flag_outlined,
                shape: ImageInputShape.rectangle,
                currentImageUrl: widget.country?.flagImage,
                enabled: !_isSaving,
                onChanged: (image) => _flag = image,
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
                      label: "Code",
                      hint: "Optional, e.g. BA",
                      controller: _codeController,
                      validator: (value) =>
                          maxLengthValidator(value, _codeMaxLength),
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
                    : Text(_isNewCountry ? "Create country" : "Save changes"),
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

    final Map<String, PickedImage> files = {"flagImage": ?_flag};

    try {
      if (_isNewCountry) {
        await _countryProvider.insert(fields, files: files);
      } else {
        await _countryProvider.update(widget.country!.id!, fields, files: files);
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
