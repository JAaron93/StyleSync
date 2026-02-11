# StyleSync Design Documentation

## Overview

This directory contains all design documentation for the StyleSync application, created during Task 7 (UI Prototyping and Wireframes). These documents serve as the foundation for implementation in Task 23.

## Document Index

### 1. Wireframes (`wireframes.md`)
Low-fidelity wireframes for all core user flows including:
- Onboarding flow (welcome → API key tutorial → key input)
- Digital Closet flow (upload → face detection consent → background removal → tagging → item view)
- Virtual Try-On flow (biometric consent → photo selection → clothing selection → generation → result display)
- Rate Limit flow (80% warning banner → 100% modal with upgrade instructions)
- Outfit Canvas flow (item selection → layering → saving)
- Settings flow (API key management → cloud backup → usage history)
- Age verification flows (18+ age gate → verification → access granted/denied)
- Empty states, loading states, and error states

### 2. Prototype Specification (`prototype-spec.md`)
Comprehensive specifications for building a clickable prototype including:
- Artboard/frame requirements (~45 screens)
- Interactive elements and hotspots
- Navigation patterns and transitions
- Component library specifications
- Interaction patterns (gestures, micro-interactions)
- Prototype testing checklist
- Sharing and collaboration guidelines

### 3. API Contracts (`api-contracts.md`)
Complete API contract documentation including:
- Data model definitions
- Firebase API contracts (Firestore, Storage, Remote Config, Auth)
- Vertex AI API contracts (Virtual Try-On, Gemini Image Generation)
- Component interfaces
- State management with Riverpod
- Data flow diagrams
- Error code reference

### 4. Firebase Contracts (`firebase-contracts.md`)
Detailed Firebase service contracts including:
- Firestore collection schemas
- Security rules
- Indexes and queries
- Firebase Storage structure and security
- Remote Config parameters
- Authentication custom claims and blocking functions

### 5. Vertex AI Contracts (`vertex-ai-contracts.md`)
Detailed Vertex AI API contracts including:
- Virtual Try-On API endpoint specifications
- Gemini Image Generation API specifications
- Model availability checking
- Error handling and retry strategies
- Client-side caching specifications
- Request/response examples

### 6. Data Models (`data-models.dart`)
Dart data model definitions including:
- User models (UserProfile, AgeVerificationMethod)
- Clothing models (ClothingItem, ClothingTags, ItemProcessingState)
- Outfit models (Outfit, OutfitLayer, LayerType)
- API key and storage models (APIKeyConfig, CloudBackupMetadata, KDFMetadata)
- Quota and usage models (QuotaStatus, UsageHistoryEntry, StorageQuota)
- Virtual try-on models (GeneratedImage, GenerationMode)
- Error models (AppError hierarchy, Result type)

### 7. Component Interfaces (`component-interfaces.dart`)
Dart interface definitions including:
- Repository interfaces (ClothingRepository, OutfitRepository, UserRepository)
- Service interfaces (BYOKManager, SecureStorageService, VirtualTryOnEngine, etc.)
- UI component props (ClothingItemCardProps, OutfitCardProps, etc.)

### 8. Mock Data (`mock-data.dart`)
Mock data for prototype testing and development including:
- Mock user profiles
- Mock clothing items (various categories and states)
- Mock outfits
- Mock quota status (normal, 80%, exceeded)
- Mock usage history
- Mock storage quota
- Mock API key configurations
- Mock generated images
- Mock errors
- Helper functions for accessing mock data

## Usage Guidelines

### For Designers

1. **Wireframes**: Use `wireframes.md` as the foundation for creating high-fidelity designs
2. **Prototype**: Follow `prototype-spec.md` to build the clickable prototype in Figma/Adobe XD
3. **Mock Data**: Use `mock-data.dart` to populate prototype screens with realistic content

### For Developers

1. **Data Models**: Implement models from `data-models.dart` in `lib/models/`
2. **Interfaces**: Implement services following `component-interfaces.dart`
3. **API Integration**: Follow contracts in `firebase-contracts.md` and `vertex-ai-contracts.md`
4. **State Management**: Use Riverpod provider patterns from `api-contracts.md`

### For Product Managers

1. **User Flows**: Review `wireframes.md` to understand all user journeys
2. **Feature Scope**: Use `prototype-spec.md` to validate feature completeness
3. **Data Requirements**: Review `api-contracts.md` for backend requirements

## Design Principles

### Consistency
- 8px grid system for spacing
- Consistent button hierarchy (primary, secondary, tertiary)
- Unified iconography throughout the app

### Accessibility
- Minimum touch target: 44x44pt
- Color contrast ratio: 4.5:1 for text
- Screen reader support
- Clear focus indicators

### Privacy-First
- Clear consent dialogs before data collection
- Transparent data usage explanations
- Easy access to privacy controls
- Prominent security indicators

### Performance
- Loading states for all async operations
- Progress indicators for long operations
- Optimistic UI updates where appropriate
- Efficient image caching

## Next Steps

### Task 7.4: User Testing
- Test prototype with 3-5 users
- Validate onboarding clarity
- Validate consent flows
- Validate COPPA workflows
- Validate rate limit messaging
- Document feedback

### Task 7.5: Design Finalization
- Incorporate user testing feedback
- Finalize API data contracts
- Create design handoff documentation
- Update component interfaces if needed
- Prepare for Task 23 (UI implementation)

## File Organization

```
docs/design/
├── README.md                    # This file
├── wireframes.md                # Low-fidelity wireframes
├── prototype-spec.md            # Clickable prototype specifications
├── api-contracts.md             # Complete API contracts
├── firebase-contracts.md        # Firebase-specific contracts
├── vertex-ai-contracts.md       # Vertex AI-specific contracts
├── data-models.dart             # Dart data model definitions
├── component-interfaces.dart    # Dart interface definitions
└── mock-data.dart               # Mock data for testing
```

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-10 | Kiro | Initial design documentation for Task 7 |

## Related Documentation

- **Requirements**: `.kiro/specs/style-sync/requirements.md`
- **Design Document**: `.kiro/specs/style-sync/design.md`
- **Tasks**: `.kiro/specs/style-sync/tasks.md`
- **Architecture**: `docs/architecture/overview.md`

## Questions or Feedback

For questions about these design documents or to provide feedback, please refer to the main project documentation or contact the development team.
