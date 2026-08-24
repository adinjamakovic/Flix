import 'package:flix_desktop/models/picked_image.dart';
import 'package:flix_desktop/models/studio.dart';
import 'package:flix_desktop/providers/studio_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flix_desktop/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudioDetails extends StatefulWidget {
  const StudioDetails({super.key, this.studio});

  final Studio? studio;

  @override
  State<StudioDetails> createState() => _StudioDetailsState();
}

class _StudioDetailsState extends State<StudioDetails> {
  static const int _nameMaxLength = 100;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late StudioProvider _studioProvider;

  PickedImage? _logo;
  bool _isSaving = false;

  bool get _isNewStudio => widget.studio?.id == null;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.studio?.name ?? "";
    _descriptionController.text = widget.studio?.description ?? "";

    _studioProvider = context.read<StudioProvider>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNewStudio
              ? "New Studio"
              : "Update studio: ${widget.studio!.name ?? "-"}",
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
                label: "Logo",
                helperText: "JPG, PNG, GIF or WEBP, up to 5 MB.",
                placeholderIcon: Icons.business_outlined,
                shape: ImageInputShape.rectangle,
                currentImageUrl: widget.studio?.logo,
                enabled: !_isSaving,
                onChanged: (image) => _logo = image,
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
                      label: "Description",
                      hint: "Optional",
                      controller: _descriptionController,
                      maxLines: 5,
                      validator: (value) => null,
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
                    : Text(_isNewStudio ? "Create studio" : "Save changes"),
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
    int maxLines = 1,
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
          maxLines: maxLines,
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
      "description": _nullIfBlank(_descriptionController.text),
    };

    final Map<String, PickedImage> files = {"logo": ?_logo};

    try {
      if (_isNewStudio) {
        await _studioProvider.insert(fields, files: files);
      } else {
        await _studioProvider.update(widget.studio!.id!, fields, files: files);
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
