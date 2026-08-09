import 'package:flix_mobile/models/picked_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  /// Mirrors `ImageValidationRules.MaxImageSizeBytes`.
  static const int maxSizeBytes = 5 * 1024 * 1024;

  /// Mirrors `ImageValidationRules.AllowedExtensions`.
  static const List<String> allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  static const Map<String, String> _contentTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
  };

  @override
  State<ImageInput> createState() => _ImageInputState();
}

enum _PickAction { camera, gallery, remove }

class _ImageInputState extends State<ImageInput> {
  final ImagePicker _picker = ImagePicker();

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
    final colors = Theme.of(context).colorScheme;

    final action = await showModalBottomSheet<_PickAction>(
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
              onTap: () => Navigator.pop(context, _PickAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, _PickAction.gallery),
            ),
            if (_picked != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove photo'),
                onTap: () => Navigator.pop(context, _PickAction.remove),
              ),
          ],
        ),
      ),
    );

    if (action == null) return;

    if (action == _PickAction.remove) {
      _clear();
      return;
    }

    await _pick(action == _PickAction.camera
        ? ImageSource.camera
        : ImageSource.gallery);
  }

  Future<void> _pick(ImageSource source) async {
    final XFile? file;
    try {
      // An avatar never needs the sensor's full resolution, and bounding it
      // here is what keeps a modern phone photo under the API's 5 MB limit.
      file = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
      );
    } on Exception catch (e) {
      // A denied camera/photo permission surfaces as a PlatformException.
      _fail(e.toString().replaceFirst('Exception: ', ''));
      return;
    }

    if (file == null) return;

    final String extension = _extensionOf(file.name);
    final String? contentType = ImageInput._contentTypes[extension];

    if (contentType == null) {
      _fail('Image must be one of the following types: '
          '${ImageInput.allowedExtensions.join(", ")}.');
      return;
    }

    final bytes = await file.readAsBytes();

    if (bytes.length > ImageInput.maxSizeBytes) {
      _fail('Image must be '
          '${ImageInput.maxSizeBytes ~/ (1024 * 1024)} MB or smaller.');
      return;
    }

    final picked = PickedImage(
      fileName: file.name,
      bytes: bytes,
      contentType: contentType,
    );

    if (!mounted) return;
    setState(() {
      _picked = picked;
      _error = null;
    });
    widget.onChanged(picked);
  }

  String _extensionOf(String fileName) {
    final int dot = fileName.lastIndexOf('.');
    return dot == -1 ? '' : fileName.substring(dot + 1).toLowerCase();
  }

  void _clear() {
    setState(() {
      _picked = null;
      _error = null;
    });
    widget.onChanged(null);
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() => _error = message);
  }
}
