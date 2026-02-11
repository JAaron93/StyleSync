# Vertex AI API Contracts

## Base Configuration

**Base URL**: `https://us-central1-aiplatform.googleapis.com/v1`

**Authentication**: Bearer token (API Key)

**Headers**:
```
Authorization: Bearer {API_KEY}
Content-Type: application/json
```

---

## 1. Virtual Try-On API

### Endpoint: POST `/projects/{projectId}/locations/us-central1/publishers/google/models/virtual-try-on-preview-08-04:predict`

**Purpose**: Generate virtual try-on images

**Request Body**:
```json
{
  "instances": [
    {
      "userPhoto": {
        "bytesBase64Encoded": "base64_encoded_image"
      },
      "clothingImage": {
        "bytesBase64Encoded": "base64_encoded_image"
      },
      "parameters": {
        "sampleCount": 1,
        "aspectRatio": "1:1"
      }
    }
  ]
}
```

**Response (Success - 200)**:
```json
{
  "predictions": [
    {
      "bytesBase64Encoded": "base64_encoded_result_image",
      "mimeType": "image/jpeg"
    }
  ],
  "metadata": {
    "modelVersion": "virtual-try-on-preview-08-04"
  }
}
```

**Response (Error - 429 Rate Limit)**:
```json
{
  "error": {
    "code": 429,
    "message": "Quota exceeded for quota metric 'Generate requests' and limit 'Generate requests per day'",
    "status": "RESOURCE_EXHAUSTED",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.QuotaFailure",
        "violations": [
          {
            "subject": "projects/{projectId}",
            "description": "Daily quota exceeded"
          }
        ]
      }
    ]
  }
}
```

**Response (Error - 400 Invalid Request)**:
```json
{
  "error": {
    "code": 400,
    "message": "Invalid image format or size",
    "status": "INVALID_ARGUMENT"
  }
}
```

**Constraints**:
- User photo: Max 10MB, JPEG/PNG
- Clothing image: Max 10MB, JPEG/PNG
- Recommended resolution: 512x512 to 1024x1024
- Processing time: 10-30 seconds typical

---

## 2. Gemini Image Generation API

### Endpoint: POST `/projects/{projectId}/locations/us-central1/publishers/google/models/{modelId}:generateContent`

**Models**:
- `gemini-3-pro-image-preview` (high quality, up to 4096px)
- `gemini-2.5-flash-image` (fast, up to 1024px)

**Request Body**:
```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "Generate an image of a person wearing this clothing item"
        },
        {
          "inlineData": {
            "mimeType": "image/jpeg",
            "data": "base64_encoded_clothing_image"
          }
        },
        {
          "inlineData": {
            "mimeType": "image/jpeg",
            "data": "base64_encoded_user_photo"
          }
        }
      ]
    }
  ],
  "generationConfig": {
    "temperature": 0.4,
    "topK": 32,
    "topP": 1,
    "maxOutputTokens": 2048,
    "responseMimeType": "image/jpeg"
  }
}
```

**Response (Success - 200)**:
```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "inlineData": {
              "mimeType": "image/jpeg",
              "data": "base64_encoded_result_image"
            }
          }
        ]
      },
      "finishReason": "STOP",
      "safetyRatings": [
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "probability": "NEGLIGIBLE"
        }
      ]
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 256,
    "candidatesTokenCount": 512,
    "totalTokenCount": 768
  }
}
```

**Response (Error - 429 Rate Limit)**:
```json
{
  "error": {
    "code": 429,
    "message": "Resource has been exhausted (e.g. check quota)",
    "status": "RESOURCE_EXHAUSTED"
  }
}
```

---

## 3. Model Availability Check

### Endpoint: GET `/projects/{projectId}/locations/us-central1/publishers/google/models`

**Purpose**: List available models for the API key

**Response (Success - 200)**:
```json
{
  "models": [
    {
      "name": "projects/{projectId}/locations/us-central1/publishers/google/models/virtual-try-on-preview-08-04",
      "displayName": "Virtual Try-On Preview",
      "description": "Dedicated virtual try-on model",
      "supportedActions": ["predict"]
    },
    {
      "name": "projects/{projectId}/locations/us-central1/publishers/google/models/gemini-3-pro-image-preview",
      "displayName": "Gemini 3 Pro Image",
      "description": "High-quality image generation",
      "supportedActions": ["generateContent"]
    },
    {
      "name": "projects/{projectId}/locations/us-central1/publishers/google/models/gemini-2.5-flash-image",
      "displayName": "Gemini 2.5 Flash Image",
      "description": "Fast image generation",
      "supportedActions": ["generateContent"]
    }
  ]
}
```

**Response (Error - 401 Unauthorized)**:
```json
{
  "error": {
    "code": 401,
    "message": "Request had invalid authentication credentials",
    "status": "UNAUTHENTICATED"
  }
}
```

**Response (Error - 403 Forbidden)**:
```json
{
  "error": {
    "code": 403,
    "message": "Vertex AI API has not been used in project {projectId} before or it is disabled",
    "status": "PERMISSION_DENIED",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.Help",
        "links": [
          {
            "description": "Google developers console API activation",
            "url": "https://console.developers.google.com/apis/api/aiplatform.googleapis.com/overview?project={projectId}"
          }
        ]
      }
    ]
  }
}
```

---

## 4. Error Handling

### Common Error Codes

**400 - INVALID_ARGUMENT**:
- Invalid image format
- Image too large
- Missing required fields
- Invalid parameters

**401 - UNAUTHENTICATED**:
- Invalid API key
- Expired API key
- Missing authentication header

**403 - PERMISSION_DENIED**:
- Vertex AI API not enabled
- Insufficient permissions
- Project billing not enabled

**429 - RESOURCE_EXHAUSTED**:
- Daily quota exceeded
- Rate limit exceeded
- Concurrent request limit exceeded

**500 - INTERNAL**:
- Server error
- Model unavailable
- Processing failure

**503 - UNAVAILABLE**:
- Service temporarily unavailable
- Maintenance mode

### Retry Strategy

**Retryable Errors**: 429, 500, 503
**Non-Retryable Errors**: 400, 401, 403

**Retry Logic**:
```dart
import 'dart:math';

// Result types (should match data-models.dart)
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}

// Error types
sealed class AppError {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const AppError(this.message, {this.code, this.originalError});
}

class NetworkError extends AppError {
  const NetworkError(super.message, {super.code, super.originalError});
}

class APIError extends AppError {
  final int? statusCode;
  const APIError(super.message, {this.statusCode, super.code, super.originalError});
}

// Helper: Check if error is retryable
bool isRetryable(dynamic e) {
  // Check for HTTP status codes
  if (e is APIError) {
    return e.statusCode == 429 || e.statusCode == 500 || e.statusCode == 503;
  }
  
  // Check for network errors
  if (e is NetworkError) {
    return true;
  }
  
  // Check for common exception types
  if (e.toString().contains('SocketException') ||
      e.toString().contains('TimeoutException') ||
      e.toString().contains('HttpException')) {
    return true;
  }
  
  return false;
}

// Helper: Map exception to AppError
AppError mapError(dynamic e) {
  if (e is AppError) {
    return e;
  }
  
  // Parse HTTP errors
  if (e.toString().contains('429')) {
    return APIError('Rate limit exceeded', statusCode: 429, code: 'RESOURCE_EXHAUSTED', originalError: e);
  }
  
  if (e.toString().contains('500')) {
    return APIError('Server error', statusCode: 500, code: 'INTERNAL', originalError: e);
  }
  
  if (e.toString().contains('503')) {
    return APIError('Service unavailable', statusCode: 503, code: 'UNAVAILABLE', originalError: e);
  }
  
  if (e.toString().contains('401')) {
    return APIError('Unauthorized', statusCode: 401, code: 'UNAUTHENTICATED', originalError: e);
  }
  
  if (e.toString().contains('403')) {
    return APIError('Forbidden', statusCode: 403, code: 'PERMISSION_DENIED', originalError: e);
  }
  
  if (e.toString().contains('400')) {
    return APIError('Bad request', statusCode: 400, code: 'INVALID_ARGUMENT', originalError: e);
  }
  
  // Network errors
  if (e.toString().contains('SocketException') ||
      e.toString().contains('TimeoutException') ||
      e.toString().contains('HttpException')) {
    return NetworkError('Network error: ${e.toString()}', code: 'NETWORK_ERROR', originalError: e);
  }
  
  // Generic error
  return APIError('Unknown error: ${e.toString()}', code: 'UNKNOWN', originalError: e);
}

// Retry with exponential backoff
Future<Result<T>> retryWithBackoff<T>({
  required Future<T> Function() operation,
  int maxAttempts = 3,
  Duration baseDelay = const Duration(seconds: 1),
}) async {
  for (int attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      final result = await operation();
      return Success(result);
    } catch (e) {
      if (attempt == maxAttempts - 1 || !isRetryable(e)) {
        return Failure(mapError(e));
      }
      
      // Exponential backoff with jitter
      final delay = baseDelay * pow(2, attempt);
      final jitter = Random().nextDouble() * 0.25 * delay.inMilliseconds;
      await Future.delayed(delay + Duration(milliseconds: jitter.toInt()));
    }
  }
  
  // This should never be reached, but for type safety
  throw StateError('Retry loop completed without returning');
}
```

---

## 5. Client-Side Caching

### Cache Key Generation

```dart
String generateCacheKey({
  required String userId,
  required String photoSHA256,
  required String itemId,
  required int itemVersion,
  required GenerationMode mode,
}) {
  return '$userId:$photoSHA256:$itemId:$itemVersion:${mode.name}';
}
```

### Cache Storage

**Location**: Device local storage (not Firebase)

**Structure**:
```json
{
  "cacheKey": "userId:photoHash:itemId:version:mode",
  "imageUrl": "local_file_path",
  "createdAt": "ISO8601 timestamp",
  "expiresAt": "ISO8601 timestamp",
  "metadata": {
    "modelUsed": "string",
    "generationTime": "number (ms)"
  }
}
```

**TTL by Mode**:
- Try-On: 24 hours
- Thumbnails: 7 days
- Clothing: Indefinite (until item deleted)

**Eviction Policy**: LRU with 100MB size limit per user

---

## 6. Request/Response Examples

### Example: Successful Try-On Generation

**Request**:
```bash
curl -X POST \
  "https://us-central1-aiplatform.googleapis.com/v1/projects/my-project/locations/us-central1/publishers/google/models/virtual-try-on-preview-08-04:predict" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "instances": [{
      "userPhoto": {"bytesBase64Encoded": "..."},
      "clothingImage": {"bytesBase64Encoded": "..."},
      "parameters": {"sampleCount": 1, "aspectRatio": "1:1"}
    }]
  }'
```

**Response**:
```json
{
  "predictions": [{
    "bytesBase64Encoded": "iVBORw0KGgoAAAANSUhEUgAA...",
    "mimeType": "image/jpeg"
  }],
  "metadata": {
    "modelVersion": "virtual-try-on-preview-08-04"
  }
}
```

### Example: Quota Exceeded

**Response**:
```json
{
  "error": {
    "code": 429,
    "message": "Quota exceeded for quota metric 'Generate requests' and limit 'Generate requests per day'",
    "status": "RESOURCE_EXHAUSTED",
    "details": [{
      "@type": "type.googleapis.com/google.rpc.QuotaFailure",
      "violations": [{
        "subject": "projects/my-project",
        "description": "Daily quota exceeded. Resets at midnight UTC."
      }]
    }]
  }
}
```

**Client Handling**:
1. Parse error code (429)
2. Extract reset time from error details
3. Update local quota tracker
4. Display rate limit modal to user
5. Disable try-on features until reset

