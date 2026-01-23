# API Key Input Page

Collects and validates the user's Vertex AI API key.

**File**: [`lib/features/onboarding/widgets/api_key_input_page.dart`](../../../lib/features/onboarding/widgets/api_key_input_page.dart)

## Features
- API key text input with validation
- Project ID input
- Real-time format validation
- Functional validation via API call
- Clear error messages

## Validation Flow
1. Format check (AIza prefix, 39 chars)
2. Functional test (API request)
3. Storage in secure storage
4. Mark onboarding complete

## Related Documentation
- [BYOK Manager](../../core-services/byok-manager.md)
- [Secure Storage](../../core-services/secure-storage-service.md)
