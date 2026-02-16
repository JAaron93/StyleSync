# Manual Testing Checklist - Task 13 Checkpoint

This document outlines the manual testing required to complete Task 13 verification. These tests validate features implemented in Tasks 1-12 that cannot be fully automated.

## Test Environment Requirements

- [ ] iOS device or simulator (iOS 14+)
- [ ] Android device or emulator (Android 8.0+)
- [ ] Valid Google Cloud project with Vertex AI API enabled
- [ ] Test Gemini API key (Free tier is sufficient for testing)

---

## 1. Onboarding Flow (Requirements 1.1-1.7)

### 1.1 First Launch Experience
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 1 | Launch app for first time (fresh install) | Welcome screen displays with app features overview | |
| 2 | Verify welcome screen content | Core features (Digital Closet, Virtual Try-On, Outfit Brainstorming) are explained | |
| 3 | Tap "Continue" or "Next" on welcome screen | Navigates to API key tutorial screen | |

### 1.2 Tutorial Screen
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 4 | Tutorial screen displays | Title "How to Get Your Gemini API Key" is shown | |
| 5 | Verify step-by-step instructions | Clear numbered steps for getting API key are displayed | |
| 6 | Tap Google Cloud Console link | Opens browser to Google Cloud Console | |
| 7 | Tap Vertex AI setup link | Opens browser to Vertex AI documentation | |
| 8 | Verify tier explanation | Free tier vs Paid tier differences are explained | |
| 9 | Verify Vertex AI clarification | States users need Vertex AI API (not Google AI Studio) | |

### 1.3 API Key Input Screen
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 10 | Navigate to API key input | Input field and validation UI displayed | |
| 11 | Enter invalid format key (e.g., "abc123") | Format validation error shown | |
| 12 | Enter correctly formatted but invalid key | Functional verification fails, specific error message shown | |
| 13 | Enter valid API key | Key accepted, proceeds to main app | |

### 1.4 Onboarding Persistence
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 14 | Complete onboarding, close app, relaunch | Main app screen shown (not onboarding) | |
| 15 | Verify onboarding status persists | Does not re-show onboarding flow | |

---

## 2. 18+ Age Gate (Requirements 4.19-4.25)

### 2.1 Age Verification Flow
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 16 | Start sign-up process | Age verification prompt appears before account creation | |
| 17 | Enter DOB making user 18+ (e.g., 20 years ago) | Verification passes, proceeds to account creation | |
| 18 | Enter DOB making user 17 years old | Access denied, account creation blocked | |
| 19 | Enter DOB making user exactly 18 today | Verification passes | |

### 2.2 Edge Cases
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 20 | Enter Feb 29 birthdate (leap year) | Correctly calculates age on non-leap years | |
| 21 | Enter future date | Error: "Date of birth cannot be in the future" | |
| 22 | Enter date before 1900 | Error: "Minimum supported year is 1900" | |

### 2.3 Cooldown Mechanism
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 23 | Fail age verification, try again immediately | 24-hour cooldown message displayed | |
| 24 | Verify cooldown prevents brute-force attempts | Cannot retry verification during cooldown | |

---

## 3. Secure Storage (Requirements 2.5-2.9)

### 3.1 API Key Security
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 25 | Store API key | Key stored successfully | |
| 26 | Retrieve API key | Key retrieved correctly | |
| 27 | Verify biometric/passcode required (if device supports) | Authentication prompt shown before access | |

### 3.2 Platform-Specific Storage
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 28 | iOS: Verify Keychain storage | Key stored in iOS Keychain | |
| 29 | Android 9+: Verify StrongBox/Keystore | Key stored with hardware backing | |
| 30 | Android 8.x: Verify Keystore fallback | Key stored with software backing | |

---

## 4. Privacy Services (Requirements 3.1-3.12)

### 4.1 Face Detection Consent
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 31 | First upload attempt | Face detection consent dialog appears | |
| 32 | Verify consent dialog content | Privacy Protection title, on-device processing explained | |
| 33 | Tap "Reject" | Dialog closes, face detection skipped | |
| 34 | Tap "Grant Consent" | Consent recorded, face detection enabled | |

### 4.2 Metadata Stripping
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 35 | Upload image with EXIF data (GPS, timestamp) | Image processed, EXIF stripped | |
| 36 | Verify stripped image has no GPS data | No location data in processed image | |
| 37 | Verify stripped image has no device identifier | No device info in processed image | |

### 4.3 Auto-Tagging
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 38 | Upload clothing photo | Category tag assigned (tops/bottoms/shoes/accessories) | |
| 39 | Verify color detection | Dominant colors identified and tagged | |
| 40 | Verify season suggestion | Appropriate seasons suggested | |

---

## 5. Background Removal (Requirements 3.8, 9.6-9.7)

| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 41 | Upload clothing photo | Background removal processing starts | |
| 42 | Verify successful removal | Background removed, clothing isolated | |
| 43 | Test with complex background | Background removed or fallback triggered | |
| 44 | Verify timeout behavior (>10s) | Falls back to original image with notification | |

---

## 6. Digital Closet (Requirements 3.13-3.18)

### 6.1 Upload Flow
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 45 | Upload from camera | Photo captured and processed | |
| 46 | Upload from photo library | Photo selected and processed | |
| 47 | Verify upload progress indicator | Progress shown during upload | |

### 6.2 Storage Quota
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 48 | Upload items within quota | Items stored successfully | |
| 49 | Verify quota display | Current usage shown | |
| 50 | Test quota limit (if feasible) | Error with usage statistics shown | |

### 6.3 CRUD Operations
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 51 | View clothing item details | Full image and tags displayed | |
| 52 | Delete clothing item | Item removed from closet and storage | |
| 53 | Filter by category | Items filtered correctly | |

---

## 7. Encryption Services (Requirements 2.12-2.14)

### 7.1 Encryption Round-Trip
| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 54 | Enable cloud backup with passphrase | Backup created with encryption | |
| 55 | Restore backup with correct passphrase | Data restored correctly | |
| 56 | Attempt restore with wrong passphrase | Decryption fails gracefully | |

---

## 8. Error Handling (Requirements 8.1-8.5)

| # | Test Case | Expected Result | Pass/Fail |
|---|-----------|-----------------|-----------|
| 57 | Turn off network, attempt upload | Offline indicator shown | |
| 58 | Enter expired/invalid API key | Specific error prompting key verification | |
| 59 | Force upload failure | Auto-retry (up to 3x), then error shown | |
| 60 | Force background removal failure | Option to proceed with original image | |

---

## Summary

| Category | Total Tests | Passed | Failed |
|----------|-------------|--------|--------|
| Onboarding Flow | 15 | | |
| Age Gate | 9 | | |
| Secure Storage | 6 | | |
| Privacy Services | 10 | | |
| Background Removal | 4 | | |
| Digital Closet | 9 | | |
| Encryption Services | 3 | | |
| Error Handling | 4 | | |
| **TOTAL** | **60** | | |

## Sign-off

- **Tester Name:** _______________________
- **Test Date:** _______________________
- **Platform(s) Tested:** _______________________
- **App Version:** _______________________
- **Notes/Issues Found:**

---

_Last Updated: Task 13 Checkpoint_
