import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:stylesync/core/privacy/metadata_stripper_service.dart';

void main() {
  group('Property Tests: EXIF Metadata Stripping', () {
    final service = MetadataStripperServiceImpl();

    // Property 4: EXIF Metadata Stripping
    test('Metadata stripping preserves image pixel data', () async {
      // Create a test image with a known pattern
      final testImage = img.Image(width: 100, height: 100);
      
      // Fill with a pattern that we can verify after stripping
      for (int x = 0; x < 100; x++) {
        for (int y = 0; y < 100; y++) {
          testImage.setPixel(x, y, img.ColorRgb8(128, 64, 32));
        }
      }
      
      // Add explicit EXIF metadata to ensure stripping reduces size
      // Ensure EXIF is present before setting tags
      expect(testImage.exif, isNotNull, reason: 'Test image must have EXIF data initialized');
      
      // Set EXIF fields for camera make, model, and timestamp
      testImage.exif!.setTagString(img.ExifTags.make, 'TestCamera');
      testImage.exif!.setTagString(img.ExifTags.model, 'TestModel');
      testImage.exif!.setTagString(img.ExifTags.software, 'TestSoftware');
      testImage.exif!.setTagString(img.ExifTags.artist, 'TestArtist');
      testImage.exif!.setTagString(img.ExifTags.copyright, 'TestCopyright');
      testImage.exif!.setTagString(img.ExifTags.dateTimeOriginal, '2024:01:01 00:00:00');
      testImage.exif!.setTagString(img.ExifTags.createDate, '2024:01:01 00:00:00');
      
      // Encode to JPEG (which supports EXIF)
      final jpegBytes = img.encodeJpg(testImage);
      
      // Write to a temporary file
      final tempDir = await Directory.systemTemp.createTemp('stripped_test_');
      final tempFile = File('${tempDir.path}/test_image.jpg');
      await tempFile.writeAsBytes(jpegBytes);
      
      File? strippedFile;
      try {
        // Strip metadata
        strippedFile = await service.stripMetadata(tempFile);
        
        // Read the stripped image
        final strippedBytes = await strippedFile.readAsBytes();
        final strippedImage = img.decodeImage(strippedBytes);
        
        // Verify the image can be decoded
        expect(strippedImage, isNotNull);
        
        // Verify the pixel data is preserved (same dimensions)
        expect(strippedImage?.width, 100);
        expect(strippedImage?.height, 100);
        
        // Check a sample pixel to verify data integrity (allow small variance due to JPEG lossy encoding)
        final samplePixel = strippedImage?.getPixel(50, 50);
        expect(samplePixel?.r, greaterThan(120));
        expect(samplePixel?.g, greaterThan(50));
        expect(samplePixel?.b, greaterThan(20));
        
        // Verify the stripped file is different from original (metadata removed)
        expect(strippedBytes.length, lessThan(jpegBytes.length));
      } finally {
        // Clean up temporary files
        await tempFile.delete();
        if (strippedFile != null) {
          await strippedFile.delete();
        }
        await tempDir.delete(recursive: true);
      }
    });

    test('Metadata stripping produces valid image files', () async {
      // Create a test image
      final testImage = img.Image(width: 50, height: 50);
      for (int x = 0; x < 50; x++) {
        for (int y = 0; y < 50; y++) {
          testImage.setPixel(x, y, img.ColorRgb8(x % 256, y % 256, 128));
        }
      }
      
      final jpegBytes = img.encodeJpg(testImage);
      final tempDir = await Directory.systemTemp.createTemp('stripped_test2_');
      final tempFile = File('${tempDir.path}/test_image2.jpg');
      await tempFile.writeAsBytes(jpegBytes);
      
      File? strippedFile;
      try {
        strippedFile = await service.stripMetadata(tempFile);
        
        // Verify the stripped file can be read and decoded
        final strippedBytes = await strippedFile.readAsBytes();
        final decodedImage = img.decodeImage(strippedBytes);
        
        expect(decodedImage, isNotNull);
        expect(decodedImage?.width, 50);
        expect(decodedImage?.height, 50);
      } finally {
        await tempFile.delete();
        if (strippedFile != null) {
          await strippedFile.delete();
        }
        await tempDir.delete(recursive: true);
      }
    });

    test('Metadata stripping handles non-image files gracefully', () async {
      // Create a non-image file
      final tempDir = await Directory.systemTemp.createTemp('stripped_test3_');
      final tempFile = File('${tempDir.path}/not_an_image.txt');
      await tempFile.writeAsString('This is not an image');
      
      try {
        await expectLater(
          service.stripMetadata(tempFile),
          throwsA(isA<StateError>()),
        );
      } finally {
        await tempFile.delete();
        await tempDir.delete(recursive: true);
      }
    });
  });
}
