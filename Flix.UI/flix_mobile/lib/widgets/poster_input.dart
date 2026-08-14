import 'package:flix_mobile/models/picked_image.dart';
import 'package:flix_mobile/widgets/image_input.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PosterInput extends StatefulWidget {
  const PosterInput({
    super.key,
    required this.onChanged,
    this.label = 'Movie poster',
    this.enabled = true,
  });

  final void Function(PickedImage? image) onChanged;
  final String label;
  final bool enabled;

  @override
  State<PosterInput> createState() => _PosterInputState();
}

class _PosterInputState extends State<PosterInput> {
  static const double _emptyHeight = 176;
  static const double _previewHeight = 168;

  // A poster is 2:3, so the preview follows it.
  static const double _previewWidth = _previewHeight * 2 / 3;

  PickedImage? _picked;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: _picked == null ? _emptyHeight : 0),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_picked != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _picked!.bytes,
                width: _previewWidth,
                height: _previewHeight,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.enabled ? _openSourceSheet : null,
            style: TextButton.styleFrom(
              backgroundColor: colors.tertiary,
              foregroundColor: colors.onTertiary,
              disabledBackgroundColor: colors.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(_picked == null ? 'Select' : 'Change'),
          ),
          if (_picked != null)
            TextButton(
              onPressed: widget.enabled ? _clear : null,
              child: const Text('Remove poster'),
            ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.error, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openSourceSheet() async {
    final ImagePickAction? action = await showImageSourceSheet(
      context,
      canRemove: _picked != null,
      removeLabel: 'Remove poster',
    );

    if (action == null) return;

    if (action == ImagePickAction.remove) {
      _clear();
      return;
    }

    final ImagePickResult result = await pickImage(
      action == ImagePickAction.camera
          ? ImageSource.camera
          : ImageSource.gallery,
    );

    if (!mounted || result.isCancelled) return;

    if (result.error != null) {
      setState(() => _error = result.error);
      return;
    }

    setState(() {
      _picked = result.image;
      _error = null;
    });
    widget.onChanged(result.image);
  }

  void _clear() {
    setState(() {
      _picked = null;
      _error = null;
    });
    widget.onChanged(null);
  }
}
