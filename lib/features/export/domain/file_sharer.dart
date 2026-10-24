import 'dart:typed_data';

/// Hands a generated file to the system share sheet (save, send, open in…).
abstract interface class FileSharer {
  Future<void> share({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  });
}
