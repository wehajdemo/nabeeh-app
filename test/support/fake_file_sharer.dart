import 'dart:io';
import 'dart:typed_data';

import 'package:rateby/features/export/application/export_service.dart';
import 'package:rateby/features/export/domain/file_sharer.dart';

class SharedFile {
  const SharedFile(this.bytes, this.fileName, this.mimeType);

  final Uint8List bytes;
  final String fileName;
  final String mimeType;
}

class FakeFileSharer implements FileSharer {
  final List<SharedFile> shared = [];

  @override
  Future<void> share({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    shared.add(SharedFile(bytes, fileName, mimeType));
  }
}

/// Fonts from the project's assets folder (tests run from the project root).
Future<ReportFonts> fontsFromDisk() async {
  ByteData load(String name) {
    final bytes = File('assets/fonts/$name').readAsBytesSync();
    return ByteData.sublistView(bytes);
  }

  return (
    regular: load('IBMPlexSansArabic-Regular.ttf'),
    bold: load('IBMPlexSansArabic-Bold.ttf'),
  );
}

bool looksLikePdf(Uint8List bytes) =>
    bytes.length > 4 &&
    String.fromCharCodes(bytes.sublist(0, 4)) == '%PDF';
