import 'package:flix_mobile/models/picked_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Mirrors `ImageValidationRules.MaxImageSizeBytes`.
const int maxImageSizeBytes = 5 * 1024 * 1024;

/// Mirrors `ImageValidationRules.AllowedExtensions`.
const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

const Map<String, String> _imageContentTypes = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'gif': 'image/gif',
  'webp': 'image/webp',
};

class ImagePickResult {
  const ImagePickResult({this.image, this.error});

  final PickedImage? image;
  final String? error;

  bool get isCancelled => image == null && error == null;
}

enum ImagePickAction { camera, gallery, remove }

Future<ImagePickResult> pickImage(
  ImageSource source, {
  double maxWidth = 1080,
  double maxHeight = 1080,
}) async {
  final XFile? file;
  try {
    file = await _picker.pickImage(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  } on Exception catch (e) {
    return ImagePickResult(error: e.toString().replaceFirst('Exception: ', ''));
  }

  if (file == null) return const ImagePickResult();

  final String extension = _extensionOf(file.name);
  final String? contentType = _imageContentTypes[extension];

  if (contentType == null) {
    return ImagePickResult(
      error: 'Image must be one of the following types: '
          '${allowedImageExtensions.join(", ")}.',
    );
  }

  final bytes = await file.readAsBytes();

  if (bytes.length > maxImageSizeBytes) {
    return ImagePickResult(
      error: 'Image must be '
          '${maxImageSizeBytes ~/ (1024 * 1024)} MB or smaller.',
    );
  }

  return ImagePickResult(
    image: PickedImage(
      fileName: file.name,
      bytes: bytes,
      contentType: contentType,
    ),
  );
}

Future<ImagePickAction?> showImageSourceSheet(
  BuildContext context, {
  bool canRemove = false,
  String removeLabel = 'Remove photo',
}) {
  final colors = Theme.of(context).colorScheme;

  return showModalBottomSheet<ImagePickAction>(
    context: context,
    backgroundColor: colors.surfaceContainerHigh,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(context, ImagePickAction.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(context, ImagePickAction.gallery),
          ),
          if (canRemove)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(removeLabel),
              onTap: () => Navigator.pop(context, ImagePickAction.remove),
            ),
        ],
      ),
    ),
  );
}

final ImagePicker _picker = ImagePicker();

String _extensionOf(String fileName) {
  final int dot = fileName.lastIndexOf('.');
  return dot == -1 ? '' : fileName.substring(dot + 1).toLowerCase();
}

/// A round image picker — an avatar. `PosterInput` is the rectangular one.
class ImageInput extends StatefulWidget {
  const ImageInput({
    super.key,
    required this.onChanged,
    this.currentImageUrl,
    this.label = 'Profile photo',
    this.helperText,
    this.size = 104,
    this.placeholderIcon = Icons.person_outline,
    this.enabled = true,
  });

  final void Function(PickedImage? image) onChanged;

  final String? currentImageUrl;

  final String label;
  final String? helperText;
  final double size;
  final IconData placeholderIcon;
  final bool enabled;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  PickedImage? _picked;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        GestureDetector(
          onTap: widget.enabled ? _openSourceSheet : null,
          child: Stack(
            children: [
              _buildPreview(),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surfaceContainerLow, width: 2),
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: 16,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _error ?? (_picked != null ? widget.label : (widget.helperText ?? widget.label)),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _error != null ? colors.error : colors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        if (_picked != null)
          TextButton(
            onPressed: widget.enabled ? _clear : null,
            child: const Text('Remove photo'),
          ),
      ],
    );
  }

  Widget _buildPreview() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        shape: BoxShape.circle,
        border: Border.all(color: colors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildPreviewContent(),
    );
  }

  Widget _buildPreviewContent() {
    if (_picked != null) {
      return Image.memory(_picked!.bytes, fit: BoxFit.cover);
    }

    final Uri? uri = Uri.tryParse(widget.currentImageUrl ?? '');
    final bool isNetworkImage =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

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
    final colors = Theme.of(context).colorScheme;

    return Icon(
      widget.placeholderIcon,
      size: widget.size * 0.45,
      color: colors.onSurfaceVariant,
    );
  }

  Future<void> _openSourceSheet() async {
    final action = await showImageSourceSheet(
      context,
      canRemove: _picked != null,
    );

    if (action == null) return;

    if (action == ImagePickAction.remove) {
      _clear();
      return;
    }

    await _pick(action == ImagePickAction.camera
        ? ImageSource.camera
        : ImageSource.gallery);
  }

  Future<void> _pick(ImageSource source) async {
    final ImagePickResult result = await pickImage(source);

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
