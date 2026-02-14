# Authentication Service

<cite>
**Referenced Files in This Document**
- [auth_service.dart](file://lib/core/auth/auth_service.dart)
- [auth_providers.dart](file://lib/core/auth/auth_providers.dart)
- [auth_error.dart](file://lib/core/auth/models/auth_error.dart)
- [user_profile.dart](file://lib/core/auth/models/user_profile.dart)
- [age_verification_service.dart](file://lib/core/auth/age_verification_service.dart)
- [auth_service_test.dart](file://test/core/auth/auth_service_test.dart)
- [auth_service_social_test.dart](file://test/core/auth/auth_service_social_test.dart)
- [main.dart](file://lib/main.dart)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Architecture Overview](#architecture-overview)
5. [Detailed Component Analysis](#detailed-component-analysis)
6. [Dependency Analysis](#dependency-analysis)
7. [Performance Considerations](#performance-considerations)
8. [Troubleshooting Guide](#troubleshooting-guide)
9. [Conclusion](#conclusion)

## Introduction
This document provides comprehensive documentation for the Authentication Service in StyleSync, a Flutter application focused on secure API key management with encrypted cloud backup. The authentication system integrates Firebase Authentication and Firestore to manage user accounts, profiles, and compliance requirements including age verification. The service supports email/password authentication, social authentication (Google and Apple), user profile management, and consent handling for privacy features.

## Project Structure
The authentication service is organized within the core module of the Flutter application, following a layered architecture pattern:

```mermaid
graph TB
subgraph "lib/core/auth"
AS[auth_service.dart]
AP[auth_providers.dart]
AE[models/auth_error.dart]
UP[models/user_profile.dart]
AVS[age_verification_service.dart]
end
subgraph "lib"
MAIN[main.dart]
end
subgraph "test/core/auth"
AT[auth_service_test.dart]
AST[auth_service_social_test.dart]
end
AS --> AE
AS --> UP
AS --> AVS
AP --> AS
AP --> AVS
AT --> UP
AT --> AE
AST --> AS
```

**Diagram sources**
- [auth_service.dart](file://lib/core/auth/auth_service.dart#L1-L381)
- [auth_providers.dart](file://lib/core/auth/auth_providers.dart#L1-L290)
- [auth_error.dart](file://lib/core/auth/models/auth_error.dart#L1-L71)
- [user_profile.dart](file://lib/core/auth/models/user_profile.dart#L1-L147)
- [age_verification_service.dart](file://lib/core/auth/age_verification_service.dart#L1-L252)

**Section sources**
- [auth_service.dart](file://lib/core/auth/auth_service.dart#L1-L381)
- [auth_providers.dart](file://lib/core/auth/auth_providers.dart#L1-L290)

## Core Components
The authentication service consists of several key components working together to provide comprehensive user authentication and management capabilities:

### Authentication Service Interface
The `AuthService` abstract interface defines the contract for authentication operations, including email/password authentication, social authentication, user profile management, and consent handling. The interface ensures type safety and provides clear separation of concerns between the authentication logic and external dependencies.

### Authentication Service Implementation
The `AuthServiceImpl` class provides the concrete implementation using Firebase Authentication and Firestore. It handles user authentication flows, profile creation and retrieval, age verification integration, and error mapping from Firebase exceptions to application-specific errors.

### Authentication State Management
The `AuthStateNotifier` class manages authentication state reactively using Riverpod's StateNotifier pattern. It provides loading states, error handling, and automatic state synchronization with Firestore user profiles.

### User Profile Model
The `UserProfile` class encapsulates user-related information stored in Firestore, including authentication status, onboarding completion, consent preferences, and age verification state. It provides serialization/deserialization capabilities and immutability through copy operations.

### Age Verification Service
The `AgeVerificationService` interface and its implementation handle 18+ age verification with self-reported DOB validation, third-party verification integration, session-based cooldown prevention, and Firestore-based persistence of verification states.

**Section sources**
- [auth_service.dart](file://lib/core/auth/auth_service.dart#L11-L71)
- [auth_providers.dart](file://lib/core/auth/auth_providers.dart#L55-L184)
- [user_profile.dart](file://lib/core/auth/models/user_profile.dart#L7-L147)
- [age_verification_service.dart](file://lib/core/auth/age_verification_service.dart#L10-L45)

## Architecture Overview
The authentication service follows a clean architecture pattern with clear separation between presentation, domain, and data layers:

```mermaid
graph TB
subgraph "Presentation Layer"
UI[UI Components]
AN[AuthStateNotifier]
end
subgraph "Domain Layer"
AS[AuthService]
UPS[UserProfile]
AE[AuthError]
AVS[AgeVerificationService]
end
subgraph "Data Layer"
FA[Firebase Auth]
FS[Firebase Firestore]
end
UI --> AN
AN --> AS
AS --> FA
AS --> FS
AS --> AVS
AVS --> FS
UPS --> FS
AE --> AS
```

**Diagram sources**
- [auth_providers.dart](file://lib/core/auth/auth_providers.dart#L55-L184)
- [auth_service.dart](file://lib/core/auth/auth_service.dart#L74-L381)
- [age_verification_service.dart](file://lib/core/auth/age_verification_service.dart#L47-L252)

The architecture implements several key design principles:

- **Dependency Injection**: Services accept Firebase instances through constructor parameters, enabling easy mocking and testing
- **Separation of Concerns**: Authentication logic is separated from UI state management
- **Immutability**: User profiles are immutable data structures with copy operations for state updates
- **Reactive State Management**: Riverpod providers enable reactive UI updates based on authentication state changes

## Detailed Component Analysis

### Authentication Service Implementation
The `AuthServiceImpl` class serves as the central coordinator for all authentication operations, implementing the `AuthService` interface with comprehensive error handling and Firebase integration.

#### Core Authentication Operations
The service provides five primary authentication methods:
- Email/password sign-in and sign-up with comprehensive error mapping
- Social authentication placeholders for Google and Apple (currently unimplemented)
- User profile management with Firestore integration
- Consent management for privacy features

#### Error Handling Strategy
The implementation includes sophisticated error handling through the `_mapFirebaseAuthError` method, which converts Firebase-specific exceptions into application-wide `AuthError` instances with standardized error codes. This approach ensures consistent error reporting across the entire application.

#### Transaction-Based Profile Management
The `_getUserProfileFromUser` method uses Firestore transactions to ensure atomic profile creation and retrieval, preventing race conditions and maintaining data consistency during user authentication.

```mermaid
sequenceDiagram
participant UI as UI Component
participant AN as AuthStateNotifier
participant AS as AuthServiceImpl
participant FA as Firebase Auth
participant FS as Firestore
UI->>AN : signInWithEmail(email, password)
AN->>AS : signInWithEmail(email, password)
AS->>FA : signInWithEmailAndPassword()
FA-->>AS : UserCredential
AS->>FS : getTransaction(users/doc)
FS-->>AS : UserProfile or create new
AS-->>AN : UserProfile
AN-->>UI : AuthState.authenticated(profile)
Note over AS,FS : Transaction ensures atomic profile creation
```

**Diagram sources**
- [auth_service.dart](file://lib/core/auth/auth_service.dart#L94-L112)
- [auth_service.dart](file://lib/core/auth/auth_service.dart#L339-L379)

**Section sources**
- [auth_service.dart](file://lib/core/auth/auth_service.dart#L74-L381)

### Authentication State Management
The `AuthStateNotifier` class implements Riverpod's StateNotifier pattern to provide reactive authentication state management throughout the application.

#### State Lifecycle
The notifier manages four distinct states:
- **Initial**: Application startup state before authentication check
- **Unauthenticated**: User not signed in
- **Authenticated**: User successfully authenticated with profile data
- **Error**: Authentication operation failed with error details
- **Loading**: Authentication operation in progress

#### State Synchronization
The notifier automatically synchronizes UI state with Firestore user profiles, ensuring that authentication state reflects the most current user data. This includes automatic profile updates when consent preferences change.

```mermaid
stateDiagram-v2
[*] --> Initial
Initial --> Unauthenticated : isSignedIn() = false
Initial --> Loading : initialize()
Loading --> Authenticated : signInWithEmail()
Loading --> Unauthenticated : signOut()
Loading --> Error : authentication error
Unauthenticated --> Loading : signInWithEmail()
Unauthenticated --> Loading : signUpWithEmail()
Authenticated --> Loading : signOut()
Authenticated --> Error : updateConsent error
Error --> Loading : retry operation
Error --> Unauthenticated : clear error
```

**Diagram sources**
- [auth_providers.dart](file://lib/core/auth/auth_providers.dart#L190-L277)

**Section sources**
- [auth_providers.dart](file://lib/core/auth/auth_providers.dart#L55-L290)

### User Profile Management
The `UserProfile` class provides a comprehensive data model for user information, designed for immutable data structures and seamless Firestore integration.

#### Data Model Design
The profile includes essential user information:
- Unique user identifier (Firebase UID)
- Email address for communication
- Creation timestamp with server synchronization
- Onboarding completion status
- Privacy consent preferences for face detection and biometric processing
- Age verification status for compliance

#### Serialization and Validation
The class implements robust serialization through `toMap()` and deserialization through `fromMap()` factory constructors, with comprehensive input validation to ensure data integrity. The `fromMap` method handles both string and Timestamp formats for createdAt fields, providing flexibility for different Firestore data types.

```mermaid
classDiagram
class UserProfile {
+String userId
+String email
+DateTime createdAt
+bool onboardingComplete
+bool faceDetectionConsentGranted
+bool biometricConsentGranted
+bool is18PlusVerified
+copyWith() UserProfile
+toMap() Map~String, dynamic~
+fromMap(map) UserProfile
}
class AuthError {
+String message
+String? code
+toString() String
}
class AuthErrorCode {
<<enumeration>>
+emailAlreadyInUse
+invalidEmail
+weakPassword
+userDisabled
+userNotFound
+wrongPassword
+operationNotAllowed
+underAge
+notImplemented
+generalError
}
UserProfile --> AuthError : "validates against"
AuthError --> AuthErrorCode : "uses codes"
```

**Diagram sources**
- [user_profile.dart](file://lib/core/auth/models/user_profile.dart#L7-L147)
- [auth_error.dart](file://lib/core/auth/models/auth_error.dart#L21-L71)

**Section sources**
- [user_profile.dart](file://lib/core/auth/models/user_profile.dart#L1-L147)
- [auth_error.dart](file://lib/core/auth/models/auth_error.dart#L1-L71)

### Age Verification Service
The `AgeVerificationService` interface and implementation provide comprehensive age verification capabilities with built-in security measures.

#### Verification Methods
The service supports two primary verification approaches:
- **Self-reported DOB verification**: Primary method using user-provided date of birth
- **Third-party verification**: Appeal mechanism for failed verifications

#### Security Measures
The implementation includes several security features:
- **Session-based cooldown**: Prevents brute-force attempts with 24-hour cooldown periods
- **Fail-closed policy**: Assumes active cooldown during system failures for security
- **Input validation**: Comprehensive validation of date inputs and reasonableness checks
- **Firestore persistence**: Secure storage of verification states and cooldown timestamps

```mermaid
flowchart TD
Start([Age Verification Request]) --> ValidateDOB["Validate Date of Birth"]
ValidateDOB --> FutureCheck{"Date in Future?"}
FutureCheck --> |Yes| InvalidInput["Throw Invalid Input Error"]
FutureCheck --> |No| CheckCooldown["Check Active Cooldown"]
CheckCooldown --> CooldownActive{"Active Cooldown?"}
CooldownActive --> |Yes| CooldownError["Throw Cooldown Error"]
CooldownActive --> |No| CalculateAge["Calculate Age"]
CalculateAge --> IsAdult{"Age >= 18?"}
IsAdult --> |Yes| Success["Return True"]
IsAdult --> |No| RecordCooldown["Record Cooldown"]
RecordCooldown --> UnderAgeError["Throw Under Age Error"]
InvalidInput --> End([End])
CooldownError --> End
Success --> End
UnderAgeError --> End
```

**Diagram sources**
- [age_verification_service.dart](file://lib/core/auth/age_verification_service.dart#L63-L94)

**Section sources**
- [age_verification_service.dart](file://lib/core/auth/age_verification_service.dart#L1-L252)

## Dependency Analysis
The authentication service demonstrates excellent dependency management through dependency injection and modular design:

```mermaid
graph TB
subgraph "External Dependencies"
FA[Firebase Auth]
FS[Firebase Firestore]
LOG[Logging Library]
end
subgraph "Internal Dependencies"
AS[AuthService]
AN[AuthStateNotifier]
UPS[UserProfile]
AE[AuthError]
AVS[AgeVerificationService]
end
subgraph "Application Integration"
RP[Riverpod Providers]
UI[UI Components]
end
AS --> FA
AS --> FS
AS --> LOG
AN --> AS
AN --> AVS
AN --> RP
AS --> AE
AS --> UPS
AVS --> FS
AVS --> AE
UI --> RP
```

**Diagram sources**
- [auth_service.dart](file://lib/core/auth/auth_service.dart#L1-L9)
- [auth_providers.dart](file://lib/core/auth/auth_providers.dart#L1-L7)
- [age_verification_service.dart](file://lib/core/auth/age_verification_service.dart#L1-L8)

### Coupling and Cohesion
The service maintains low coupling through:
- Interface-based design enabling easy mocking and testing
- Constructor injection for external dependencies
- Clear separation between authentication logic and state management
- Modular organization of related functionality

### Testing Strategy
The authentication service includes comprehensive test coverage:
- Unit tests for data models and error handling
- Integration tests for social authentication placeholders
- Mock-based testing for external dependencies
- Property-based testing for validation logic

**Section sources**
- [auth_service_test.dart](file://test/core/auth/auth_service_test.dart#L1-L82)
- [auth_service_social_test.dart](file://test/core/auth/auth_service_social_test.dart#L1-L45)

## Performance Considerations
The authentication service incorporates several performance optimization strategies:

### Asynchronous Operations
All authentication operations are asynchronous, preventing UI blocking and ensuring responsive user experiences. The use of Riverpod's FutureProvider enables efficient caching and automatic refresh of authentication state.

### Firestore Optimization
The service leverages Firestore's server-side timestamp functionality to maintain consistent time across client and server environments. Transaction-based operations ensure data consistency without requiring manual conflict resolution.

### Memory Management
Immutable data structures minimize memory allocation overhead and prevent accidental state mutations. The copyWith pattern enables efficient state updates without full object recreation.

### Error Recovery
Fail-closed security policies during network failures prevent potential security vulnerabilities while maintaining system reliability. Logging integration enables monitoring and debugging of authentication operations.

## Troubleshooting Guide

### Common Authentication Issues
The service provides comprehensive error handling with specific error codes for different failure scenarios:

#### Firebase Authentication Errors
- **Email Already In Use**: Occurs when attempting to register with an existing email address
- **Invalid Email**: Email format validation failures
- **Weak Password**: Password strength requirements not met
- **User Not Found**: Attempted sign-in with non-existent account
- **Wrong Password**: Incorrect password provided

#### Age Verification Errors
- **Under Age**: User attempts to access application without meeting age requirements
- **Cooldown Active**: User blocked due to excessive failed verification attempts
- **Invalid Input**: Date of birth validation failures

#### Social Authentication Limitations
The current implementation intentionally throws `AuthErrorCode.notImplemented` for Google and Apple authentication methods, indicating planned future enhancements.

### Debugging Strategies
The service includes comprehensive logging through the Dart logging library, enabling detailed tracking of authentication operations and error conditions. Error messages include both user-friendly descriptions and machine-readable codes for programmatic handling.

**Section sources**
- [auth_service.dart](file://lib/core/auth/auth_service.dart#L292-L336)
- [auth_error.dart](file://lib/core/auth/models/auth_error.dart#L21-L71)
- [auth_service_social_test.dart](file://test/core/auth/auth_service_social_test.dart#L22-L42)

## Conclusion
The StyleSync Authentication Service demonstrates robust architecture design with clear separation of concerns, comprehensive error handling, and reactive state management. The service successfully integrates Firebase Authentication and Firestore to provide secure user authentication while maintaining extensibility for future enhancements including social authentication methods and advanced age verification features.

The implementation prioritizes security through fail-closed policies, comprehensive input validation, and session-based rate limiting. The reactive state management approach ensures consistent user experiences across different authentication states while maintaining data integrity through transaction-based operations.

Future development should focus on implementing the social authentication methods currently marked as not implemented, expanding the age verification service with additional third-party integrations, and enhancing the error reporting system with more granular diagnostic information.