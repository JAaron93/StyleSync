import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

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
}

class FaceDetectionServiceImpl implements FaceDetectionService {
  final FaceDetector _faceDetector;

  FaceDetectionServiceImpl({FaceDetector? faceDetector})
      : _faceDetector = faceDetector ?? FaceDetector(options: FaceDetectorOptions());

  @override
  Future<bool> detectFace(File imageFile) async {
    if (!await imageFile.exists()) {
      throw StateError('Image file does not exist: ${imageFile.path}');
    }

    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _faceDetector.processImage(inputImage);

    // Clean up resources
    await _faceDetector.close();

    // Return true if at least one face was detected
    return faces.isNotEmpty;
  }
}
