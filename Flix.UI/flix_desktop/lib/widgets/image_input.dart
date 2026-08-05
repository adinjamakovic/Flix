import 'package:file_picker/file_picker.dart';
import 'package:flix_desktop/models/picked_image.dart';
import 'package:flutter/material.dart';

enum ImageInputShape { circle, rectangle }

// Preview + file picker for the single image an entity carries (a user's
// profile image, a movie poster, a country flag, ...).
class ImageInput extends StatefulWidget {
  const ImageInput({
    super.key,
    required this.onChanged,
    this.currentImageUrl,
    this.label = "Image",
    this.helperText,
    this.size = 148,
    this.shape = ImageInputShape.circle,
    this.placeholderIcon = Icons.image_outlined,
    this.enabled = true,
  });

  // Called with the staged image, or null when the selection is cleared.
  final void Function(PickedImage? image) onChanged;

  // Image already stored for the entity. Rendered until the user picks a new
  // one; anything that is not an http(s) URL falls back to the placeholder.
  final String? currentImageUrl;

  final String label;
  final String? helperText;
  final double size;
  final ImageInputShape shape;
  final IconData placeholderIcon;
  final bool enabled;

  /// Mirrors `ImageValidationRules.MaxImageSizeBytes`.
  static const int maxSizeBytes = 5 * 1024 * 1024;

  /// Mirrors `ImageValidationRules.AllowedExtensions`.
  static const List<String> allowedExtensions = [
    "jpg",
    "jpeg",
    "png",
    "gif",
    "webp",
  ];

  static const Map<String, String> _contentTypes = {
    "jpg": "image/jpeg",
    "jpeg": "image/jpeg",
    "png": "image/png",
    "gif": "image/gif",
    "webp": "image/webp",
  };

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  PickedImage? _picked;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildPreview(),
        const SizedBox(height: 12),
        _buildActions(),
        if (_picked != null) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: widget.size,
            child: Text(
              _picked!.fileName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: widget.size,
            child: Text(
              _error!,
              style: TextStyle(color: colors.error, fontSize: 12),
            ),
          ),
        ],
        if (widget.helperText != null && _error == null) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: widget.size,
            child: Text(
              widget.helperText!,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPreview() {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final BorderRadius radius = BorderRadius.circular(
      widget.shape == ImageInputShape.circle ? widget.size : 12,
    );

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: radius,
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildPreviewContent(),
    );
  }

  Widget _buildPreviewContent() {
    if (_picked != null) {
      return Image.memory(_picked!.bytes, fit: BoxFit.cover);
    }

    final Uri? uri = Uri.tryParse(widget.currentImageUrl ?? "");
    final bool isNetworkImage =
        uri != null && (uri.scheme == "http" || uri.scheme == "https");

    if (isNetworkImage) {
      return Image.network(
        uri.toString(),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Icon(
      widget.placeholderIcon,
      size: widget.size * 0.4,
      color: colors.onSurfaceVariant,
    );
  }

  Widget _buildActions() {
    final bool hasStagedImage = _picked != null;

    return SizedBox(
      width: widget.size,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: widget.enabled ? _pick : null,
            icon: const Icon(Icons.upload_outlined, size: 18),
            label: Text(hasStagedImage ? "Change" : "Upload"),
          ),
          if (hasStagedImage) ...[
            const SizedBox(height: 6),
            TextButton(
              onPressed: widget.enabled ? _clear : null,
              child: const Text("Remove"),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pick() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      dialogTitle: "Select ${widget.label.toLowerCase()}",
      type: FileType.custom,
      allowedExtensions: ImageInput.allowedExtensions,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final PlatformFile file = result.files.single;
    final String extension = (file.extension ?? "").toLowerCase();
    final String? contentType = ImageInput._contentTypes[extension];

    if (contentType == null) {
      _fail("Image must be one of the following types: "
          "${ImageInput.allowedExtensions.join(", ")}.");
      return;
    }

    if (file.size > ImageInput.maxSizeBytes) {
      _fail("Image must be "
          "${ImageInput.maxSizeBytes ~/ (1024 * 1024)} MB or smaller.");
      return;
    }

    final bytes = file.bytes;
    if (bytes == null) {
      _fail("Could not read the selected file.");
      return;
    }

    final PickedImage picked = PickedImage(
      fileName: file.name,
      bytes: bytes,
      contentType: contentType,
    );

    setState(() {
      _picked = picked;
      _error = null;
    });
    widget.onChanged(picked);
  }

  void _clear() {
    setState(() {
      _picked = null;
      _error = null;
    });
    widget.onChanged(null);
  }

  void _fail(String message) {
    setState(() {
      _error = message;
    });
  }
}
