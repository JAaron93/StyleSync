# StyleSync - Low-Fidelity Wireframes

## Overview
This document describes the low-fidelity wireframes for StyleSync's core user flows. These wireframes serve as the foundation for the clickable prototype and final UI implementation.

## 1. Onboarding Flow

### 1.1 Welcome Screen
**Purpose**: Introduce the app and its core features to first-time users.

**Layout**:
```
┌─────────────────────────────┐
│      [App Logo/Icon]        │
│                             │
│      Welcome to             │
│      StyleSync              │
│                             │
│  Your AI-Powered Digital    │
│  Wardrobe & Virtual Try-On  │
│                             │
│  • Organize your closet     │
│  • Try on outfits with AI   │
│  • Create outfit combos     │
│  • Privacy-first design     │
│                             │
│                             │
│    [Get Started Button]     │
│                             │
│    ○ ○ ○ ○ ○ (Page Indicator)│
└─────────────────────────────┘
```

**Elements**:
- App logo/branding at top
- Welcome headline
- Brief value proposition
- 4 bullet points highlighting key features
- Primary CTA button "Get Started"
- Page indicator dots (5 screens total)

**Navigation**: Taps "Get Started" → Age Gate Screen

---

### 1.2 Age Gate Screen (18+ Verification)
**Purpose**: Verify user is 18+ before account creation.

**Layout**:
```
┌─────────────────────────────┐
│      [App Logo]             │
│                             │
│  Age Verification Required  │
│                             │
│  StyleSync is for users     │
│  18 years and older.        │
│                             │
│  Please enter your date     │
│  of birth:                  │
│                             │
│  ┌───────────────────────┐  │
│  │ Month  Day    Year    │  │
│  │ [MM]   [DD]   [YYYY]  │  │
│  └───────────────────────┘  │
│                             │
│  ℹ️ Your DOB is used only   │
│     for age verification    │
│     and not stored.         │
│                             │
│  [Verify & Continue]        │
│                             │
│  [Exit]                     │
│                             │
│    ○ ● ○ ○ ○ (Page Indicator)│
└─────────────────────────────┘
```

**Elements**:
- App branding
- Clear title
- Explanation text
- Date of birth input (3 fields: MM, DD, YYYY)
- Privacy notice
- Primary CTA "Verify & Continue"
- Exit option
- Page indicator

**Validation**:
- Check if age >= 18
- If yes → Continue to Account Creation
- If no → Access Denied Screen

**Navigation**:
- Success (18+) → Account Creation Screen
- Failure (<18) → Access Denied Screen (see Section 7)
- "Exit" → Close app

---

### 1.3 Account Creation / Signup Screen
**Purpose**: Create a new user account with email/password or social auth.

**Layout**:
```
┌─────────────────────────────┐
│  [← Back]  Create Account   │
│                             │
│  ┌───────────────────────┐  │
│  │  ⚠️ [Error Banner]    │  │  ← hidden by default
│  │  (e.g. "Email already │  │
│  │   registered")        │  │
│  └───────────────────────┘  │
│                             │
│  Create your StyleSync      │
│  account to get started     │
│                             │
│  Email                      │
│  ┌───────────────────────┐  │
│  │ [Text Input Field]    │  │
│  └───────────────────────┘  │
│  helper: "e.g. you@mail.com"│
│  error:  "Enter a valid     │
│           email address"    │
│                             │
│  Password                   │
│  ┌───────────────────────┐  │
│  │ [Password Field] [👁]  │  │
│  └───────────────────────┘  │
│  helper: "Min 8 chars, 1    │
│   uppercase, 1 number"     │
│  error:  "Password does not │
│           meet requirements"│
│                             │
│  Confirm Password           │
│  ┌───────────────────────┐  │
│  │ [Password Field] [👁]  │  │
│  └───────────────────────┘  │
│  error:  "Passwords do not  │
│           match"            │
│                             │
│  [Create Account]           │
│                             │
│  ─────── OR ───────         │
│                             │
│  [🔵 Continue with Google]  │
│  [🍎 Continue with Apple]   │
│                             │
│  Already have an account?   │
│  [Sign In]                  │
│                             │
│    ○ ○ ● ○ ○ (Page Indicator)│
└─────────────────────────────┘
```

**Visible UI Elements**:
- **Back button** (top-left) — returns to previous screen
- **Error banner** — hidden by default; displayed at top on submission failure
- **Title**: "Create Account" (header), "Create your StyleSync account to get started" (subtitle)
- **Email input** — text field with placeholder, helper text, inline error
- **Password input** — obscured field with show/hide toggle (👁), helper text showing requirements, inline error
- **Confirm Password input** — obscured field with toggle, inline error
- **[Create Account] button** — primary CTA, disabled until all fields valid
- **Divider** — "OR" separator
- **[Continue with Google]** — branded social sign-in button
- **[Continue with Apple]** — branded social sign-in button
- **"Already have an account? Sign In"** — text link to Login Screen
- **Page indicator** — 5-dot progress (dot 3 active)

**Primary Actions**:
- **Create Account** — validate inputs, call signup API, create local account
- **Continue with Google** — initiate Google OAuth flow
- **Continue with Apple** — initiate Apple Sign-In flow

**Secondary Actions**:
- **← Back** — return to Age Gate Screen
- **Sign In** — navigate to Login Screen

**Validation & Error States**:
| Field | Validation Rule | Error Message |
|---|---|---|
| Email | RFC 5322 format, not already registered | "Enter a valid email address" / "This email is already registered" |
| Password | ≥ 8 characters, ≥ 1 uppercase, ≥ 1 digit | "Password does not meet requirements" |
| Confirm Password | Must match Password field | "Passwords do not match" |

- **Inline errors** — appear beneath the field in red when the field loses focus and is invalid
- **Error banner** — appears at top of form for server-side errors (network failure, duplicate email, etc.)
- **Success state** — brief success toast ("Account created!"), then automatic navigation to API Key Tutorial Screen

**Navigation**:
- **Create Account (success)** → API Key Tutorial Screen (Section 1.4)
- **Continue with Google / Apple (success)** → API Key Tutorial Screen (Section 1.4)
- **"Sign In" link** → Login Screen (Section 1.3b)
- **"← Back"** → Age Gate Screen (Section 1.2)

---

### 1.3b Login Screen
**Purpose**: Authenticate a returning user via email/password or social auth.

**Layout**:
```
┌─────────────────────────────┐
│  [← Back]  Sign In          │
│                             │
│  ┌───────────────────────┐  │
│  │  ⚠️ [Error Banner]    │  │  ← hidden by default
│  │  (e.g. "Invalid email │  │
│  │   or password")       │  │
│  └───────────────────────┘  │
│                             │
│  Welcome back to StyleSync  │
│                             │
│  Email                      │
│  ┌───────────────────────┐  │
│  │ [Text Input Field]    │  │
│  └───────────────────────┘  │
│  error:  "Enter a valid     │
│           email address"    │
│                             │
│  Password                   │
│  ┌───────────────────────┐  │
│  │ [Password Field] [👁]  │  │
│  └───────────────────────┘  │
│  error:  "Password is       │
│           required"         │
│                             │
│  [Forgot Password?]         │
│                             │
│  [Sign In]                  │
│                             │
│  ─────── OR ───────         │
│                             │
│  [🔵 Continue with Google]  │
│  [🍎 Continue with Apple]   │
│                             │
│  Don't have an account?     │
│  [Create Account]           │
│                             │
└─────────────────────────────┘
```

**Visible UI Elements**:
- **Back button** (top-left) — returns to Welcome Screen
- **Error banner** — hidden by default; shown on authentication failure
- **Title**: "Sign In" (header), "Welcome back to StyleSync" (subtitle)
- **Email input** — text field with inline error
- **Password input** — obscured field with show/hide toggle (👁), inline error
- **[Forgot Password?] link** — positioned below password field
- **[Sign In] button** — primary CTA, disabled until both fields non-empty
- **Divider** — "OR" separator
- **[Continue with Google]** — branded social sign-in button
- **[Continue with Apple]** — branded social sign-in button
- **"Don't have an account? Create Account"** — text link to Account Creation Screen

**Primary Actions**:
- **Sign In** — validate inputs, authenticate via backend, start session
- **Forgot Password** — navigate to Password Reset flow (future)

**Secondary Actions**:
- **Continue with Google** — initiate Google OAuth flow
- **Continue with Apple** — initiate Apple Sign-In flow
- **Create Account** — navigate to Account Creation / Signup Screen
- **← Back** — return to Welcome Screen

**Validation & Error States**:
| Field | Validation Rule | Error Message |
|---|---|---|
| Email | RFC 5322 format, non-empty | "Enter a valid email address" |
| Password | Non-empty | "Password is required" |

- **Invalid credentials** — error banner: "Invalid email or password. Please try again."
- **Account locked** — error banner: "Too many failed attempts. Account locked for 15 minutes." (after 5 consecutive failures)
- **Network error** — error banner: "Unable to connect. Please check your internet and try again." with **[Retry]** button
- **Success state** — navigate immediately to Main App (Digital Closet tab)

**Navigation**:
- **Sign In (success)** → Main App / Digital Closet (Section 2.1)
- **Continue with Google / Apple (success)** → Main App / Digital Closet (Section 2.1)
- **"Forgot Password?"** → Password Reset Flow (future — not yet wireframed)
- **"Create Account" link** → Account Creation / Signup Screen (Section 1.3)
- **"← Back"** → Welcome Screen (Section 1.1)

---

### 1.4 API Key Tutorial Screen
**Purpose**: Educate users on how to obtain a Gemini API key.

**Layout**:
```
┌─────────────────────────────┐
│  [← Back]  How to Get Your  │
│            API Key          │
│                             │
│  ┌───────────────────────┐  │
│  │  Step 1: Create       │  │
│  │  Google Cloud Project │  │
│  │  [Icon]               │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │  Step 2: Enable       │  │
│  │  Vertex AI API        │  │
│  │  [Icon]               │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │  Step 3: Create       │  │
│  │  API Key              │  │
│  │  [Icon]               │  │
│  └───────────────────────┘  │
│                             │
│  [Open Google Cloud Console]│
│  [Open Vertex AI Setup]     │
│                             │
│  Free vs Paid Tier:         │
│  • Free: Limited daily quota│
│  • Paid: Higher limits      │
│                             │
│    [Continue Button]        │
│    ○ ○ ○ ● ○ (Page Indicator)│
└─────────────────────────────┘
```

**Elements**:
- Back button (top left)
- Title "How to Get Your API Key"
- 3 step cards with icons and brief descriptions
- 2 action buttons linking to Google Cloud Console and Vertex AI setup
- Info box explaining Free vs Paid tier differences
- Primary CTA "Continue"
- Page indicator

**Navigation**: Taps "Continue" → API Key Input Screen

---

### 1.5 API Key Input Screen
**Purpose**: Collect and validate the user's Gemini API key.

**Layout**:
```
┌─────────────────────────────┐
│  [← Back]  Enter API Key    │
│                             │
│  Paste your Gemini API key  │
│  from Google Cloud Console  │
│                             │
│  ┌───────────────────────┐  │
│  │ API Key               │  │
│  │ [Text Input Field]    │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ Project ID            │  │
│  │ [Text Input Field]    │  │
│  └───────────────────────┘  │
│                             │
│  ℹ️ Your key is stored     │
│     securely on device     │
│                             │
│    [Validate & Continue]    │
│                             │
│    ○ ○ ○ ○ ● (Page Indicator)│
└─────────────────────────────┘
```

**Elements**:
- Back button
- Title and instructions
- API Key text input field
- Project ID text input field
- Security reassurance message with icon
- Primary CTA "Validate & Continue" (disabled until both fields filled)
- Page indicator
- Loading spinner appears during validation

**Validation States**:
- Empty: Button disabled
- Format invalid: Show inline error "Invalid API key format"
- Functional test fails: Show error modal with specific reason
- Success: Navigate to main app

**Navigation**: 
- Success → Main App (Digital Closet)
- Failure → Stay on screen with error message

---

## 2. Digital Closet Flow

### 2.1 Digital Closet Main Screen
**Purpose**: Display user's clothing collection with filtering and upload options.

**Layout**:
```
┌─────────────────────────────┐
│  My Closet        [+ Upload]│
│                             │
│  [All] [Tops] [Bottoms]     │
│  [Shoes] [Accessories]      │
│                             │
│  ┌─────┐ ┌─────┐ ┌─────┐   │
│  │ 👕  │ │ 👖  │ │ 👟  │   │
│  │Item1│ │Item2│ │Item3│   │
│  └─────┘ └─────┘ └─────┘   │
│  ┌─────┐ ┌─────┐ ┌─────┐   │
│  │ 🧥  │ │ 👔  │ │ 🎒  │   │
│  │Item4│ │Item5│ │Item6│   │
│  └─────┘ └─────┘ └─────┘   │
│                             │
│  Storage: 45/500 items      │
│           1.2GB/2GB         │
│                             │
│  [Closet] [Try-On] [Outfits]│
└─────────────────────────────┘
```

**Elements**:
- Header with title and upload button
- Category filter chips (horizontal scroll)
- Grid of clothing item thumbnails (3 columns)
- Storage quota indicator at bottom
- Bottom navigation bar (3 tabs)

**Navigation**:
- Tap item → Item Detail Screen
- Tap "+ Upload" → Upload Options Modal
- Tap "Try-On" tab → Virtual Try-On Screen
- Tap "Outfits" tab → Outfit Canvas Screen

---

### 2.2 Upload Options Modal
**Purpose**: Let user choose photo source.

**Layout**:
```
┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │  Upload Clothing      │  │
│  │                       │  │
│  │  [📷 Take Photo]      │  │
│  │                       │  │
│  │  [🖼️ Choose from      │  │
│  │     Library]          │  │
│  │                       │  │
│  │  [Cancel]             │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Elements**:
- Modal overlay
- Two primary action buttons with icons
- Cancel button

**Navigation**:
- "Take Photo" → Camera interface → Face Detection Consent (if first time)
- "Choose from Library" → Photo picker → Face Detection Consent (if first time)
- "Cancel" → Close modal

---

### 2.3 Face Detection Consent Dialog (First Time Only)
**Purpose**: Obtain one-time consent to **scan** uploaded images for faces. This does **not** grant consent to upload photos that contain faces — that decision is made separately in Section 2.5.

**Layout**:
```
┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │  Face Detection       │  │
│  │  Permission           │  │
│  │                       │  │
│  │  We can scan your     │  │
│  │  photos for faces to  │  │
│  │  protect your privacy.│  │
│  │                       │  │
│  │  What this means:     │  │
│  │  • Photos are scanned │  │
│  │    on-device only     │  │
│  │  • No biometric data  │  │
│  │    is stored          │  │
│  │  • Only checks if a   │  │
│  │    face is present    │  │
│  │  • You'll be asked    │  │
│  │    before uploading   │  │
│  │    any photo with a   │  │
│  │    detected face      │  │
│  │  • Scanning does NOT  │  │
│  │    auto-allow uploads │  │
│  │    containing faces   │  │
│  │                       │  │
│  │  [Allow Face Detection]│  │
│  │  [Skip Detection]     │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Visible UI Elements**:
- **Title**: "Face Detection Permission"
- **Explanation**: describes the scan-only scope
- **Bullet list**: five points clarifying on-device scanning, no storage, per-upload confirmation, and that scan consent ≠ upload consent
- **[Allow Face Detection]** — primary CTA, saves scan-only consent
- **[Skip Detection]** — secondary, skips face scanning for this upload

**Navigation**:
- "Allow Face Detection" → Save scan consent → Continue to upload processing (Section 2.4). If a face is later detected, the user is prompted again at Section 2.5.
- "Skip Detection" → Continue to upload processing without face detection (photo uploaded as-is)

---

### 2.4 Upload Processing Screen
**Purpose**: Show progress during image processing.

**Layout**:
```
┌─────────────────────────────┐
│  Processing...              │
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │   [Image Preview]     │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│  ✓ Removing metadata        │
│  ⏳ Detecting faces...      │
│  ⏺️ Removing background     │
│  ⏺️ Auto-tagging            │
│                             │
│  This may take a few        │
│  seconds...                 │
│                             │
└─────────────────────────────┘
```

**Elements**:
- Image preview
- Progress checklist with status icons
- Informative message

**States**:
- ✓ = Complete
- ⏳ = In progress (animated)
- ⏺️ = Pending

**Navigation**: Auto-advances when complete

---

### 2.5 Face Detected Warning Modal
**Purpose**: Get **per-upload** explicit consent to proceed when a face is detected. This is a separate decision from the scan permission granted in Section 2.3.

**Layout**:
```
┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │  ⚠️ Face Detected     │  │
│  │                       │  │
│  │  We detected a face in│  │
│  │  this photo.          │  │
│  │                       │  │
│  │  Face detection is    │  │
│  │  enabled in your      │  │
│  │  privacy settings.    │  │
│  │                       │  │
│  │  For privacy, we      │  │
│  │  recommend photos of  │  │
│  │  clothing only.       │  │
│  │                       │  │
│  │  Do you want to       │  │
│  │  proceed with this    │  │
│  │  upload?              │  │
│  │                       │  │
│  │  [Cancel Upload]      │  │
│  │  [Proceed with Upload]│  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Visible UI Elements**:
- **Warning icon and title**: "⚠️ Face Detected"
- **Detection context**: "Face detection is enabled in your privacy settings."
- **Explanation**: describes the detected face and recommends clothing-only photos
- **Decision prompt**: "Do you want to proceed with this upload?"
- **[Cancel Upload]** — abort the upload, discard the photo
- **[Proceed with Upload]** — continue uploading despite the detected face

**Navigation**:
- "Cancel Upload" → Discard photo → Return to Digital Closet (Section 2.1)
- "Proceed with Upload" → Continue upload processing (Section 2.4 remaining steps)

---

### 2.6 Item Detail Screen
**Purpose**: Display full clothing item with tags and actions.

**Layout**:
```
┌─────────────────────────────┐
│  [← Back]        [⋮ Menu]   │
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │                       │  │
│  │   [Full Image]        │  │
│  │                       │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│  Category: Tops             │
│  Colors: Blue, White        │
│  Season: Summer, All-season │
│                             │
│  Uploaded: Jan 15, 2026     │
│                             │
│  [Try On] [Add to Outfit]   │
│                             │
└─────────────────────────────┘
```

**Elements**:
- Back button and menu (delete option)
- Full-size image
- Auto-generated tags (category, colors, seasons)
- Upload timestamp
- Action buttons

**Navigation**:
- "← Back" → Digital Closet
- "Try On" → Virtual Try-On Screen (with this item pre-selected)
- "Add to Outfit" → Outfit Canvas Screen
- Menu → Delete confirmation dialog

---

## 3. Virtual Try-On Flow

### 3.1 Virtual Try-On Main Screen
**Purpose**: Allow users to select clothing and photo for AI try-on.

**Layout**:
```
┌─────────────────────────────┐
│  Virtual Try-On             │
│                             │
│  Select Clothing Item:      │
│  ┌─────┐ ┌─────┐ ┌─────┐   │
│  │ 👕  │ │ 👖  │ │ 👟  │   │
│  │Item1│ │Item2│ │Item3│   │
│  └─────┘ └─────┘ └─────┘   │
│                             │
│  Select Your Photo:         │
│  ┌───────────────────────┐  │
│  │  [📷 Take Photo]      │  │
│  │  [🖼️ Choose Photo]    │  │
│  └───────────────────────┘  │
│                             │
│  Generation Mode:           │
│  ○ Quality (slower)         │
│  ● Speed (faster)           │
│  ○ Try-On Model (best)      │
│                             │
│  [Generate Try-On]          │
│  (disabled until both       │
│   selections made)          │
│                             │
│  [Closet] [Try-On] [Outfits]│
└─────────────────────────────┘
```

**Elements**:
- Clothing item selector (horizontal scroll)
- Photo source buttons
- Generation mode radio buttons
- Primary CTA (disabled until ready)
- Bottom navigation

**Navigation**:
- Select item → Highlight selection
- "Take Photo"/"Choose Photo" → Biometric Consent (first time) → Photo picker
- "Generate Try-On" → Generation Progress Screen

---

### 3.2 Biometric Consent Dialog (First Time Only)
**Purpose**: Obtain consent for processing user photos.

**Layout**:
```
┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │  Photo Processing     │  │
│  │  Consent              │  │
│  │                       │  │
│  │  To generate try-ons, │  │
│  │  we need to process   │  │
│  │  your photo.          │  │
│  │                       │  │
│  │  Your privacy:        │  │
│  │  • Photos processed   │  │
│  │    on-device when     │  │
│  │    possible           │  │
│  │  • Deleted immediately│  │
│  │    after generation   │  │
│  │  • Never stored in    │  │
│  │    cloud by default   │  │
│  │  • Direct AI          │  │
│  │    communication      │  │
│  │                       │  │
│  │  [I Understand]       │  │
│  │  [Cancel]             │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Elements**:
- Clear title
- Explanation of what will happen
- Privacy guarantees with bullet points
- Two action buttons

**Navigation**:
- "I Understand" → Save consent → Continue to photo picker
- "Cancel" → Return to Try-On screen

---

### 3.3 Try-On Generation Progress Screen
**Purpose**: Show progress during AI generation.

**Layout**:
```
┌─────────────────────────────┐
│  Generating Try-On...       │
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │   [Clothing Preview]  │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│  ┌─────────────────────┐    │
│  │ ████████░░░░░░░░░░ │    │
│  └─────────────────────┘    │
│                             │
│  Processing with AI...      │
│  This may take 10-30 seconds│
│                             │
│  💡 Tip: Speed mode is      │
│     faster for quick tests  │
│                             │
│  [Cancel]                   │
│                             │
└─────────────────────────────┘
```

**Elements**:
- Clothing item preview
- Progress bar (animated)
- Status message
- Helpful tip
- Cancel button

**Navigation**:
- Success → Try-On Result Screen
- Error → Error modal with retry option
- Cancel → Return to Try-On screen

---

### 3.4 Try-On Result Screen
**Purpose**: Display generated try-on result with save/share options.

**Layout**:
```
┌─────────────────────────────┐
│  [← Back]        [⋮ Menu]   │
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │                       │  │
│  │   [Generated Image]   │  │
│  │                       │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│  Generated with: Speed Mode │
│  Model: gemini-2.5-flash    │
│                             │
│  [Save to Device]           │
│  [Share]                    │
│  [Try Another Item]         │
│                             │
└─────────────────────────────┘
```

**Elements**:
- Back button and menu
- Generated image (full screen)
- Generation metadata
- Action buttons

**Navigation**:
- "← Back" → Virtual Try-On screen
- "Save to Device" → Request storage permission → Save confirmation
- "Share" → System share sheet
- "Try Another Item" → Virtual Try-On screen
- Menu → Delete result option

---

## 4. Rate Limit Flow

### 4.1 Warning Banner (80% Threshold)
**Purpose**: Alert user they're approaching quota limit.

**Layout**:
```
┌─────────────────────────────┐
│  ⚠️ Approaching Daily Limit │
│  Used: 80/100 requests      │
│  Resets in: 2h 15m (5:00 PM)│
│  [Learn More] [Dismiss]     │
└─────────────────────────────┘
```

**Elements**:
- Warning icon
- Usage statistics
- Countdown timer (updates every minute)
- Two action buttons

**Behavior**:
- Appears at top of screen (sticky)
- Dismissible but reappears on next screen
- Shows local time + timezone

**Navigation**:
- "Learn More" → Rate Limit Info Modal
- "Dismiss" → Hide banner (temporarily)

---

### 4.2 Rate Limit Modal (100% Threshold)
**Purpose**: Inform user quota is exhausted and provide upgrade path.

**Layout**:
```
┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │  🚫 Daily Limit       │  │
│  │     Reached           │  │
│  │                       │  │
│  │  Your free tier quota │  │
│  │  has been exhausted.  │  │
│  │                       │  │
│  │  Usage Today:         │  │
│  │  100/100 requests     │  │
│  │                       │  │
│  │  Next Reset:          │  │
│  │  5:00 PM PST (01:00   │  │
│  │  UTC) - in 2h 15m     │  │
│  │                       │  │
│  │  Upgrade to Paid Tier:│  │
│  │  • Higher quotas      │  │
│  │  • Faster processing  │  │
│  │  • Priority access    │  │
│  │                       │  │
│  │  [Enable Billing]     │  │
│  │  [View Usage History] │  │
│  │  [OK]                 │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Elements**:
- Error icon and title
- Clear explanation
- Current usage stats
- Reset time (local + UTC) with countdown
- Benefits of upgrading
- Three action buttons

**Behavior**:
- Blocks try-on features until dismissed
- Cannot be permanently dismissed until quota resets
- Try-on button disabled on main screen

**Navigation**:
- "Enable Billing" → Open Google Cloud Console (external)
- "View Usage History" → Usage History Screen
- "OK" → Close modal (features remain disabled)

---

## 5. Outfit Canvas Flow

### 5.1 Outfit Canvas Main Screen
**Purpose**: Create outfit combinations by layering clothing items.

**Layout**:
```
┌─────────────────────────────┐
│  [← Back]  New Outfit [Save]│
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │   [Canvas Area]       │  │
│  │                       │  │
│  │   Drag items here     │  │
│  │   to layer them       │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│  Layers:                    │
│  [Base] [Mid] [Outer] [Acc] │
│                             │
│  Your Items:                │
│  ┌─────┐ ┌─────┐ ┌─────┐   │
│  │ 👕  │ │ 👖  │ │ 👟  │   │
│  └─────┘ └─────┘ └─────┘   │
│                             │
│  [Closet] [Try-On] [Outfits]│
└─────────────────────────────┘
```

**Elements**:
- Back button and Save button
- Canvas area (drag-and-drop zone)
- Layer selector tabs
- Clothing item picker (horizontal scroll)
- Bottom navigation

**Interactions**:
- Drag item from picker → Drop on canvas
- Tap layer tab → Filter items by layer type
- Pinch/zoom on canvas
- Tap item on canvas → Show reorder/remove options

**Navigation**:
- "← Back" → Outfit Gallery (if saved) or discard confirmation
- "Save" → Save Outfit Dialog
- Bottom nav → Other screens

---

### 5.2 Save Outfit Dialog
**Purpose**: Name and save the outfit combination.

**Layout**:
```
┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │  Save Outfit          │  │
│  │                       │  │
│  │  ┌─────────────────┐  │  │
│  │  │ [Thumbnail]     │  │  │
│  │  └─────────────────┘  │  │
│  │                       │  │
│  │  Outfit Name:         │  │
│  │  ┌─────────────────┐  │  │
│  │  │ [Text Input]    │  │  │
│  │  └─────────────────┘  │  │
│  │                       │  │
│  │  Items: 4             │  │
│  │  • Blue T-shirt       │  │
│  │  • Black jeans        │  │
│  │  • White sneakers     │  │
│  │  • Leather jacket     │  │
│  │                       │  │
│  │  [Save] [Cancel]      │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Elements**:
- Outfit thumbnail preview
- Name input field
- Item list
- Save and Cancel buttons

**Navigation**:
- "Save" → Save outfit → Outfit Gallery
- "Cancel" → Return to canvas

---

### 5.3 Outfit Gallery Screen
**Purpose**: Display saved outfits with management options.

**Layout**:
```
┌─────────────────────────────┐
│  My Outfits      [+ Create] │
│                             │
│  ┌───────────────────────┐  │
│  │  Summer Casual        │  │
│  │  [Thumbnail]          │  │
│  │  4 items              │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │  Work Professional    │  │
│  │  [Thumbnail]          │  │
│  │  5 items              │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │  Date Night           │  │
│  │  [Thumbnail]          │  │
│  │  3 items              │  │
│  └───────────────────────┘  │
│                             │
│  💡 AI Suggestions          │
│  [Get Missing Piece Ideas]  │
│                             │
│  [Closet] [Try-On] [Outfits]│
└─────────────────────────────┘
```

**Elements**:
- Header with create button
- List of saved outfits (cards)
- AI suggestion prompt
- Bottom navigation

**Navigation**:
- Tap outfit card → Outfit Detail Screen
- "+ Create" → Outfit Canvas
- "Get Missing Piece Ideas" → AI Suggestions Screen

---

### 5.4 AI Suggestions Screen
**Purpose**: Recommend complementary clothing items that complete or enhance an outfit, powered by AI analysis of the user's existing wardrobe and current outfit.

**Layout**:
```
┌─────────────────────────────┐
│  [← Back]  AI Suggestions   │
│                             │
│  Describe what you need:    │
│  ┌───────────────────────┐  │
│  │ [Text Input]          │  │
│  │ e.g. "a jacket for    │  │
│  │  cold weather"        │  │
│  └───────────────────────┘  │
│  [Get Suggestions]          │
│                             │
│  Or try:                    │
│  [Complete this outfit]     │
│  [Match colors]             │
│  [Seasonal upgrade]         │
│                             │
│  ─────────────────────────  │
│  Filter: [All ▾] Sort: [Relevance ▾]│
│  ─────────────────────────  │
│                             │
│  ┌───────────┐ ┌───────────┐│
│  │ [Image]   │ │ [Image]   ││
│  │ Navy      │ │ Brown     ││
│  │ Blazer    │ │ Loafers   ││
│  │           │ │           ││
│  │ "Adds     │ │ "Pairs    ││
│  │  structure│ │  with     ││
│  │  to casual│ │  earth    ││
│  │  layers"  │ │  tones"   ││
│  │           │ │           ││
│  │ [💾 Save] │ │ [💾 Save] ││
│  │ [👕 Try On]│ │ [👕 Try On]││
│  │ [+ Outfit]│ │ [+ Outfit]││
│  └───────────┘ └───────────┘│
│  ┌───────────┐ ┌───────────┐│
│  │ [Image]   │ │ [Image]   ││
│  │ ...       │ │ ...       ││
│  └───────────┘ └───────────┘│
│                             │
│  [Closet] [Try-On] [Outfits]│
└─────────────────────────────┘
```

**Visible UI Elements**:
- **Back button** (top-left) — returns to Outfit Gallery
- **Header**: "AI Suggestions"
- **Prompt text input** — free-text field with placeholder ("e.g. a jacket for cold weather")
- **[Get Suggestions] button** — primary CTA, disabled when input is empty
- **Suggested-prompt chips** — pre-built shortcuts: "Complete this outfit", "Match colors", "Seasonal upgrade"
- **Filter dropdown** — filter results by category (All / Tops / Bottoms / Shoes / Accessories)
- **Sort dropdown** — sort by Relevance (default), Category, Color
- **Results grid** — 2-column card grid, each card containing:
  - AI-generated or reference image
  - Item name (e.g. "Navy Blazer")
  - Reason text (e.g. "Adds structure to casual layers")
  - **[💾 Save]** — save suggestion to a "Saved Ideas" list
  - **[👕 Try On]** — send item to Virtual Try-On flow
  - **[+ Outfit]** — add item to the current Outfit Canvas
- **Bottom navigation** — standard app tabs

**Primary Actions**:
- **Get Suggestions** — submit the text prompt (or a selected chip) to the AI; displays results in the grid
- **Save suggestion** — persist the suggestion for later reference
- **Try On** — navigate to Virtual Try-On with the suggested item pre-selected
- **Add to Outfit (+ Outfit)** — add the suggested item directly to the Outfit Canvas

**Secondary Actions**:
- **← Back** — return to Outfit Gallery
- **Tap suggested-prompt chip** — auto-fill the prompt and submit
- **Filter / Sort** — refine the results grid

**Loading, Error & Empty States**:

*Loading*:
```
┌─────────────────────────────┐
│  AI Suggestions             │
│                             │
│         ⏳                  │
│  Finding pieces for you...  │
│  This may take a moment.    │
│                             │
└─────────────────────────────┘
```

*Error*:
```
┌─────────────────────────────┐
│  AI Suggestions             │
│                             │
│  ┌───────────────────────┐  │
│  │  ⚠️ Suggestion Error  │  │
│  │                       │  │
│  │  We couldn't generate │  │
│  │  suggestions right    │  │
│  │  now. This could be a │  │
│  │  network or API issue.│  │
│  │                       │  │
│  │  [Retry]              │  │
│  │  [Cancel]             │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

*Empty — no results*:
```
┌─────────────────────────────┐
│  AI Suggestions             │
│                             │
│         🤷                  │
│                             │
│  No suggestions found       │
│                             │
│  Try a different prompt or  │
│  add more items to your     │
│  outfit first.              │
│                             │
│  [Try Again]                │
│                             │
└─────────────────────────────┘
```

*Empty — first visit (no prompt submitted)*:
```
┌─────────────────────────────┐
│  AI Suggestions             │
│                             │
│         💡                  │
│                             │
│  Get AI-powered ideas to    │
│  complete your outfits.     │
│                             │
│  Type a description above   │
│  or tap a suggestion to     │
│  get started!               │
│                             │
└─────────────────────────────┘
```

**Navigation**:
- **← Back** → Outfit Gallery (Section 5.3)
- **[💾 Save]** → save in-place (stays on this screen, shows toast "Suggestion saved")
- **[👕 Try On]** → Virtual Try-On Main Screen (Section 3.1) with suggested item pre-selected
- **[+ Outfit]** → Outfit Canvas (Section 5.1) with suggested item added to the current canvas
- **[Retry]** (error state) → re-submit the last prompt
- **[Cancel]** (error state) → return to Outfit Gallery (Section 5.3)
- **Bottom nav** → other app tabs

---

## 6. Settings Flow

### 6.1 Settings Main Screen
**Purpose**: Access app configuration and account management.

**Layout**:
```
┌─────────────────────────────┐
│  [← Back]  Settings         │
│                             │
│  Account                    │
│  ┌───────────────────────┐  │
│  │ user@example.com      │  │
│  │ [Sign Out]            │  │
│  └───────────────────────┘  │
│                             │
│  API Key Management         │
│  ┌───────────────────────┐  │
│  │ Status: ✓ Valid       │  │
│  │ [Update Key]          │  │
│  │ [Cloud Backup]        │  │
│  └───────────────────────┘  │
│                             │
│  Usage & Quota              │
│  ┌───────────────────────┐  │
│  │ Today: 45/100         │  │
│  │ [View History]        │  │
│  └───────────────────────┘  │
│                             │
│  Privacy                    │
│  ┌───────────────────────┐  │
│  │ [Manage Consents]     │  │
│  │ [Delete Account]      │  │
│  └───────────────────────┘  │
│                             │
│  About                      │
│  Version 1.0.0              │
│                             │
└─────────────────────────────┘
```

**Elements**:
- Grouped settings sections
- Account info with sign out
- API key status indicator
- Usage summary
- Privacy controls
- App version

**Navigation**:
- "Update Key" → API Key Input Screen
- "Cloud Backup" → Cloud Backup Settings Screen
- "View History" → Usage History Screen
- "Manage Consents" → Consent Management Screen
- "Delete Account" → Account Deletion Flow
- "Sign Out" → Sign Out Options Dialog

---

### 6.1b Sign Out Options Dialog
**Purpose**: Confirm sign-out intent and offer the option to clear local data on sign-out.

**Layout**:
```
┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │  Sign Out              │  │
│  │                        │  │
│  │  Signed in as:         │  │
│  │  user@example.com      │  │
│  │                        │  │
│  │  ─────────────────     │  │
│  │                        │  │
│  │  [Sign Out]            │  │
│  │                        │  │
│  │  ⚠️ Or remove all data:│  │
│  │                        │  │
│  │  [Sign Out & Clear     │  │
│  │   All Data]            │  │  ← destructive / red
│  │                        │  │
│  │  This will permanently │  │
│  │  delete your closet,   │  │
│  │  outfits, try-on       │  │
│  │  results, and API key  │  │
│  │  from this device.     │  │
│  │                        │  │
│  │  [Cancel]              │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Visible UI Elements**:
- **Title**: "Sign Out"
- **Account email** — displays the currently signed-in address (e.g. `user@example.com`)
- **[Sign Out] button** — primary action, standard style
- **Warning section** — ⚠️ icon with "Or remove all data:" label
- **[Sign Out & Clear All Data] button** — destructive action, styled in red / danger color
- **Destructive action description** — explains what will be deleted (closet items, outfits, try-on results, API key)
- **[Cancel] button** — secondary / text button, dismisses dialog

**Primary Actions**:
- **Sign Out** — end the current session, clear auth tokens, redirect to Login Screen; local data (closet, outfits, API key) is preserved for next sign-in
- **Confirm Sign Out (after "Sign Out & Clear All Data")** — end session **and** wipe all local data (closet, outfits, try-on history, API key, consents)

**Secondary Actions**:
- **Cancel** — dismiss dialog, return to Settings Main Screen

**Validation & Error States**:
- **Sign-out failure** — toast: "Unable to sign out. Please try again." (e.g., network timeout when revoking token)
- **Data-clear confirmation** — if user taps "Sign Out & Clear All Data", a second confirmation toast/modal appears: "Are you sure? This cannot be undone." with **[Delete & Sign Out]** and **[Go Back]**
- **Success (Sign Out)** — session cleared, navigate to Login Screen with brief toast: "Signed out successfully"
- **Success (Sign Out & Clear All Data)** — all local data wiped, navigate to Login Screen with toast: "Signed out — all data removed"

**Navigation**:
- **Sign Out (success)** → Login Screen (Section 1.3b)
- **Sign Out & Clear All Data (success)** → Login Screen (Section 1.3b)
- **Cancel** → Settings Main Screen (Section 6.1)

---

### 6.2 Cloud Backup Settings Screen
**Purpose**: Configure encrypted cloud backup for API key.

**Layout**:
```
┌─────────────────────────────┐
│  [← Back]  Cloud Backup     │
│                             │
│  Encrypted API Key Backup   │
│                             │
│  ℹ️ Your API key can be     │
│     backed up with end-to-  │
│     end encryption.         │
│                             │
│  Status: ○ Disabled         │
│                             │
│  How it works:              │
│  • You provide a passphrase │
│  • Key encrypted on device  │
│  • Stored in Firebase       │
│  • Only you can decrypt     │
│                             │
│  ⚠️ If you forget your      │
│     passphrase, backup      │
│     cannot be recovered     │
│                             │
│  [Enable Backup]            │
│                             │
└─────────────────────────────┘
```

**Elements**:
- Explanation of feature
- Current status indicator
- How it works section
- Warning about passphrase
- Enable button

**Navigation**:
- "Enable Backup" → Passphrase Setup Dialog
- If already enabled: Show "Disable Backup" and "Change Passphrase" options

---

### 6.3 Usage History Screen
**Purpose**: Display API usage events and quota history.

**Layout**:
```
┌─────────────────────────────┐
│  [← Back]  Usage History    │
│                             │
│  Current Period             │
│  Used: 45/100 requests      │
│  Resets: 5:00 PM (2h 15m)   │
│                             │
│  Recent Activity:           │
│  ┌───────────────────────┐  │
│  │ Jan 15, 2:30 PM       │  │
│  │ Try-On Generated      │  │
│  │ +1 request            │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │ Jan 15, 1:45 PM       │  │
│  │ Try-On Generated      │  │
│  │ +1 request            │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │ Jan 15, 12:00 AM      │  │
│  │ Quota Reset           │  │
│  │ 0/100 requests        │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │ Jan 14, 11:30 PM      │  │
│  │ ⚠️ 80% Warning        │  │
│  │ 80/100 requests       │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Elements**:
- Current quota summary
- Chronological event list
- Event cards with timestamps and details
- Scrollable list

**Event Types**:
- Try-on generated
- Quota reset
- 80% warning
- 100% limit reached
- API key updated

---

## 7. Age Verification Flow

### 7.1 Age Gate Screen (Pre-Signup)
**Purpose**: Verify user is 18+ before account creation.

**Layout**:
```
┌─────────────────────────────┐
│      [App Logo]             │
│                             │
│  Age Verification Required  │
│                             │
│  StyleSync is for users     │
│  18 years and older.        │
│                             │
│  Please enter your date     │
│  of birth:                  │
│                             │
│  ┌───────────────────────┐  │
│  │ Month  Day    Year    │  │
│  │ [MM]   [DD]   [YYYY]  │  │
│  └───────────────────────┘  │
│                             │
│  ℹ️ Your DOB is used only   │
│     for age verification    │
│     and not stored.         │
│                             │
│  [Verify & Continue]        │
│                             │
│  [Exit]                     │
│                             │
└─────────────────────────────┘
```

**Elements**:
- App branding
- Clear title
- Explanation text
- Date of birth input (3 fields)
- Privacy notice
- Primary CTA
- Exit option

**Validation**:
- Check if age >= 18
- If yes → Continue to signup
- If no → Access Denied Screen

**Navigation**:
- Success (18+) → Account Creation Screen
- Failure (<18) → Access Denied Screen
- "Exit" → Close app

---

### 7.2 Access Denied Screen (Under 18)
**Purpose**: Inform user they cannot access the app.

**Layout**:
```
┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │  Access Restricted    │  │
│  │                       │  │
│  │  StyleSync is only    │  │
│  │  available to users   │  │
│  │  18 years and older.  │  │
│  │                       │  │
│  │  We cannot create an  │  │
│  │  account for you at   │  │
│  │  this time.           │  │
│  │                       │  │
│  │  If you believe this  │  │
│  │  is an error:         │  │
│  │                       │  │
│  │  [Request Review]     │  │
│  │  [Exit]               │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Elements**:
- Clear denial message
- Explanation
- Appeal option
- Exit button

**Behavior**:
- All user data from verification attempt is purged
- No account created
- 24-hour cooldown before retry

**Navigation**:
- "Request Review" → Third-Party Verification Screen
- "Exit" → Close app

---

### 7.3 Third-Party Verification Screen
**Purpose**: Offer high-assurance age verification via third-party service.

**Layout**:
```
┌─────────────────────────────┐
│  [← Back]  Age Verification │
│                             │
│  Enhanced Verification      │
│                             │
│  To verify your age, we     │
│  partner with a trusted     │
│  third-party service.       │
│                             │
│  What happens:              │
│  • You'll be redirected to  │
│    our verification partner │
│  • Provide ID or other      │
│    verification method      │
│  • Results sent back to us  │
│  • Your ID is not stored    │
│    by StyleSync             │
│                             │
│  Privacy:                   │
│  • Only verification result │
│    is shared (pass/fail)    │
│  • No personal data stored  │
│                             │
│  [Start Verification]       │
│  [Cancel]                   │
│                             │
└─────────────────────────────┘
```

**Elements**:
- Title
- Process explanation
- Privacy guarantees
- Action buttons

**Navigation**:
- "Start Verification" → External verification service (Jumio/Yoti)
- Success → Account Creation Screen
- Failure → Access Denied Screen (permanent)
- "Cancel" → Return to Access Denied Screen

---

### 7.4 Verification Success Screen
**Purpose**: Confirm successful age verification.

**Layout**:
```
┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │  ✓ Verified           │  │
│  │                       │  │
│  │  Your age has been    │  │
│  │  successfully verified│  │
│  │                       │  │
│  │  You can now create   │  │
│  │  your StyleSync       │  │
│  │  account.             │  │
│  │                       │  │
│  │  [Continue to Signup] │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Elements**:
- Success icon
- Confirmation message
- Continue button

**Navigation**:
- "Continue to Signup" → Account Creation Screen

---

## 8. Additional Screens & States

### 8.1 Loading States
All screens with async operations should show loading indicators:

```
┌─────────────────────────────┐
│                             │
│         ⏳                  │
│                             │
│      Loading...             │
│                             │
└─────────────────────────────┘
```

### 8.2 Empty States

**Empty Closet**:
```
┌─────────────────────────────┐
│  My Closet        [+ Upload]│
│                             │
│                             │
│         👕                  │
│                             │
│  Your closet is empty       │
│                             │
│  Upload your first clothing │
│  item to get started!       │
│                             │
│    [Upload Photo]           │
│                             │
│  [Closet] [Try-On] [Outfits]│
└─────────────────────────────┘
```

**Empty Outfits**:
```
┌─────────────────────────────┐
│  My Outfits      [+ Create] │
│                             │
│                             │
│         🎨                  │
│                             │
│  No outfits yet             │
│                             │
│  Create your first outfit   │
│  combination!               │
│                             │
│    [Create Outfit]          │
│                             │
│  [Closet] [Try-On] [Outfits]│
└─────────────────────────────┘
```

### 8.3 Error States

**Network Error**:
```
┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │  ⚠️ Connection Error  │  │
│  │                       │  │
│  │  Unable to connect to │  │
│  │  the network.         │  │
│  │                       │  │
│  │  Please check your    │  │
│  │  internet connection  │  │
│  │  and try again.       │  │
│  │                       │  │
│  │  [Retry]              │  │
│  │  [Cancel]             │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**API Error**:
```
┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │  ⚠️ API Error         │  │
│  │                       │  │
│  │  Something went wrong │  │
│  │  with the AI service. │  │
│  │                       │  │
│  │  Error: [error msg]   │  │
│  │                       │  │
│  │  [Retry]              │  │
│  │  [Report Issue]       │  │
│  │  [Cancel]             │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Storage Quota Exceeded**:
```
┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │  🚫 Storage Full      │  │
│  │                       │  │
│  │  You've reached your  │  │
│  │  storage limit:       │  │
│  │                       │  │
│  │  500/500 items        │  │
│  │  2.0GB/2GB            │  │
│  │                       │  │
│  │  Delete some items to │  │
│  │  free up space.       │  │
│  │                       │  │
│  │  [Manage Items]       │  │
│  │  [Cancel]             │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

---

## 9. Navigation Flow Diagram

```
App Launch
    ↓
[First Time?]
    ↓ Yes                          ↓ No (Returning User)
Onboarding Flow                    ↓
    ↓                              ↓
Welcome Screen                 Login Screen (1.3b)
    ↓                              │
Age Gate (18+)                     │  ←── "Create Account" link
    ↓ Pass                         │       goes to Account Creation
Account Creation (1.3) ─────────→  │  ←── "Sign In" link
    │                              │       goes to Login Screen
    ↓                              ↓
API Key Tutorial              Main App
    ↓                          ├─→ Digital Closet (Tab 1)
API Key Input                  │   ├─→ Upload Flow
    ↓                          │   ├─→ Item Detail
Main App ←─────────────────────┘   └─→ Face Detection Consent
    │
    ├─→ Digital Closet (Tab 1)
    │   ├─→ Upload Flow
    │   ├─→ Item Detail
    │   └─→ Face Detection Consent
    │
    ├─→ Virtual Try-On (Tab 2)
    │   ├─→ Biometric Consent
    │   ├─→ Generation Progress
    │   ├─→ Result Display
    │   └─→ Rate Limit Modal
    │
    ├─→ Outfit Canvas (Tab 3)
    │   ├─→ Create Outfit
    │   ├─→ Save Outfit
    │   ├─→ Outfit Gallery
    │   └─→ AI Suggestions
    │
    └─→ Settings (Menu)
        ├─→ API Key Management
        ├─→ Cloud Backup
        ├─→ Usage History
        ├─→ Consent Management
        ├─→ Account Deletion
        └─→ Sign Out Options Dialog (6.1b)
            ├─→ Sign Out → Login Screen (1.3b)
            └─→ Sign Out & Clear Data → Login Screen (1.3b)
```

---

## 10. Design Principles

### Consistency
- Use consistent spacing (8px grid system)
- Maintain button hierarchy (primary, secondary, tertiary)
- Consistent iconography throughout

### Accessibility
- Minimum touch target: 44x44pt
- Color contrast ratio: 4.5:1 for text
- Support for screen readers
- Clear focus indicators

### Feedback
- Loading states for all async operations
- Success/error messages for all actions
- Progress indicators for long operations
- Haptic feedback for important actions

### Privacy-First
- Clear consent dialogs
- Transparent data usage explanations
- Easy access to privacy controls
- Prominent security indicators

---

## 11. Responsive Considerations

### Phone (Primary Target)
- Single column layouts
- Bottom navigation for main tabs
- Full-screen modals
- Swipe gestures for navigation

### Tablet (Future)
- Two-column layouts where appropriate
- Side navigation instead of bottom tabs
- Popover modals instead of full-screen
- Drag-and-drop enhancements

---

## Notes for Implementation

1. All wireframes are low-fidelity and focus on layout/flow
2. Final visual design (colors, typography, imagery) to be determined
3. Animations and transitions not specified but should be smooth
4. All text is placeholder and should be reviewed for clarity
5. Icon choices are suggestions and can be refined
6. Consider platform-specific patterns (iOS vs Android)

