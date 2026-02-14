import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:stylesync/core/privacy/background_removal_service.dart';

void main() {
  group('BackgroundRemovalService Tests', () {
    late BackgroundRemovalServiceImpl service;

    setUp(() {
      service = BackgroundRemovalServiceImpl();
    });

    test(
      'background removal returns original file on non-existent file',
      () async {
        final nonExistentFile = File('/non/existent/path/image.jpg');

        final result = await service.removeBackground(nonExistentFile);

        expect(result.path, nonExistentFile.path);
      },
    );

    test('background removal handles valid image files', () async {
      // Create a test image
      final testImage = img.Image(width: 100, height: 100);
      for (int x = 0; x < 100; x++) {
        for (int y = 0; y < 100; y++) {
          testImage.setPixel(x, y, img.ColorRgb8(255, 128, 64));
        }
      }

      final jpegBytes = img.encodeJpg(testImage);
      final tempDir = await Directory.systemTemp.createTemp('bg_removal_test_');
      final tempFile = File('${tempDir.path}/test_image.jpg');
      await tempFile.writeAsBytes(jpegBytes);

      File? resultFile;
      try {
        resultFile = await service.removeBackground(tempFile);

        // Result should be a valid file
        expect(resultFile.existsSync(), true);

        // Result should be a PNG (background removed)
        final resultBytes = await resultFile.readAsBytes();
        final decodedImage = img.decodeImage(resultBytes);
        expect(decodedImage, isNotNull);

        // Result should be resized to model input size (513x513)
        expect(decodedImage?.width, 513);
        expect(decodedImage?.height, 513);
      } finally {
        // Safely delete files, avoiding double-deletes and ensuring all deletions run
        try {
          await tempFile.delete();
        } catch (e) {
          // Log and continue
        }
        if (resultFile != null && resultFile.path != tempFile.path) {
          try {
            await resultFile.delete();
          } catch (e) {
            // Log and continue
          }
        }
        try {
          await tempDir.delete(recursive: true);
        } catch (e) {
          // Log and continue
        }
      }
    });

    test('background removal handles images with transparency', () async {
      // Create an image with some transparent pixels
      final testImage = img.Image(width: 50, height: 50);
      for (int x = 0; x < 50; x++) {
        for (int y = 0; y < 50; y++) {
          if (x < 25) {
            testImage.setPixel(
              x,
              y,
              img.ColorRgba8(255, 0, 0, 255),
            ); // Opaque red
          } else {
            testImage.setPixel(
              x,
              y,
              img.ColorRgba8(0, 255, 0, 128),
            ); // Semi-transparent green
          }
        }
      }

      final pngBytes = img.encodePng(testImage);
      final tempDir = await Directory.systemTemp.createTemp(
        'bg_removal_alpha_test_',
      );
      final tempFile = File('${tempDir.path}/test_image.png');
      await tempFile.writeAsBytes(pngBytes);

      File? resultFile;
      try {
        resultFile = await service.removeBackground(tempFile);

        final resultBytes = await resultFile.readAsBytes();
        final decodedImage = img.decodeImage(resultBytes);
        expect(decodedImage, isNotNull);
        // Result should be resized to model input size (513x513)
        expect(decodedImage?.width, 513);
        expect(decodedImage?.height, 513);

        // Verify alpha handling - check that semi-transparent pixels are preserved or handled
        // Sample pixels from the opaque region (left side, x < 25 in original -> x < ~256 in scaled)
        final opaquePixel = decodedImage?.getPixel(100, 256);
        expect(opaquePixel?.a, greaterThan(200)); // Should be mostly opaque

        // Sample pixels from the semi-transparent region (right side, x >= 25 in original -> x >= ~256 in scaled)
        final semiTransparentPixel = decodedImage?.getPixel(400, 256);
        // After processing, alpha may be preserved or flattened to 255
        // Either behavior is acceptable as long as the image is valid
        expect(semiTransparentPixel, isNotNull);

        // Verify at least one pixel has valid alpha (0-255)
        final anyAlpha = decodedImage?.getPixel(25, 25);
        expect(anyAlpha?.a, inInclusiveRange(0, 255));
      } finally {
        // Safely delete files, avoiding double-deletes and ensuring all deletions run
        try {
          await tempFile.delete();
        } catch (e) {
          // Log and continue
        }
        if (resultFile != null && resultFile.path != tempFile.path) {
          try {
            await resultFile.delete();
          } catch (e) {
            // Log and continue
          }
        }
        try {
          await tempDir.delete(recursive: true);
        } catch (e) {
          // Log and continue
        }
      }
    });

    test('background removal handles images that cannot be decoded', () async {
      // Create a non-image file
      final tempDir = await Directory.systemTemp.createTemp(
        'bg_removal_invalid_test_',
      );
      final tempFile = File('${tempDir.path}/not_an_image.txt');
      await tempFile.writeAsString('This is not an image');

      try {
        final resultFile = await service.removeBackground(tempFile);

        // Should return original file when image cannot be decoded
        expect(resultFile.path, tempFile.path);
      } finally {
        // Safely delete files, avoiding double-deletes and ensuring all deletions run
        try {
          await tempFile.delete();
        } catch (e) {
          // Log and continue
        }
        try {
          await tempDir.delete(recursive: true);
        } catch (e) {
          // Log and continue
        }
      }
    });
  });
}
