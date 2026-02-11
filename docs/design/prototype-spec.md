# StyleSync - Clickable Prototype Specification

## Overview
This document provides specifications for creating an interactive clickable prototype of StyleSync. The prototype should demonstrate all critical user flows and interactions without requiring actual implementation.

## Prototype Tool Recommendations
- **Figma** (Recommended): Best for collaboration, has component system, easy sharing
- **Adobe XD**: Good alternative with similar features
- **Sketch + InVision**: For Mac-only teams
- **Framer**: For more advanced interactions

## Prototype Structure

### Artboards/Frames Required
Total screens: ~55 unique screens + variants

#### 1. Onboarding Flow (6 screens)
- Welcome Screen
- API Key Tutorial Screen
- API Key Input Screen
- API Key Input - Loading State
- API Key Input - Error State
- API Key Input - Success State

#### 2. Age Verification Flow (5 screens)
- Age Gate Screen
- Age Gate - Under 18 Error
- Third-Party Verification Info
- Verification Success
- Access Denied (Permanent)

#### 3. Digital Closet Flow (12 screens)
- Closet Main - Empty State
- Closet Main - With Items
- Upload Options Modal
- Face Detection Consent Dialog
- Upload Processing Screen
- Face Detected Warning Modal
- Item Detail Screen
- Item Delete Confirmation
- Closet - Category Filtered View
- Storage Quota Warning
- Storage Quota Exceeded Modal
- Closet - Loading State

#### 4. Virtual Try-On Flow (10 screens)
- Try-On Main Screen
- Try-On - Item Selected
- Try-On - Photo Selected
- Biometric Consent Dialog
- Generation Progress Screen
- Try-On Result Screen
- Try-On Error Modal
- Try-On - Save Confirmation
- Try-On - Share Sheet
- Try-On - Rate Limited State

#### 5. Rate Limit Flow (4 screens)
- Warning Banner (80%)
- Rate Limit Info Modal
- Rate Limit Modal (100%)
- Usage History Screen

#### 6. Outfit Canvas Flow (6 screens)
- Outfit Canvas - Empty
- Outfit Canvas - With Items
- Save Outfit Dialog
- Outfit Gallery - Empty
- Outfit Gallery - With Outfits
- AI Suggestions Screen

#### 7. Settings Flow (8 screens)
- Settings Main Screen
- API Key Management
- Cloud Backup Settings
- Cloud Backup - Enable Dialog
- Usage History
- Consent Management
- Sign Out Options Dialog
- Account Deletion Confirmation

#### 8. Global States (4 screens)
- Network Error Modal
- API Error Modal
- Generic Loading Screen
- Success Toast/Snackbar

---

## Interactive Elements & Hotspots

### Navigation Patterns

#### Bottom Navigation (Main Tabs)
```
Hotspot: "Closet" tab → Navigate to Digital Closet Main
Hotspot: "Try-On" tab → Navigate to Virtual Try-On Main
Hotspot: "Outfits" tab → Navigate to Outfit Gallery
```

#### Back Buttons
```
Hotspot: "← Back" → Navigate to previous screen in flow
```

#### Modal Overlays
```
Interaction: Click outside modal → Close modal
Hotspot: "X" or "Cancel" → Close modal
```

### Onboarding Flow Interactions

**Welcome Screen**:
```
Hotspot: "Get Started" button
  → Navigate to: API Key Tutorial Screen
  → Transition: Slide left
```

**API Key Tutorial Screen**:
```
Hotspot: "Open Google Cloud Console" button
  → Action: Show toast "Opens external browser"
  → Stay on current screen

Hotspot: "Open Vertex AI Setup" button
  → Action: Show toast "Opens external browser"
  → Stay on current screen

Hotspot: "Continue" button
  → Navigate to: API Key Input Screen
  → Transition: Slide left
```

**API Key Input Screen**:
```
Hotspot: API Key text field
  → Action: Show keyboard overlay (optional)
  → Enable "Validate & Continue" button when filled

Hotspot: Project ID text field
  → Action: Show keyboard overlay (optional)
  → Enable "Validate & Continue" button when filled

Hotspot: "Validate & Continue" button (enabled state)
  → Navigate to: API Key Input - Loading State
  → Auto-advance after 2 seconds to: Age Gate Screen
  → Transition: Fade

Hotspot: "Validate & Continue" button (disabled state)
  → Action: None (visual feedback only)
```

### Age Verification Flow Interactions

**Age Gate Screen**:
```
Hotspot: Month field
  → Action: Show number picker (01-12)

Hotspot: Day field
  → Action: Show number picker (01-31)

Hotspot: Year field
  → Action: Show number picker (1900-2026)

Hotspot: "Verify & Continue" button
  → Condition: If age >= 18
    → Navigate to: Verification Success Screen
    → Transition: Fade
  → Condition: If age < 18
    → Navigate to: Access Denied Screen
    → Transition: Fade

Hotspot: "Exit" button
  → Action: Show toast "App would close"
```

**Access Denied Screen**:
```
Hotspot: "Request Review" button
  → Navigate to: Third-Party Verification Info
  → Transition: Slide up

Hotspot: "Exit" button
  → Action: Show toast "App would close"
```

**Third-Party Verification Screen**:
```
Hotspot: "Start Verification" button
  → Navigate to: Verification Success Screen
  → Transition: Fade
  → Note: In real app, would open external service

Hotspot: "Cancel" button
  → Navigate to: Access Denied Screen
  → Transition: Slide down
```

### Digital Closet Flow Interactions

**Closet Main Screen**:
```
Hotspot: "+ Upload" button
  → Navigate to: Upload Options Modal
  → Transition: Slide up from bottom

Hotspot: Category filter chip (e.g., "Tops")
  → Navigate to: Closet - Category Filtered View
  → Transition: Fade
  → Visual: Highlight selected chip

Hotspot: Clothing item thumbnail
  → Navigate to: Item Detail Screen
  → Transition: Zoom in

Hotspot: Bottom nav tabs
  → Navigate to: Respective tab screen
  → Transition: Fade
```

**Upload Options Modal**:
```
Hotspot: "📷 Take Photo" button
  → Navigate to: Face Detection Consent Dialog
  → Transition: Fade

Hotspot: "🖼️ Choose from Library" button
  → Navigate to: Face Detection Consent Dialog
  → Transition: Fade

Hotspot: "Cancel" button
  → Navigate to: Closet Main Screen
  → Transition: Slide down

Hotspot: Click outside modal
  → Navigate to: Closet Main Screen
  → Transition: Slide down
```

**Face Detection Consent Dialog**:
```
Hotspot: "Allow Scanning" button
  → Navigate to: Upload Processing Screen
  → Transition: Fade

Hotspot: "Skip This Time" button
  → Navigate to: Upload Processing Screen
  → Transition: Fade
```

**Upload Processing Screen**:
```
Auto-advance: After 3 seconds
  → Condition: If face detected
    → Navigate to: Face Detected Warning Modal
    → Transition: Fade
  → Condition: If no face detected
    → Navigate to: Closet Main - With Items
    → Transition: Fade
```

**Face Detected Warning Modal**:
```
Hotspot: "Cancel Upload" button
  → Navigate to: Closet Main Screen
  → Transition: Fade

Hotspot: "Continue" button
  → Navigate to: Closet Main - With Items
  → Transition: Fade
```

**Item Detail Screen**:
```
Hotspot: "← Back" button
  → Navigate to: Closet Main - With Items
  → Transition: Zoom out

Hotspot: "⋮ Menu" button
  → Navigate to: Item Delete Confirmation
  → Transition: Slide up

Hotspot: "Try On" button
  → Navigate to: Virtual Try-On Main (with item pre-selected)
  → Transition: Fade

Hotspot: "Add to Outfit" button
  → Navigate to: Outfit Canvas - With Items
  → Transition: Fade
```

### Virtual Try-On Flow Interactions

**Try-On Main Screen**:
```
Hotspot: Clothing item thumbnail
  → Action: Highlight selected item
  → Visual: Add border/checkmark

Hotspot: "📷 Take Photo" button
  → Navigate to: Biometric Consent Dialog (first time)
  → Transition: Fade
  → Note: Subsequent times, skip consent

Hotspot: "🖼️ Choose Photo" button
  → Navigate to: Biometric Consent Dialog (first time)
  → Transition: Fade

Hotspot: Generation mode radio button
  → Action: Select mode
  → Visual: Fill radio button

Hotspot: "Generate Try-On" button (enabled)
  → Navigate to: Generation Progress Screen
  → Transition: Fade

Hotspot: "Generate Try-On" button (disabled)
  → Action: None (visual feedback only)
```

**Biometric Consent Dialog**:
```
Hotspot: "I Understand" button
  → Navigate to: Try-On Main Screen (photo selected state)
  → Transition: Fade

Hotspot: "Cancel" button
  → Navigate to: Try-On Main Screen
  → Transition: Fade
```

**Generation Progress Screen**:
```
Auto-advance: After 5 seconds
  → Navigate to: Try-On Result Screen
  → Transition: Fade

Hotspot: "Cancel" button
  → Navigate to: Try-On Main Screen
  → Transition: Fade
```

**Try-On Result Screen**:
```
Hotspot: "← Back" button
  → Navigate to: Try-On Main Screen
  → Transition: Fade

Hotspot: "Save to Device" button
  → Navigate to: Try-On - Save Confirmation
  → Transition: Toast from bottom

Hotspot: "Share" button
  → Navigate to: Try-On - Share Sheet
  → Transition: Slide up

Hotspot: "Try Another Item" button
  → Navigate to: Try-On Main Screen
  → Transition: Fade
```

### Rate Limit Flow Interactions

**Warning Banner (80%)**:
```
Hotspot: "Learn More" button
  → Navigate to: Rate Limit Info Modal
  → Transition: Slide up

Hotspot: "Dismiss" button
  → Action: Hide banner
  → Visual: Slide up and fade out
```

**Rate Limit Modal (100%)**:
```
Hotspot: "Enable Billing" button
  → Action: Show toast "Opens Google Cloud Console"
  → Stay on current screen

Hotspot: "View Usage History" button
  → Navigate to: Usage History Screen
  → Transition: Slide left

Hotspot: "OK" button
  → Action: Close modal
  → Navigate to: Previous screen
  → Transition: Fade
```

### Outfit Canvas Flow Interactions

**Outfit Canvas Screen**:
```
Hotspot: Clothing item thumbnail (in picker)
  → Action: Add item to canvas
  → Visual: Item appears on canvas

Hotspot: Item on canvas
  → Action: Show reorder/remove options
  → Visual: Highlight item with controls

Hotspot: Layer tab (Base/Mid/Outer/Acc)
  → Action: Filter items by layer
  → Visual: Highlight selected tab

Hotspot: "Save" button
  → Navigate to: Save Outfit Dialog
  → Transition: Slide up

Hotspot: "← Back" button
  → Condition: If outfit has items
    → Navigate to: Discard confirmation dialog
    → Transition: Fade
  → Condition: If outfit empty
    → Navigate to: Outfit Gallery
    → Transition: Fade
```

**Save Outfit Dialog**:
```
Hotspot: Name text field
  → Action: Show keyboard overlay (optional)

Hotspot: "Save" button
  → Navigate to: Outfit Gallery - With Outfits
  → Transition: Fade

Hotspot: "Cancel" button
  → Navigate to: Outfit Canvas Screen
  → Transition: Slide down
```

**Outfit Gallery Screen**:
```
Hotspot: Outfit card
  → Navigate to: Outfit Canvas - With Items (edit mode)
  → Transition: Fade

Hotspot: "+ Create" button
  → Navigate to: Outfit Canvas - Empty
  → Transition: Fade

Hotspot: "Get Missing Piece Ideas" button
  → Navigate to: AI Suggestions Screen
  → Transition: Slide left
```

### Settings Flow Interactions

**Settings Main Screen**:
```
Hotspot: "Sign Out" button
  → Navigate to: Sign Out Options Dialog
  → Transition: Slide up

Hotspot: "Update Key" button
  → Navigate to: API Key Input Screen
  → Transition: Slide left

Hotspot: "Cloud Backup" button
  → Navigate to: Cloud Backup Settings Screen
  → Transition: Slide left

Hotspot: "View History" button
  → Navigate to: Usage History Screen
  → Transition: Slide left

Hotspot: "Manage Consents" button
  → Navigate to: Consent Management Screen
  → Transition: Slide left

Hotspot: "Delete Account" button
  → Navigate to: Account Deletion Confirmation
  → Transition: Slide up
```

---

## Component Library

### Reusable Components to Create

#### Buttons
- Primary Button (filled, high emphasis)
- Secondary Button (outlined, medium emphasis)
- Text Button (text only, low emphasis)
- Icon Button (icon only)

#### Input Fields
- Text Input (single line)
- Text Area (multi-line)
- Number Picker
- Date Picker

#### Cards
- Clothing Item Card (thumbnail + label)
- Outfit Card (thumbnail + title + item count)
- Event Card (icon + title + description + timestamp)

#### Modals
- Full Screen Modal (mobile)
- Bottom Sheet Modal (mobile)
- Center Modal (tablet)
- Alert Dialog

#### Navigation
- Bottom Navigation Bar (3 tabs)
- Top App Bar (with back button)
- Page Indicator Dots

#### Feedback
- Loading Spinner
- Progress Bar
- Toast/Snackbar
- Warning Banner

#### Lists
- Grid View (3 columns)
- List View (single column)
- Horizontal Scroll List

---

## Interaction Patterns

### Transitions
- **Screen to Screen**: Slide left/right (300ms ease-in-out)
- **Modal Open**: Slide up from bottom (250ms ease-out)
- **Modal Close**: Slide down (200ms ease-in)
- **Tab Switch**: Fade (150ms)
- **Item Detail**: Zoom in/out (300ms ease-in-out)

### Gestures (Optional for Advanced Prototypes)
- **Swipe Right**: Go back (on screens with back button)
- **Swipe Down**: Dismiss modal (on modals)
- **Long Press**: Show context menu (on items)
- **Pinch**: Zoom (on canvas)

### Loading States
- **Spinner**: For indeterminate operations
- **Progress Bar**: For determinate operations (0-100%)
- **Skeleton Screens**: For content loading

### Micro-interactions
- **Button Press**: Scale down slightly (0.95x)
- **Toggle**: Smooth slide animation
- **Checkbox**: Checkmark animation
- **Radio Button**: Fill animation

---

## Prototype Testing Checklist

### Navigation Testing
- [ ] All buttons navigate to correct screens
- [ ] Back buttons return to previous screen
- [ ] Bottom navigation switches tabs correctly
- [ ] Modals can be dismissed

### Flow Completeness
- [ ] Onboarding flow: Welcome → Tutorial → Input → Success
- [ ] Age gate flow: Gate → Verification → Success/Denied
- [ ] Upload flow: Select → Consent → Process → View
- [ ] Try-on flow: Select → Consent → Generate → Result
- [ ] Rate limit flow: Warning → Modal → History
- [ ] Outfit flow: Create → Save → Gallery
- [ ] Settings flow: All sub-screens accessible

### Interaction Testing
- [ ] Buttons show hover/active states
- [ ] Disabled buttons don't respond to clicks
- [ ] Form fields show focus states
- [ ] Modals overlay correctly
- [ ] Transitions are smooth

### Content Testing
- [ ] All text is readable
- [ ] Icons are clear and appropriate
- [ ] Images/placeholders are present
- [ ] Error messages are helpful

### Edge Cases
- [ ] Empty states display correctly
- [ ] Loading states display correctly
- [ ] Error states display correctly
- [ ] Long text doesn't break layout

---

## Sharing & Collaboration

### Prototype Link Setup
1. Create shareable link with view-only access
2. Enable commenting for feedback
3. Set up presentation mode for demos
4. Create separate versions for:
   - Internal review
   - User testing
   - Stakeholder presentation

### Documentation to Include
- Link to this specification document
- Link to wireframes document
- User flow diagrams
- Component library reference

---

## Next Steps After Prototype

1. **User Testing**: Test with 3-5 users
2. **Feedback Collection**: Document findings
3. **Iteration**: Update prototype based on feedback
4. **Handoff**: Prepare design specs for developers
5. **API Contracts**: Finalize data structures (Task 7.3)

