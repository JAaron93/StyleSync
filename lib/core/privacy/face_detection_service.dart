import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Exception thrown when face detection fails.
class FaceDetectionException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  FaceDetectionException(this.message, [this.originalError, this.stackTrace]);

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('FaceDetectionException: $message');
    
    if (originalError != null) {
      buffer.write(' (original: $originalError)');
    }
    
    if (stackTrace != null) {
      buffer.write('\nStackTrace: $stackTrace');
    }
    
    return buffer.toString();
  }
}

/// Service for detecting faces in images using ML Kit.
///
/// This service performs on-device face detection for privacy protection.
/// It only returns a boolean indicating whether a face was detected,
/// without extracting any biometric data or face embeddings.
abstract class FaceDetectionService {
  /// Detects if a face is present in the given image.
  ///
  /// Returns true if a face is detected, false otherwise.
  ///
  /// Processing is 100% on-device with no data sent to servers.
  /// No biometric data is extracted or stored.
  Future<bool> detectFace(File imageFile);

  /// Releases resources used by the face detector.
  /// Call when the service is no longer needed.
  Future<void> dispose();
}

class FaceDetectionServiceImpl implements FaceDetectionService {
  final FaceDetector _faceDetector;

  FaceDetectionServiceImpl({FaceDetector? faceDetector})
      : _faceDetector = faceDetector ?? FaceDetector(options: FaceDetectorOptions());

  @override
  Future<bool> detectFace(File imageFile) async {
    if (!await imageFile.exists()) {
      throw FaceDetectionException('Image file does not exist');
    }
    }

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);

      // Return true if at least one face was detected
      return faces.isNotEmpty;
    } on FaceDetectionException {
      rethrow;
    } catch (error, stackTrace) {
      // Sanitize error message - do not leak ML Kit internals
      throw FaceDetectionException(
        'Failed to process image for face detection',
        error,
        stackTrace,
      );
    }
  }

  @override
  Future<void> dispose() async {
    await _faceDetector.close();
  }
}
