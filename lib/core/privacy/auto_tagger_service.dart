import 'dart:io';
import 'package:image/image.dart' as img;

/// Service for automatically tagging clothing items.
/// 
/// This service analyzes clothing images and extracts attributes such as:
/// - Category (tops, bottoms, shoes, accessories)
/// - Dominant colors
/// - Season suggestions (spring, summer, fall, winter, all-season)
/// 
/// The service restricts analysis to clothing attributes only and does not
/// process or log any biometric or facial data.
abstract class AutoTaggerService {
  /// Analyzes a clothing image and returns extracted tags.
  /// 
  /// Returns category, colors, and season suggestions.
  /// Analysis is restricted to clothing attributes only.
  Future<ClothingTags> analyzeTags(File imageFile);
}

class ClothingTags {
  final String category; // tops, bottoms, shoes, accessories, unknown (fallback)
  final List<String> colors;
  final List<String> seasons; // spring, summer, fall, winter, all-season
  final Map<String, dynamic> additionalAttributes;

  ClothingTags({
    required this.category,
    required this.colors,
    required this.seasons,
    this.additionalAttributes = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'colors': colors,
      'seasons': seasons,
      'additionalAttributes': additionalAttributes,
    };
  }

  factory ClothingTags.fromJson(Map<String, dynamic> json) {
    return ClothingTags(
      category: json['category'] as String? ?? 'unknown',
      colors: List<String>.from(json['colors'] ?? []),
      seasons: List<String>.from(json['seasons'] ?? []),
      additionalAttributes: Map<String, dynamic>.from(json['additionalAttributes'] ?? {}),
    );
  }
}

class AutoTaggerServiceImpl implements AutoTaggerService {
  @override
  Future<ClothingTags> analyzeTags(File imageFile) async {
    if (!await imageFile.exists()) {
      throw StateError('Image file does not exist: ${imageFile.path}');
    }

    // Read image bytes
    final bytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      throw StateError('Failed to decode image: ${imageFile.path}');
    }

    // Extract category based on image dimensions and aspect ratio
    final category = _categorizeClothing(decodedImage);

    // Extract dominant colors
    final colors = _extractDominantColors(decodedImage);

    // Suggest season based on colors
    final seasons = _suggestSeasons(colors);

    return ClothingTags(
      category: category,
      colors: colors,
      seasons: seasons,
    );
  }

  /// Categorizes clothing based on image dimensions and aspect ratio.
  String _categorizeClothing(img.Image image) {
    final width = image.width;
    final height = image.height;
    if (width == 0 || height == 0) {
      return 'accessories'; // default for degenerate images
    }
    final aspectRatio = width / height;
    // T-shirts and tops are typically square or slightly wider
    if (aspectRatio > 0.8 && aspectRatio < 1.3) {
      return 'tops';
    }

    // Pants and bottoms are typically taller
    if (aspectRatio < 0.7) {
      return 'bottoms';
    }

    // Shoes and accessories are typically wider
    if (aspectRatio > 1.5) {
      return 'shoes';
    }

    // Default to accessories for other items
    return 'accessories';
  }

  /// Extracts dominant colors from the image.
  List<String> _extractDominantColors(img.Image image) {
    // Simple color extraction: sample pixels and find most common
    final colorCounts = <String, int>{};

    // Sample every 10th pixel to improve performance
    final step = 10;
    for (var y = 0; y < image.height; y += step) {
      for (var x = 0; x < image.width; x += step) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // Group similar colors into buckets
        final colorBucket = _getColorBucket(r, g, b);
        colorCounts[colorBucket] = (colorCounts[colorBucket] ?? 0) + 1;
      }
    }

    // Sort by count and return top colors
    final sortedColors = colorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Return top 3 colors
    return sortedColors.take(3).map((e) => e.key).toList();
  }

  /// Groups RGB values into color buckets.
  String _getColorBucket(int r, int g, int b) {
    // Simple color bucketing based on dominant channel
    if (r > 200 && g > 200 && b > 200) {
      return 'white';
    }
    if (r < 50 && g < 50 && b < 50) {
      return 'black';
    }
    if (r > 200 && g < 100 && b < 100) {
      return 'red';
    }
    if (r < 100 && g > 200 && b < 100) {
      return 'green';
    }
    if (r < 100 && g < 100 && b > 200) {
      return 'blue';
    }
    if (r > 200 && g > 200 && b < 100) {
      return 'yellow';
    }
    if (r > 200 && g < 150 && b < 100) {
      return 'orange';
    }
    if (r > 150 && g < 100 && b > 150) {
      return 'purple';
    }
    if (r > 200 && g > 150 && b < 100) {
      return 'brown';
    }

    // Default to gray for neutral colors
    return 'gray';
  }

  /// Suggests seasons based on extracted colors.
  List<String> _suggestSeasons(List<String> colors) {
    final seasonCounts = <String, int>{
      'spring': 0,
      'summer': 0,
      'fall': 0,
      'winter': 0,
    };

    for (final color in colors) {
      switch (color) {
        case 'white':
        case 'yellow':
        case 'green':
          seasonCounts['spring'] = (seasonCounts['spring'] ?? 0) + 1;
          seasonCounts['summer'] = (seasonCounts['summer'] ?? 0) + 1;
          break;
        case 'red':
        case 'orange':
        case 'brown':
          seasonCounts['fall'] = (seasonCounts['fall'] ?? 0) + 1;
          break;
        case 'blue':
        case 'black':
          seasonCounts['winter'] = (seasonCounts['winter'] ?? 0) + 1;
          seasonCounts['summer'] = (seasonCounts['summer'] ?? 0) + 1;
          break;
        default:
          // Gray and other neutral colors work for all seasons
          seasonCounts['spring'] = (seasonCounts['spring'] ?? 0) + 1;
          seasonCounts['summer'] = (seasonCounts['summer'] ?? 0) + 1;
          seasonCounts['fall'] = (seasonCounts['fall'] ?? 0) + 1;
          seasonCounts['winter'] = (seasonCounts['winter'] ?? 0) + 1;
          break;
      }
    }

    // Return seasons with highest counts
    final sortedSeasons = seasonCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Return top 2 seasons, or "all-season" if balanced
    if (sortedSeasons.every((e) => e.value == sortedSeasons.first.value)) {
      return ['all-season'];
    }

    return sortedSeasons.take(2).map((e) => e.key).toList();
  }
}
