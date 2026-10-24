import 'dart:typed_data';

import 'package:rateby/features/export/domain/file_sharer.dart';
import 'package:share_plus/share_plus.dart';

/// [FileSharer] using the platform share sheet.
class SharePlusFileSharer implements FileSharer {
  const SharePlusFileSharer();

  @override
  Future<void> share({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    await Share.shareXFiles(
      [XFile.fromData(bytes, mimeType: mimeType, name: fileName)],
      fileNameOverrides: [fileName],
    );
  }
}
