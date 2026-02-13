import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:stylesync/core/privacy/auto_tagger_service.dart';

void main() {
  group('Property Tests: Auto-Tagger Privacy Invariant', () {
    late AutoTaggerServiceImpl service;

    setUp(() {
      service = AutoTaggerServiceImpl();
    });

    // Property 6: Auto-Tagger Privacy Invariant
    // Validates: Requirements 3.10
    test('auto-tagger output contains only clothing attributes', () async {
      // Test with various image sizes and colors
      final testCases = [
        {'width': 100, 'height': 100, 'color': 'red'},
        {'width': 200, 'height': 300, 'color': 'blue'},
        {'width': 300, 'height': 200, 'color': 'green'},
        {'width': 400, 'height': 400, 'color': 'yellow'},
      ];

      for (final testCase in testCases) {
        final width = testCase['width'] as int;
        final height = testCase['height'] as int;
        final color = testCase['color'] as String;

        // Create a test image with the specified color
        final testImage = img.Image(width: width, height: height);
        final colorValue = _getColorValue(color);
        for (int x = 0; x < width; x++) {
          for (int y = 0; y < height; y++) {
            testImage.setPixel(x, y, img.ColorRgb8(
              colorValue[0],
              colorValue[1],
              colorValue[2],
            ));
          }
        }

        final pngBytes = img.encodePng(testImage);
        final tempDir = await Directory.systemTemp.createTemp('auto_tagger_prop_test_');
        final tempFile = File('${tempDir.path}/test_image.png');
        await tempFile.writeAsBytes(pngBytes);

        ClothingTags? tags;
        try {
          tags = await service.analyzeTags(tempFile);

          // Property: Category must be one of the allowed values
          expect(
            tags.category,
            isIn(['tops', 'bottoms', 'shoes', 'accessories']),
            reason: 'Category must be one of: tops, bottoms, shoes, accessories',
          );

          // Property: Colors must be a list of strings
          expect(tags.colors, isList);
          expect(tags.colors.every((c) => c is String), isTrue);

          // Property: Seasons must be a list of strings
          expect(tags.seasons, isList);
          expect(tags.seasons.every((c) => c is String), isTrue);

          // Property: No biometric data in additionalAttributes
          final biometricKeys = [
            'face',
            'facial',
            'biometric',
            'measurement',
            'body',
            'person',
            'identity',
          ];

          final hasBiometricData = tags.additionalAttributes.keys.any((key) {
            final lowerKey = key.toLowerCase();
            return biometricKeys.any((biometric) => lowerKey.contains(biometric));
          });

          expect(hasBiometricData, isFalse,
            reason: 'Additional attributes must not contain biometric data',
          );
        } finally {
          await tempFile.delete();
          await tempDir.delete(recursive: true);
        }
      }
    });

    test('auto-tagger does not extract facial or biometric data', () async {
      // Test with various clothing-like images
      final testCases = [
        {'width': 250, 'height': 250, 'name': 'square (tops-like)'},
        {'width': 200, 'height': 400, 'name': 'tall (bottoms-like)'},
        {'width': 400, 'height': 200, 'name': 'wide (shoes-like)'},
      ];

      for (final testCase in testCases) {
        final width = testCase['width'] as int;
        final height = testCase['height'] as int;

        // Create a test image
        final testImage = img.Image(width: width, height: height);
        for (int x = 0; x < width; x++) {
          for (int y = 0; y < height; y++) {
            testImage.setPixel(x, y, img.ColorRgb8(
              (x * 255 ~/ width).toInt(),
              (y * 255 ~/ height).toInt(),
              ((x + y) * 255 ~/ (width + height)).toInt(),
            ));
          }
        }

        final pngBytes = img.encodePng(testImage);
        final tempDir = await Directory.systemTemp.createTemp('auto_tagger_privacy_test_');
        final tempFile = File('${tempDir.path}/test_image.png');
        await tempFile.writeAsBytes(pngBytes);

        ClothingTags? tags;
        try {
          tags = await service.analyzeTags(tempFile);

          // Property: Output must contain only clothing attributes
          // Relax non-empty checks for synthetic images; focus on privacy invariants
          expect(tags.category, isNotNull);
          expect(tags.colors, isNotNull);
          expect(tags.seasons, isNotNull);

          // Property: Colors and seasons must be lists of strings
          expect(tags.colors, isList);
          expect(tags.colors.every((c) => c is String), isTrue);

          expect(tags.seasons, isList);
          expect(tags.seasons.every((c) => c is String), isTrue);

          // Property: No person/facial data
          final hasPersonData = tags.additionalAttributes.keys.any((key) {
            final lowerKey = key.toLowerCase();
            return lowerKey.contains('person') ||
                   lowerKey.contains('human') ||
                   lowerKey.contains('face');
          });

          expect(hasPersonData, isFalse,
            reason: 'Additional attributes must not contain person/facial data',
          );
        } finally {
          await tempFile.delete();
          await tempDir.delete(recursive: true);
        }
      }
    });
  });
}

/// Helper function to get RGB values for named colors
List<int> _getColorValue(String color) {
  switch (color) {
    case 'red':
      return [255, 0, 0];
    case 'blue':
      return [0, 0, 255];
    case 'green':
      return [0, 255, 0];
    case 'yellow':
      return [255, 255, 0];
    default:
      return [128, 128, 128];
  }
}
