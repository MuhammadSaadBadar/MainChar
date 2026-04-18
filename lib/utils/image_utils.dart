import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart';

class ImageUtils {
  /// Compresses [imageBytes] to approximately [quality]% and resizes to [minWidth].
  /// Returns the compressed bytes.
  static Future<Uint8List> compressImage(
    Uint8List imageBytes, {
    int quality = 80,
    int minWidth = 1080,
    int? minHeight,
  }) async {
    try {
      final beforeSize = imageBytes.lengthInBytes / 1024;
      debugPrint('Compression - Before: ${beforeSize.toStringAsFixed(2)} KB');

      final compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: minWidth,
        minHeight: minHeight ?? ((minWidth * 3) ~/ 4), // Default 4:3 ratio if not provided
        quality: quality,
        format: CompressFormat.jpeg,
      );

      final afterSize = compressedBytes.lengthInBytes / 1024;
      final savings = ((1 - (afterSize / beforeSize)) * 100).toStringAsFixed(1);
      
      debugPrint('Compression - After: ${afterSize.toStringAsFixed(2)} KB ($savings% saved)');
      return compressedBytes;
    } catch (e) {
      debugPrint('Compression Error: $e');
      // Return original bytes if compression fails
      return imageBytes;
    }
  }

  /// Specialized compression for profile avatars (smaller)
  static Future<Uint8List> compressAvatar(Uint8List imageBytes) async {
    return compressImage(
      imageBytes,
      quality: 85,
      minWidth: 400, // Avatars don't need to be huge
      minHeight: 400,
    );
  }
}
