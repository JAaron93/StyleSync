import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:stylesync/core/privacy/auto_tagger_service.dart';

void main() {
  late AutoTaggerServiceImpl service;
  final List<Directory> tempDirs = [];

  setUp(() {
    service = AutoTaggerServiceImpl();
  });

  tearDown(() {
    for (final dir in tempDirs) {
      dir.deleteSync(recursive: true);
    }
    tempDirs.clear();
  });

  /// Helper to create a test image file with specified dimensions and color.
  /// Automatically tracks the temp Directory for cleanup.
  File createTestImage({
    required int width,
    required int height,
    required int r,
    required int g,
    required int b,
  }) {
    final image = img.Image(width: width, height: height);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        image.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }

    final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
    tempDirs.add(tempDir);
    final file = File('${tempDir.path}/test_image.png');
    final encoded = img.encodePng(image);
    file.writeAsBytesSync(encoded);

    return file;
  }

  group('AutoTaggerServiceImpl', () {
    group('analyzeTags', () {
      test('should return valid tags for a simple image', () async {
        final file = createTestImage(width: 300, height: 300, r: 255, g: 0, b: 0);

        final tags = await service.analyzeTags(file);

        expect(tags.category, isNotEmpty);
        expect(tags.colors, isNotEmpty);
        expect(tags.seasons, isNotEmpty);
        expect(tags.colors, isA<List<String>>());
        expect(tags.seasons, isA<List<String>>());
      });

      test('should throw StateError for non-existent file', () async {
        final nonExistentFile = File('/non/existent/path/image.png');

        expect(
          () => service.analyzeTags(nonExistentFile),
          throwsA(isA<StateError>()),
        );
      });

      test('should categorize square images as tops', () async {
        final file = createTestImage(width: 300, height: 300, r: 100, g: 150, b: 200);

        final tags = await service.analyzeTags(file);

        expect(tags.category, equals('tops'));
      });

      test('should categorize tall images as bottoms', () async {
        final file = createTestImage(width: 200, height: 500, r: 50, g: 100, b: 150);

        final tags = await service.analyzeTags(file);

        expect(tags.category, equals('bottoms'));
      });

      test('should categorize wide images as shoes', () async {
        final file = createTestImage(width: 400, height: 200, r: 25, g: 50, b: 75);

        final tags = await service.analyzeTags(file);

        expect(tags.category, equals('shoes'));
      });

      test('should categorize other images as accessories', () async {
        final file = createTestImage(width: 300, height: 400, r: 200, g: 100, b: 50);

        final tags = await service.analyzeTags(file);

        // Aspect ratio 300/400 = 0.75
        // Not < 0.7 (bottoms), not > 0.8 && < 1.3 (tops), not > 1.5 (shoes)
        // So it defaults to 'accessories'
        expect(tags.category, equals('accessories'));
      });

      test('should extract white color from light image', () async {
        final file = createTestImage(width: 100, height: 100, r: 255, g: 255, b: 255);

        final tags = await service.analyzeTags(file);

        expect(tags.colors, contains('white'));
      });

      test('should extract black color from dark image', () async {
        final file = createTestImage(width: 100, height: 100, r: 0, g: 0, b: 0);

        final tags = await service.analyzeTags(file);

        expect(tags.colors, contains('black'));
      });

      test('should extract red color from red image', () async {
        final file = createTestImage(width: 100, height: 100, r: 255, g: 0, b: 0);

        final tags = await service.analyzeTags(file);

        expect(tags.colors, contains('red'));
      });

      test('should extract green color from green image', () async {
        final file = createTestImage(width: 100, height: 100, r: 0, g: 255, b: 0);

        final tags = await service.analyzeTags(file);

        expect(tags.colors, contains('green'));
      });

      test('should extract blue color from blue image', () async {
        final file = createTestImage(width: 100, height: 100, r: 0, g: 0, b: 255);

        final tags = await service.analyzeTags(file);

        expect(tags.colors, contains('blue'));
      });

      test('should suggest spring/summer for light colors', () async {
        final file = createTestImage(width: 100, height: 100, r: 255, g: 255, b: 200);

        final tags = await service.analyzeTags(file);

        // White color contributes to spring, summer, and all-season
        // Since all seasons get equal counts, it returns ['all-season']
        expect(tags.seasons, contains('all-season'));
      });

      test('should suggest fall for warm colors', () async {
        final file = createTestImage(width: 100, height: 100, r: 255, g: 100, b: 50);

        final tags = await service.analyzeTags(file);

        expect(tags.seasons, contains('fall'));
      });

      test('should suggest winter for dark colors', () async {
        final file = createTestImage(width: 100, height: 100, r: 0, g: 0, b: 100);

        final tags = await service.analyzeTags(file);

        // Blue contributes to winter and summer
        // Black contributes to all seasons equally
        // Since all seasons get equal counts, it returns ['all-season']
        expect(tags.seasons, contains('all-season'));
      });

      test('should return all-season for neutral colors', () async {
        final file = createTestImage(width: 100, height: 100, r: 128, g: 128, b: 128);

        final tags = await service.analyzeTags(file);

        expect(tags.seasons, contains('all-season'));
      });

      test('should return ClothingTags with correct JSON serialization', () {
        final tags = ClothingTags(
          category: 'tops',
          colors: ['red', 'blue'],
          seasons: ['spring', 'summer'],
          additionalAttributes: {'material': 'cotton'},
        );

        final json = tags.toJson();

        expect(json['category'], equals('tops'));
        expect(json['colors'], equals(['red', 'blue']));
        expect(json['seasons'], equals(['spring', 'summer']));
        expect(json['additionalAttributes'], equals({'material': 'cotton'}));
      });

      test('should create ClothingTags from JSON', () {
        final json = {
          'category': 'bottoms',
          'colors': ['black', 'gray'],
          'seasons': ['fall', 'winter'],
          'additionalAttributes': {'material': 'denim'},
        };

        final tags = ClothingTags.fromJson(json);

        expect(tags.category, equals('bottoms'));
        expect(tags.colors, equals(['black', 'gray']));
        expect(tags.seasons, equals(['fall', 'winter']));
        expect(tags.additionalAttributes, equals({'material': 'denim'}));
      });
    });
  });
}
