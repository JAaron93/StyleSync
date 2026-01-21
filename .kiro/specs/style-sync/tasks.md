# Implementation Plan: StyleSync

## Overview

This implementation plan breaks down the StyleSync feature into discrete, incremental coding tasks. Each task builds on previous work and includes specific requirements references for traceability.

## Tasks

- [x] 1. Set up Flutter project and development environment
  - Create Flutter project with minimum SDK version (Flutter 3.10+)
  - Configure Firebase project (Authentication, Firestore, Storage, Remote Config)
  - Set up development environment with Python venv for any backend scripts
  - Add core dependencies: firebase_core, firebase_auth, firebase_storage, cloud_firestore, flutter_secure_storage, riverpod
  - Configure platform-specific settings (iOS 14+, Android 8.0+)
  - Set up CI/CD pipeline with GitHub Actions or similar
  - _Requirements: 10.1, 10.2, 10.3, 10.5_

- [x] 2. Implement secure storage foundation
  - [x] 2.1 Create SecureStorageService interface and platform implementations
    - Implement iOS Keychain integration with kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    - Implement Android Keystore with StrongBox detection and fallback
    - Add SecureStorageBackend enum (strongBox, hardwareBacked, software)
    - Implement runtime StrongBox detection with try-catch fallback
    - Add logging for storage backend selection
    - _Requirements: 2.5, 2.8, 2.9, 4.4_
  
  - [x] 2.2 Write property test for secure storage backend selection
    - **Property 24: API Key Secure Storage Hardware Backing**
    - **Validates: Requirements 4.4**
  
  - [x] 2.3 Write unit tests for secure storage operations
    - Test write/read/delete operations
    - Test biometric authentication requirement
    - Test platform-specific implementations
    - _Requirements: 2.5, 2.8, 2.9_

- [x] 3. Implement key derivation and encryption services
  - [x] 3.1 Create KeyDerivationService with Argon2id and PBKDF2 support
    - Add argon2_ffi_base dependency for Argon2id
    - Implement platform detection (Web → PBKDF2, others → try Argon2id)
    - Implement Argon2id with params: time=3, memory=64MB, parallelism=4
    - Implement PBKDF2 fallback with 600,000 iterations
    - Generate and manage 32-byte cryptographic salts
    - Store KDF metadata with encrypted backups
    - _Requirements: 2.12, 2.13_
  
  - [x] 3.2 Create AES-GCM encryption service
    - Implement AES-256-GCM encryption/decryption
    - Generate 96-bit cryptographically-random nonces
    - Implement nonce prepending to ciphertext
    - Add nonce reuse prevention checks
    - _Requirements: 2.12_
  
  - [x] 3.3 Write property test for encryption round-trip
    - **Property 3: Cloud Backup Encryption Round-Trip**
    - **Validates: Requirements 2.12, 2.13, 2.14, 2.16**
  
  - [x] 3.4 Write property test for KDF consistency
    - **Property 23: Argon2id Key Derivation Consistency**
    - **Validates: Requirements 2.12**

- [ ] 4. Implement BYOK system (API key management)
  - [ ] 4.1 Create BYOKManager service
    - Implement API key storage/retrieval from SecureStorage
    - Generate idempotency keys for operations
    - Implement device-specific storage by default
    - _Requirements: 2.1, 2.7, 2.10, 2.15_
  
  - [ ] 4.2 Create APIKeyValidator service
    - Implement format validation (check key structure)
    - Implement functional verification (test API call to Vertex AI models list endpoint)
    - Return specific error messages for validation failures
    - _Requirements: 2.3, 2.4, 2.5, 2.6_
  
  - [ ] 4.3 Create CloudBackupService
    - Implement backup encryption with user passphrase
    - Store encrypted backup in Firebase Storage (users/{userId}/api_key_backup.json)
    - Include salt, KDF metadata, encrypted data, nonce in backup blob
    - Implement restore with passphrase
    - Implement backup deletion
    - _Requirements: 2.11, 2.12, 2.13, 2.14, 2.16, 2.17, 2.18, 2.19_
  
  - [ ] 4.4 Write property test for API key validation pipeline
    - **Property 2: API Key Validation Pipeline**
    - **Validates: Requirements 2.3, 2.4, 2.5, 2.6, 2.7**
  
  - [ ] 4.5 Write unit tests for BYOK operations
    - Test API key storage and retrieval
    - Test cloud backup enable/disable
    - Test sign-out options
    - _Requirements: 2.15, 2.17, 2.18_

- [ ] 5. Implement onboarding flow
  - [ ] 5.1 Create onboarding screens
    - Welcome screen with app features overview
    - API key tutorial screen with step-by-step instructions
    - Links to Google Cloud Console and Vertex AI setup
    - Explanation of Free vs Paid tier differences
    - API key input screen with validation
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_
  
  - [ ] 5.2 Create OnboardingController
    - Track onboarding completion state
    - Persist onboarding status across app restarts
    - Navigate between onboarding screens
    - _Requirements: 1.7_
  
  - [ ] 5.3 Write property test for onboarding persistence
    - **Property 1: Onboarding Persistence**
    - **Validates: Requirements 1.7**
  
  - [ ] 5.4 Write widget tests for onboarding screens
    - Test screen rendering
    - Test navigation flow
    - Test API key input validation
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

- [ ] 6. Checkpoint - Ensure all tests pass
  - [ ] All unit tests pass with >80% coverage
  - [ ] Property tests run for 100+ iterations without failures
  - [ ] Security tests validate API key protection and encryption round-trips
  - [ ] Manual verification of onboarding flow completed

- [ ] 7. UI prototyping and wireframes
  - [ ] 7.1 Create low-fidelity wireframes for core user flows
    - Onboarding flow (welcome → API key tutorial → key input)
    - Digital Closet flow (upload → face detection consent → background removal → tagging → item view)
    - Virtual Try-On flow (biometric consent → photo selection → clothing selection → generation → result display)
    - Rate Limit flow (80% warning banner → 100% modal with upgrade instructions)
    - Outfit Canvas flow (item selection → layering → saving)
    - Settings flow (API key management → cloud backup → usage history)
    - Age verification flows (18+ age gate → verification → access granted/denied)
    - _Requirements: 1.1-1.6, 3.1-3.18, 4.1-4.24, 5.1-5.18, 6.1-6.8_
  
  - [ ] 7.2 Create clickable prototype
    - Build interactive prototype using Figma, Adobe XD, or similar tool
    - Include all critical user flows and decision points
    - Demonstrate navigation between screens
    - Show modal interactions (consent dialogs, rate limit modal, error states)
    - Demonstrate COPPA flows for age-restricted users
    - Include loading states and progress indicators
    - _Requirements: 1.1-1.6, 3.1-3.18, 4.1-4.24, 5.1-5.18, 6.1-6.8_
  
  - [ ] 7.3 Draft API data contracts and component interfaces
    - Define data structures for API responses (clothing items, outfits, quota status, user profile)
    - Define component props and state interfaces
    - Document data flow between screens and services
    - Identify backend API endpoints needed (Firebase queries, Vertex AI calls)
    - Create mock data for prototype testing
    - _Requirements: 3.13-3.18, 4.6-4.24, 5.1-5.4, 6.1-6.8_
  
  - [ ] 7.4 Conduct user testing and validation
    - Test prototype with at least 3-5 users (mix of technical and non-technical)
    - Validate onboarding clarity (can users understand how to get API key?)
    - Validate consent flows (do users understand what they're consenting to?)
    - Validate COPPA workflows (is the VPC process friction-less but secure?)
    - Validate rate limit messaging (do users understand quota limits and upgrade path?)
    - Validate navigation and information architecture
    - Document feedback and iterate on wireframes
    - _Requirements: 1.1-1.6, 3.1-3.2, 4.1-4.2, 5.6-5.15, 4.19-4.24_
  
  - [ ] 7.5 Finalize design specifications
    - Document approved wireframes and user flows
    - Finalize API data contracts based on prototype feedback
    - Create design handoff documentation for task 23 (UI implementation)
    - Document any changes to backend requirements discovered during prototyping
    - Update component interfaces and data models if needed
    - _Requirements: All UI-related requirements, 4.19-4.24_
  
  **Acceptance Criteria**:
  - Low-fidelity wireframes completed for all core screens including COPPA
  - Clickable prototype demonstrates all critical user flows
  - API data contracts drafted and documented
  - At least one round of user testing completed with documented feedback
  - Design specifications finalized and ready for implementation in task 23
  
  **Deliverables**:
  - Wireframe files (Figma/Adobe XD/Sketch)
  - Clickable prototype link
  - API data contract documentation (JSON schemas or TypeScript interfaces)
  - User testing report with findings and recommendations
  - Design handoff document for developers
  
  **Note**: This task validates UX assumptions early before backend finalization. Findings may require updates to API designs and data contracts in tasks 9-22. Task 23 will implement the approved designs from this prototyping phase.

- [ ] 8. Implement Firebase Authentication and 18+ Age Gate
  - [ ] 8.1 Set up Firebase Authentication
    - Configure email/password authentication
    - Configure social authentication (Google, Apple)
    - Implement user sign-up and sign-in flows
    - Implement 18+ age verification step during signup
    - Deny access to users under 18
    - Associate user data with Firebase Auth UID
    - _Requirements: 7.1, 7.2, 7.3_
  
  - [ ] 8.2 Implement user profile management
    - Create UserProfile model with age and verification status
    - Store user profile in Firestore (users/{userId})
    - Track onboarding completion and 18+ verification state
    - _Requirements: 7.3_
  
  - [ ] 8.3 Write unit tests for authentication and age gate
    - Test sign-up and sign-in
    - Test 18+ age verification and rejection of minors
    - Test user profile creation
    - Test data association with user ID
    - _Requirements: 7.1, 7.2, 7.3_

- [ ] 9. Implement metadata stripping and privacy services
  - [ ] 9.1 Create MetadataStripperService
    - Strip EXIF data (GPS, timestamps, device IDs)
    - Preserve only image pixel data
    - _Requirements: 3.4_
  
  - [ ] 9.2 Create FaceDetectionService using ML Kit
    - Add google_mlkit_face_detection dependency
    - Implement on-device face detection
    - Return boolean (face detected or not)
    - No biometric data extraction
    - _Requirements: 3.5, 3.6, 3.7_
  
  - [ ] 9.3 Create consent management services
    - FaceDetectionConsentDialog UI component
    - BiometricConsentManager for try-on consent
    - Track consent states in user profile
    - _Requirements: 3.1, 3.2, 4.1, 4.2_
  
  - [ ] 9.4 Write property test for EXIF metadata stripping
    - **Property 4: EXIF Metadata Stripping**
    - **Validates: Requirements 3.4**
  
  - [ ] 9.5 Write property test for face detection consent enforcement
    - **Property 5: Face Detection Consent Enforcement**
    - **Validates: Requirements 3.1, 3.2, 3.5, 3.6, 3.7**

- [ ] 10. Implement background removal service
  - [ ] 10.1 Create BackgroundRemovalService with TensorFlow Lite
    - Add tflite_flutter dependency
    - Bundle DeepLabV3+ segmentation model
    - Implement on-device background removal
    - Add 10-second timeout with fallback to original image
    - _Requirements: 3.8, 9.6, 9.7_
  
  - [ ] 10.2 Write property test for background removal timeout
    - **Property 20: Background Removal Timeout with Fallback**
    - **Validates: Requirements 9.6, 9.7**
  
  - [ ] 10.3 Write unit tests for background removal
    - Test successful removal
    - Test timeout behavior
    - Test fallback to original image
    - _Requirements: 3.8, 9.6, 9.7_

- [ ] 11. Implement auto-tagging service
  - [ ] 11.1 Create AutoTaggerService
    - Implement clothing category classification (tops, bottoms, shoes, accessories)
    - Implement color detection
    - Implement season suggestion
    - Restrict analysis to clothing attributes only (no biometric data)
    - _Requirements: 3.9, 3.10, 3.11, 3.12_
  
  - [ ] 11.2 Write property test for auto-tagger privacy invariant
    - **Property 6: Auto-Tagger Privacy Invariant**
    - **Validates: Requirements 3.10**
  
  - [ ] 11.3 Write unit tests for auto-tagging
    - Test category classification
    - Test color detection
    - Test season suggestion
    - _Requirements: 3.9, 3.11, 3.12_

- [ ] 12. Implement digital closet repository
  - [ ] 12.1 Create ClothingRepository with idempotency
    - Implement uploadClothing with idempotency key generation
    - Implement CRUD operations (create, read, update, delete)
    - Implement storage quota checking (500 items or 2GB)
    - Implement partial failure handling with retry logic
    - Store clothing items in Firestore and Firebase Storage
    - _Requirements: 3.13, 3.14, 3.15, 3.16, 3.17, 3.18_
  
  - [ ] 12.2 Implement upload flow with error recovery
    - Implement exponential backoff with jitter (1s, 2s, 4s)
    - Implement automatic background retry for processing failures
    - Implement manual retry option
    - Track item processing state (uploading, processing, completed, processingFailed)
    - _Requirements: 3.16, 8.3_
  
  - [ ] 12.3 Write property test for storage quota enforcement
    - **Property 7: Storage Quota Enforcement**
    - **Validates: Requirements 3.13, 3.14, 3.15**
  
  - [ ] 12.4 Write property test for CRUD consistency
    - **Property 25: Clothing Item CRUD Consistency**
    - **Validates: Requirements 3.16, 3.17, 3.18**
  
  - [ ] 12.5 Write unit tests for upload flow
    - Test successful upload
    - Test partial failure handling
    - Test retry logic
    - Test idempotency
    - _Requirements: 3.16, 8.3_

- [ ] 13. Checkpoint - Ensure all tests pass
  - [ ] All unit tests pass with >80% coverage
  - [ ] Property tests run for 100+ iterations without failures
  - [ ] Security tests validate API key protection and encryption round-trips
  - [ ] Manual verification of onboarding flow completed

- [ ] 14. Implement Vertex AI client and model availability service
  - [ ] 14.1 Create VertexAIClient
    - Implement direct client-to-AI communication
    - Implement TLS encryption with certificate validation
    - Implement certificate pinning with Remote Config
    - Implement fallback to standard TLS with security notification
    - Implement safe mode when pinning fails
    - _Requirements: 4.7, 4.8, 4.9, 4.11, 4.12, 4.13_
  
  - [ ] 14.2 Create ModelAvailabilityService
    - Implement model availability checking
    - Implement model selection with fallback (quality → speed → tryOn)
    - Validate at least one model is available
    - _Requirements: 4.12, 4.13_
  
  - [ ] 14.3 Create CertificatePinningService
    - Fetch pin-set from Firebase Remote Config
    - Implement certificate validation with multiple backup pins
    - Implement emergency pin update flow
    - Implement forced update flow for critical security updates
    - _Requirements: 4.9, 4.10, 4.11, 4.12_
  
  - [ ] 14.4 Write property test for certificate pinning failure handling
    - **Property 9: Certificate Pinning Failure Handling**
    - **Validates: Requirements 4.11, 4.12**
  
  - [ ] 14.5 Write unit tests for Vertex AI client
    - Test API call success
    - Test certificate pinning
    - Test emergency pin query behavior
    - Test safe mode
    - _Requirements: 4.7, 4.8, 4.9, 4.11, 4.12, 4.13_

- [ ] 15. Implement virtual try-on engine
  - [ ] 15.1 Create VirtualTryOnEngine
    - Implement try-on generation with model selection
    - Implement ephemeral photo processing (RAM only, no disk persistence)
    - Implement immediate photo deletion after generation
    - Implement client-side caching with SHA256 fingerprints
    - Implement client-side throttling
    - _Requirements: 4.6, 4.10, 4.11, 4.12, 4.13, 4.14, 4.15, 4.16, 4.17_
  
  - [ ] 15.2 Create ImageCacheService
    - Implement cache key generation (userId:photoSHA256:itemId:itemVersion:mode)
    - Implement TTL-based caching (24h default, configurable per mode)
    - Implement cache invalidation on item update/delete
    - Implement LRU eviction (100 entries or 50MB per user)
    - _Requirements: 4.14_
  
  - [ ] 15.3 Write property test for photo ephemeral processing
    - **Property 8: Photo Ephemeral Processing**
    - **Validates: Requirements 4.10, 4.11**
  
  - [ ] 15.4 Write property test for client-side caching
    - **Property 10: Client-Side Caching Reduces Redundant Calls**
    - **Validates: Requirements 4.14**
  
  - [ ] 15.5 Write property test for biometric consent
    - **Property 22: Biometric Consent Required for Try-On**
    - **Validates: Requirements 4.1, 4.2**
  
  - [ ] 15.6 Write unit tests for virtual try-on
    - Test try-on generation
    - Test photo deletion
    - Test caching behavior
    - Test throttling
    - _Requirements: 4.6, 4.10, 4.11, 4.14, 4.15, 4.16, 4.17_

- [ ] 16. Implement rate limit and quota management
  - [ ] 16.1 Create RateLimitHandler
    - Implement daily usage counter per API key
    - Implement quota estimation based on usage patterns
    - Implement 80% threshold warning
    - Implement 429 error interception
    - Implement quota reset at midnight UTC
    - Implement automatic feature re-enablement after reset
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.16_
  
  - [ ] 16.2 Create QuotaTracker
    - Store quota tracking in Firestore with random UUID (not API key)
    - Implement usage increment on API calls
    - Implement reset time calculation (midnight UTC)
    - Implement timezone-aware display (local time + UTC)
    - _Requirements: 5.1, 5.2, 5.3, 5.4_
  
  - [ ] 16.3 Create UsageHistoryService
    - Log quota events with timestamps
    - Provide usage history view in settings
    - _Requirements: 5.17, 5.18_
  
  - [ ] 17.4 Create rate limit UI components
    - Warning banner (80% threshold) with countdown timer
    - Rate limit modal (100% threshold) with usage stats and reset time
    - Display local time and UTC for clarity
    - _Requirements: 5.6, 5.10, 5.11, 5.12, 5.13, 5.14, 5.15_
  
  - [ ] 17.5 Write property test for quota threshold warning
    - **Property 11: Quota Threshold Warning**
    - **Validates: Requirements 5.5, 5.6**
  
  - [ ] 17.6 Write property test for quota reset re-enables features
    - **Property 12: Quota Reset Re-enables Features**
    - **Validates: Requirements 5.16**
  
  - [ ] 17.7 Write property test for quota state consistency
    - **Property 13: Quota State Consistency**
    - **Validates: Requirements 5.1, 5.2, 5.3, 5.17, 5.18, 5.19**
  
  - [ ] 17.8 Write property test for rate limit error handling
    - **Property 14: Rate Limit Error Handling**
    - **Validates: Requirements 5.7, 5.8, 5.9, 5.10, 5.15**

- [ ] 17. Checkpoint - Ensure all tests pass
  - [ ] All unit tests pass with >80% coverage
  - [ ] Property tests run for 100+ iterations without failures
  - [ ] Security tests validate API key protection and encryption round-trips
  - [ ] Manual verification of onboarding flow completed

- [ ] 18. Implement outfit brainstorming canvas
  - [ ] 18.1 Create OutfitCanvasController
    - Implement layering interface (base, mid, outer, accessories)
    - Implement drag-and-drop positioning
    - Implement layer reordering with invariant preservation
    - Implement outfit saving with custom names
    - _Requirements: 6.1, 6.2, 6.3, 6.4_
  
  - [ ] 18.2 Create OutfitRepository
    - Implement CRUD operations for outfits
    - Store outfits in Firestore
    - Generate outfit thumbnails
    - _Requirements: 6.4, 6.5_
  
  - [ ] 18.3 Create AIOutfitSuggestionService
    - Implement AI-powered missing piece suggestions
    - Use Gemini models for recommendations
    - Display suggestions with reasoning
    - _Requirements: 6.6, 6.7, 6.8_
  
  - [ ] 18.4 Write property test for outfit layer ordering invariant
    - **Property 15: Outfit Layer Ordering Invariant**
    - **Validates: Requirements 6.3**
  
  - [ ] 18.5 Write unit tests for outfit canvas
    - Test layering operations
    - Test outfit saving
    - Test AI suggestions
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8_

- [ ] 19. Implement account deletion and data management
  - [ ] 19.1 Create account deletion flow
    - Display confirmation dialog with timestamp and timeline explanation
    - Implement immediate primary data deletion (Firebase Storage, Firestore, Auth, local cache, logs, analytics)
    - Implement 30-day retention for backup archives and disaster-recovery replicas
    - Ensure backup data is inaccessible during retention period
    - Provide deletion confirmation with completion timestamp
    - _Requirements: 7.8, 7.9, 7.10, 7.11, 7.12_
  
  - [ ] 19.2 Write property test for immediate primary data removal
    - **Property 16: Account Deletion Immediate Primary Data Removal**
    - **Validates: Requirements 7.9, 7.10**
  
  - [ ] 19.3 Write property test for backup data inaccessibility
    - **Property 17: Backup Data Inaccessibility During Retention**
    - **Validates: Requirements 7.11**
  
  - [ ] 19.4 Write unit tests for account deletion
    - Test confirmation dialog
    - Test primary data deletion
    - Test backup retention
    - Test deletion confirmation
    - _Requirements: 7.8, 7.9, 7.10, 7.11, 7.12_

- [ ] 20. Implement error handling and reporting
  - [ ] 20.1 Create error handling infrastructure
    - Implement Result<T> type with Success and Failure
    - Implement AppError hierarchy (NetworkError, APIError, ValidationError, etc.)
    - Implement error recovery strategies (retry, fallback, user notification)
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_
  
  - [ ] 20.2 Create ErrorReporter with allow-list/deny-list
    - Implement diagnostic data collection with allow-list (app version, OS version, device model, error codes, sanitized stack traces, timestamp, anonymized crash IDs)
    - Implement deny-list enforcement (no user IDs, emails, API keys, tokens, image data, file paths, location, device serials)
    - Implement stack trace sanitization (strip emails, UUIDs, file paths)
    - Validate all fields against allow-list before transmission
    - _Requirements: 8.7, 8.8, 8.9, 8.10, 8.11_
  
  - [ ] 20.3 Write property test for error report allow-list enforcement
    - **Property 18: Error Report Allow-List Enforcement**
    - **Validates: Requirements 8.8, 8.9, 8.10, 8.11**
  
  - [ ] 20.4 Write unit tests for error handling
    - Test error recovery strategies
    - Test error reporting
    - Test allow-list/deny-list enforcement
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.7, 8.8, 8.9, 8.10, 8.11_

- [ ] 21. Implement performance optimizations
  - [ ] 21.1 Implement image loading with timeouts and fallbacks
    - Display cached images within 500ms
    - Show loading state if not rendered within 500ms
    - Fall back to low-res placeholders after 10 seconds
    - Surface retry control
    - _Requirements: 9.1, 9.2, 9.3_
  
  - [ ] 21.2 Implement image compression and caching
    - Compress images before upload
    - Implement lazy loading for lists
    - Implement image caching (try-ons: 24h, thumbnails: 7 days, clothing: indefinite)
    - Implement LRU eviction (100MB cache limit)
    - _Requirements: 9.4, 9.5, 9.6, 9.8_
  
  - [ ] 21.3 Write property test for image load timeout with fallback
    - **Property 19: Image Load Timeout with Fallback**
    - **Validates: Requirements 9.1, 9.2, 9.3**
  
  - [ ] 21.4 Write performance tests
    - Test image upload time (p50 < 3s, p95 < 5s)
    - Test background removal time (p50 < 3s, p95 < 5s)
    - Test closet load time (p50 < 300ms, p95 < 500ms)
    - Test app startup time (p50 < 1.5s, p95 < 2s)
    - Note: Performance targets are initial goals and may be adjusted based on device variance, network conditions, and image complexity.
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8_

- [ ] 22. Checkpoint - Ensure all tests pass
  - [ ] All unit tests pass with >80% coverage
  - [ ] Property tests run for 100+ iterations without failures
  - [ ] Security tests validate API key protection and encryption round-trips
  - [ ] Manual verification of onboarding flow completed

- [ ] 23. Implement UI screens and navigation
  - [ ] 23.1 Create main app screens
    - Digital Closet screen with grid view and filters
    - Virtual Try-On screen with photo selection and generation
    - Outfit Canvas screen with layering interface
    - Settings screen with API key management
    - Usage History screen with quota events
    - _Requirements: 3.17, 4.16, 6.1, 6.5_
  
  - [ ] 23.2 Implement navigation with go_router
    - Set up declarative routing
    - Implement deep linking
    - Handle authentication-based routing (including 18+ gate)
    - _Requirements: 1.6, 7.1_
  
  - [ ] 23.3 Write widget tests for main screens
    - Test screen rendering
    - Test user interactions
    - Test navigation flows
    - Test 18+ gate enforcement
    - _Requirements: 3.17, 4.16, 6.1, 6.5_

- [ ] 24. Implement Firebase Remote Config integration
  - [ ] 24.1 Set up Remote Config
    - Configure certificate pins
    - Configure cache TTLs per generation mode
    - Configure force update settings
    - Configure feature flags
    - _Requirements: 4.9, 4.10, 4.11, 4.12_
  
  - [ ] 24.2 Implement Remote Config fetching
    - Fetch on app startup
    - Implement periodic refresh
    - Handle fetch failures gracefully
    - _Requirements: 4.9, 4.10, 4.11, 4.12_
  
  - [ ] 24.3 Write unit tests for Remote Config
    - Test config fetching
    - Test default values
    - Test update handling
    - _Requirements: 4.9, 4.10, 4.11, 4.12_

- [ ] 25. Implement monitoring and analytics
  - [ ] 25.1 Set up Firebase Crashlytics
    - Configure crash reporting
    - Implement custom error logging
    - Add breadcrumbs for debugging
    - _Requirements: 8.6_
  
  - [ ] 25.2 Set up Firebase Performance Monitoring
    - Track image upload time
    - Track background removal time
    - Track closet load time
    - Track try-on generation time
    - Track app startup time
    - Set up performance alerts (p95 regressions > 20%)
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8_
  
  - [ ] 25.3 Set up Firebase Analytics
    - Track user flows
    - Track feature usage
    - Track quota events
    - Track secure storage backend selection
    - Track KDF selection
    - _Requirements: 5.17, 5.18_
  
  - [ ] 25.4 Write unit tests for monitoring
    - Test event logging
    - Test performance tracking
    - Test analytics events
    - _Requirements: 5.17, 5.18, 8.6, 9.1, 9.2, 9.3_

- [ ] 26. Final integration and end-to-end testing
  - [ ] 26.1 Implement end-to-end user flows
    - Test complete onboarding flow including 18+ age-gating
    - Test complete upload and try-on flow
    - Test complete outfit creation flow
    - Test complete account deletion flow
    - _Requirements: All_
  
  - [ ] 26.2 Write integration tests
    - Test Firebase integration
    - Test Vertex AI integration
    - Test secure storage integration
    - **Property 21: 18+ Age Verification** (validates requirement for strict age gating)
    - _Requirements: All_
  
  - [ ] 26.3 Perform security audit
    - Verify API key protection
    - Verify photo ephemeral processing
    - Verify EXIF stripping
    - Verify certificate pinning
    - Verify encryption implementation
    - _Requirements: 2.5, 2.8, 2.9, 3.4, 4.4, 4.8, 4.9, 4.10, 4.11, 4.12_

- [ ] 27. Final checkpoint - Ensure all tests pass
  - [ ] All unit tests pass with >80% coverage
  - [ ] Property tests run for 100+ iterations without failures
  - [ ] Security tests validate API key protection and encryption round-trips
  - [ ] Manual verification of onboarding flow completed

## Notes

- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- All property tests should run minimum 100 iterations
- Use Firebase Performance Monitoring for continuous performance tracking
