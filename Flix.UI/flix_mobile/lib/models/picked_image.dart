import 'dart:typed_data';

// An image the user picked off disk, held in memory until the form is saved.
class PickedImage {
  const PickedImage({
    required this.fileName,
    required this.bytes,
    required this.contentType,
  });

  final String fileName;
  final Uint8List bytes;

  final String contentType;
}
