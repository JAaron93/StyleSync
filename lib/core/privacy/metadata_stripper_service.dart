import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Service for stripping EXIF and other metadata from images.
/// 
/// This service removes GPS coordinates, timestamps, device identifiers,
/// and other ancillary data while preserving only the image pixel data.
abstract class MetadataStripperService {
  /// Strips all EXIF and ancillary metadata from an image file.
  /// 
  /// Returns a new file with only the image pixel data preserved.
  /// The original file is not modified.
  Future<File> stripMetadata(File imageFile);
}

class MetadataStripperServiceImpl implements MetadataStripperService {
  @override
  Future<File> stripMetadata(File imageFile) async {
    // Read the image bytes
    final bytes = await imageFile.readAsBytes();
    
    // Decode the image
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw StateError('Failed to decode image: ${imageFile.path}');
    }
    
    // Encode the image without metadata (PNG has no EXIF)
    final encoded = img.encodePng(image);
    
    // Write to a new file with .png extension
    final tempDir = await imageFile.parent.createTemp('stripped_');
    final baseName = p.basenameWithoutExtension(imageFile.path);
    final strippedFile = File(p.join(tempDir.path, '$baseName.png'));
    await strippedFile.writeAsBytes(encoded);
    
    return strippedFile;
  }
}
