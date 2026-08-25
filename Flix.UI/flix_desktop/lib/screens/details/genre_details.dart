import 'package:flix_desktop/models/genre.dart';
import 'package:flix_desktop/providers/genre_provider.dart';
import 'package:flix_desktop/utils/utils_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GenreDetails extends StatefulWidget {
  const GenreDetails({super.key, this.genre});

  final Genre? genre;

  @override
  State<GenreDetails> createState() => _GenreDetailsState();
}

class _GenreDetailsState extends State<GenreDetails> {
  static const int _nameMaxLength = 50;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  late GenreProvider _genreProvider;

  bool _isSaving = false;

  bool get _isNewGenre => widget.genre?.id == null;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.genre?.name ?? "";

    _genreProvider = context.read<GenreProvider>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNewGenre
              ? "New Genre"
              : "Update genre: ${widget.genre!.name ?? "-"}",
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
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Name",
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            enabled: !_isSaving,
            validator: (value) =>
                requiredValidator(value) ??
                maxLengthValidator(value, _nameMaxLength),
            style: TextStyle(color: colors.onSurface, fontSize: 14),
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
                    : Text(_isNewGenre ? "Create genre" : "Save changes"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    final Map<String, dynamic> fields = {"name": _nameController.text.trim()};

    try {
      if (_isNewGenre) {
        await _genreProvider.insertJson(fields);
      } else {
        await _genreProvider.updateJson(widget.genre!.id!, fields);
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
}
