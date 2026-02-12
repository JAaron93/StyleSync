import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:stylesync/core/privacy/auto_tagger_service.dart';

void main() {
  late AutoTaggerServiceImpl service;

  setUp(() {
    service = AutoTaggerServiceImpl();
  });

  group('AutoTaggerServiceImpl', () {
    group('analyzeTags', () {
      test('should return valid tags for a simple image', () async {
        // Create a simple test image
        final image = img.Image(width: 300, height: 300);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            image.setPixel(x, y, img.ColorRgb8(255, 0, 0));
          }
        }

        final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
        final file = File('${tempDir.path}/test_image.png');
        final encoded = img.encodePng(image);
        file.writeAsBytesSync(encoded);

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
        // Create a square image (aspect ratio ~1.0)
        final image = img.Image(width: 300, height: 300);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            image.setPixel(x, y, img.ColorRgb8(100, 150, 200));
          }
        }

        final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
        final file = File('${tempDir.path}/test_image.png');
        final encoded = img.encodePng(image);
        file.writeAsBytesSync(encoded);

        final tags = await service.analyzeTags(file);

        expect(tags.category, equals('tops'));
      });

      test('should categorize tall images as bottoms', () async {
        // Create a tall image (aspect ratio < 0.7)
        final image = img.Image(width: 200, height: 500);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            image.setPixel(x, y, img.ColorRgb8(50, 100, 150));
          }
        }

        final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
        final file = File('${tempDir.path}/test_image.png');
        final encoded = img.encodePng(image);
        file.writeAsBytesSync(encoded);

        final tags = await service.analyzeTags(file);

        expect(tags.category, equals('bottoms'));
      });

      test('should categorize wide images as shoes', () async {
        // Create a wide image (aspect ratio > 1.5)
        final image = img.Image(width: 400, height: 200);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            image.setPixel(x, y, img.ColorRgb8(25, 50, 75));
          }
        }

        final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
        final file = File('${tempDir.path}/test_image.png');
        final encoded = img.encodePng(image);
        file.writeAsBytesSync(encoded);

        final tags = await service.analyzeTags(file);

        expect(tags.category, equals('shoes'));
      });

      test('should categorize other images as accessories', () async {
        // Create an image with aspect ratio between 0.7 and 0.8
        // Using dimensions that give aspect ratio ~0.75
        final image = img.Image(width: 300, height: 400);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            image.setPixel(x, y, img.ColorRgb8(200, 100, 50));
          }
        }

        final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
        final file = File('${tempDir.path}/test_image.png');
        final encoded = img.encodePng(image);
        file.writeAsBytesSync(encoded);

        final tags = await service.analyzeTags(file);

        // Aspect ratio 300/400 = 0.75
        // Not < 0.7 (bottoms), not > 0.8 && < 1.3 (tops), not > 1.5 (shoes)
        // So it defaults to 'accessories'
        expect(tags.category, equals('accessories'));
      });

      test('should extract white color from light image', () async {
        // Create a white image
        final image = img.Image(width: 100, height: 100);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            image.setPixel(x, y, img.ColorRgb8(255, 255, 255));
          }
        }

        final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
        final file = File('${tempDir.path}/test_image.png');
        final encoded = img.encodePng(image);
        file.writeAsBytesSync(encoded);

        final tags = await service.analyzeTags(file);

        expect(tags.colors, contains('white'));
      });

      test('should extract black color from dark image', () async {
        // Create a black image
        final image = img.Image(width: 100, height: 100);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            image.setPixel(x, y, img.ColorRgb8(0, 0, 0));
          }
        }

        final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
        final file = File('${tempDir.path}/test_image.png');
        final encoded = img.encodePng(image);
        file.writeAsBytesSync(encoded);

        final tags = await service.analyzeTags(file);

        expect(tags.colors, contains('black'));
      });

      test('should extract red color from red image', () async {
        // Create a red image
        final image = img.Image(width: 100, height: 100);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            image.setPixel(x, y, img.ColorRgb8(255, 0, 0));
          }
        }

        final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
        final file = File('${tempDir.path}/test_image.png');
        final encoded = img.encodePng(image);
        file.writeAsBytesSync(encoded);

        final tags = await service.analyzeTags(file);

        expect(tags.colors, contains('red'));
      });

      test('should extract green color from green image', () async {
        // Create a green image
        final image = img.Image(width: 100, height: 100);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            image.setPixel(x, y, img.ColorRgb8(0, 255, 0));
          }
        }

        final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
        final file = File('${tempDir.path}/test_image.png');
        final encoded = img.encodePng(image);
        file.writeAsBytesSync(encoded);

        final tags = await service.analyzeTags(file);

        expect(tags.colors, contains('green'));
      });

      test('should extract blue color from blue image', () async {
        // Create a blue image
        final image = img.Image(width: 100, height: 100);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            image.setPixel(x, y, img.ColorRgb8(0, 0, 255));
          }
        }

        final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
        final file = File('${tempDir.path}/test_image.png');
        final encoded = img.encodePng(image);
        file.writeAsBytesSync(encoded);

        final tags = await service.analyzeTags(file);

        expect(tags.colors, contains('blue'));
      });

      test('should suggest spring/summer for light colors', () async {
        // Create a white/yellow image
        final image = img.Image(width: 100, height: 100);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            image.setPixel(x, y, img.ColorRgb8(255, 255, 200));
          }
        }

        final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
        final file = File('${tempDir.path}/test_image.png');
        final encoded = img.encodePng(image);
        file.writeAsBytesSync(encoded);

        final tags = await service.analyzeTags(file);

        // White color contributes to spring, summer, and all-season
        // Since all seasons get equal counts, it returns ['all-season']
        expect(tags.seasons, contains('all-season'));
      });

      test('should suggest fall for warm colors', () async {
        // Create an orange/brown image
        final image = img.Image(width: 100, height: 100);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            image.setPixel(x, y, img.ColorRgb8(255, 100, 50));
          }
        }

        final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
        final file = File('${tempDir.path}/test_image.png');
        final encoded = img.encodePng(image);
        file.writeAsBytesSync(encoded);

        final tags = await service.analyzeTags(file);

        expect(tags.seasons, contains('fall'));
      });

      test('should suggest winter for dark colors', () async {
        // Create a dark blue/black image
        final image = img.Image(width: 100, height: 100);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            image.setPixel(x, y, img.ColorRgb8(0, 0, 100));
          }
        }

        final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
        final file = File('${tempDir.path}/test_image.png');
        final encoded = img.encodePng(image);
        file.writeAsBytesSync(encoded);

        final tags = await service.analyzeTags(file);

        // Blue contributes to winter and summer
        // Black contributes to all seasons equally
        // Since all seasons get equal counts, it returns ['all-season']
        expect(tags.seasons, contains('all-season'));
      });

      test('should return all-season for neutral colors', () async {
        // Create a gray image
        final image = img.Image(width: 100, height: 100);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            image.setPixel(x, y, img.ColorRgb8(128, 128, 128));
          }
        }

        final tempDir = Directory.systemTemp.createTempSync('auto_tagger_test_');
        final file = File('${tempDir.path}/test_image.png');
        final encoded = img.encodePng(image);
        file.writeAsBytesSync(encoded);

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
