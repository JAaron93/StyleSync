import 'package:uuid/uuid.dart';

/// Represents a clothing item in the user's digital closet.
class ClothingItem {
  /// Unique identifier for this clothing item.
  final String id;

  /// User ID who owns this item.
  final String userId;

  /// URL to the original uploaded image.
  final String imageUrl;

  /// URL to the processed image (background removed).
  final String processedImageUrl;

  /// URL to the thumbnail image for list views.
  final String thumbnailUrl;

  /// Clothing category (tops, bottoms, shoes, accessories).
  final String category;

  /// List of detected colors.
  final List<String> colors;

  /// List of suggested seasons (spring, summer, fall, winter, all-season).
  final List<String> seasons;

  /// Timestamp when the item was uploaded.
  final DateTime uploadedAt;

  /// Timestamp of the last update.
  final DateTime updatedAt;

  /// Processing state of the item.
  final ItemProcessingState processingState;

  /// Error message if processing failed.
  final String? failureReason;

  /// Number of retry attempts for processing.
  final int retryCount;

  /// Idempotency key for deduplication.
  final String idempotencyKey;

  /// Creates a new [ClothingItem] instance.
  const ClothingItem({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.processedImageUrl,
    required this.thumbnailUrl,
    required this.category,
    required this.colors,
    required this.seasons,
    required this.uploadedAt,
    required this.updatedAt,
    required this.processingState,
    this.failureReason,
    this.retryCount = 0,
    required this.idempotencyKey,
  });

  /// Creates a new clothing item with auto-generated IDs.
  factory ClothingItem.create({
    required String userId,
    required String imageUrl,
    required String processedImageUrl,
    required String thumbnailUrl,
    required String category,
    required List<String> colors,
    required List<String> seasons,
    required String idempotencyKey,
  }) {
    final now = DateTime.now().toUtc();
    return ClothingItem(
      id: const Uuid().v4(),
      userId: userId,
      imageUrl: imageUrl,
      processedImageUrl: processedImageUrl,
      thumbnailUrl: thumbnailUrl,
      category: category,
      colors: colors,
      seasons: seasons,
      uploadedAt: now,
      updatedAt: now,
      processingState: ItemProcessingState.completed,
      idempotencyKey: idempotencyKey,
    );
  }

  /// Creates a copy of this item with the given fields replaced.
  ClothingItem copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? processedImageUrl,
    String? thumbnailUrl,
    String? category,
    List<String>? colors,
    List<String>? seasons,
    DateTime? uploadedAt,
    DateTime? updatedAt,
    ItemProcessingState? processingState,
    String? failureReason,
    int? retryCount,
    String? idempotencyKey,
  }) => ClothingItem(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    imageUrl: imageUrl ?? this.imageUrl,
    processedImageUrl: processedImageUrl ?? this.processedImageUrl,
    thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    category: category ?? this.category,
    colors: colors ?? this.colors,
    seasons: seasons ?? this.seasons,
    uploadedAt: uploadedAt ?? this.uploadedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    processingState: processingState ?? this.processingState,
    failureReason: failureReason ?? this.failureReason,
    retryCount: retryCount ?? this.retryCount,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
  );

  /// Serializes this item to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'imageUrl': imageUrl,
    'processedImageUrl': processedImageUrl,
    'thumbnailUrl': thumbnailUrl,
    'category': category,
    'colors': colors,
    'seasons': seasons,
    'uploadedAt': uploadedAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'processingState': processingState.name,
    'failureReason': failureReason,
    'retryCount': retryCount,
    'idempotencyKey': idempotencyKey,
  };

  /// Creates a [ClothingItem] from a JSON map.
  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    final processingStateName = json['processingState'] as String;
    final processingState = ItemProcessingState.values.firstWhere(
      (e) => e.name == processingStateName,
      orElse: () => ItemProcessingState.processingFailed,
    );

    final idempotencyKey = json['idempotencyKey'] as String?;
    if (idempotencyKey == null) {
      throw FormatException(
        'ClothingItem: field "idempotencyKey" is required for deduplication',
      );
    }

    return ClothingItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      processedImageUrl: json['processedImageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      category: json['category'] as String,
      colors: List<String>.from(json['colors'] as List),
      seasons: List<String>.from(json['seasons'] as List),
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      processingState: processingState,
      failureReason: json['failureReason'] as String?,
      retryCount: json['retryCount'] as int? ?? 0,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClothingItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          imageUrl == other.imageUrl &&
          processedImageUrl == other.processedImageUrl &&
          thumbnailUrl == other.thumbnailUrl &&
          category == other.category &&
          _listEquals(colors, other.colors) &&
          _listEquals(seasons, other.seasons) &&
          uploadedAt == other.uploadedAt &&
          updatedAt == other.updatedAt &&
          processingState == other.processingState &&
          failureReason == other.failureReason &&
          retryCount == other.retryCount &&
          idempotencyKey == other.idempotencyKey;

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    imageUrl,
    processedImageUrl,
    thumbnailUrl,
    category,
    Object.hashAll(colors),
    Object.hashAll(seasons),
    uploadedAt,
    updatedAt,
    processingState,
    failureReason,
    retryCount,
    idempotencyKey,
  );

  @override
  String toString() =>
      'ClothingItem(id: $id, category: $category, '
      'colors: $colors, seasons: $seasons, state: $processingState)';

  /// Helper method to compare two lists for equality.
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Processing state of a clothing item.
enum ItemProcessingState {
  /// Item is being uploaded.
  uploading,

  /// Item is being processed (background removal, tagging).
  processing,

  /// Item has been successfully processed.
  completed,

  /// Item processing failed.
  processingFailed,
}
