# StyleSync User Testing Guide

## Overview

This document provides guidelines for conducting user testing of the StyleSync clickable prototype. The goal is to validate UX assumptions, identify usability issues, and gather feedback before implementation.

## Testing Objectives

1. **Onboarding Clarity**: Can users understand how to obtain and configure a Gemini API key?
2. **Consent Flows**: Do users understand what they're consenting to (face detection, biometric data)?
3. **Age Verification**: Is the 18+ age gate process clear and frictionless?
4. **Rate Limit Messaging**: Do users understand quota limits and the upgrade path?
5. **Navigation**: Is the information architecture intuitive?
6. **Feature Discovery**: Can users find and use core features?

## Participant Criteria

### Target Participants: 3-5 users

**Mix of:**
- 2-3 technical users (developers, tech-savvy)
- 2-3 non-technical users (general consumers)

**Requirements:**
- Age 18+ (to test age gate from verified user perspective)
- Smartphone users (iOS or Android)
- Interest in fashion/wardrobe management
- No prior exposure to the prototype

**Exclusions:**
- Project team members
- Users under 18 (cannot test full flow)

## Testing Environment

### Setup
- **Tool**: Figma/Adobe XD prototype link
- **Device**: Participant's own smartphone (preferred) or provided device
- **Duration**: 30-45 minutes per session
- **Location**: Remote (video call) or in-person

### Materials Needed
- Prototype link
- Testing script (below)
- Note-taking template
- Screen recording tool (with consent)
- Post-test questionnaire

## Testing Script

### Introduction (5 minutes)

**Say to participant:**

"Thank you for participating in this user testing session. We're testing a new mobile app called StyleSync that helps you manage your digital wardrobe and try on clothes virtually using AI.

This is a prototype, so not everything will work perfectly. We're testing the design, not you. There are no wrong answers. Please think aloud as you go through the tasks - tell me what you're thinking, what you expect to happen, and any confusion you experience.

I'll be taking notes and may ask follow-up questions. Do you have any questions before we begin?

[If recording] May I record this session for note-taking purposes? The recording will only be used internally and will be deleted after we document our findings."

### Task 1: Onboarding Flow (10 minutes)

**Scenario:**
"Imagine you've just downloaded StyleSync for the first time. Walk me through what you would do."

**Observe:**
- Do they read the welcome screen content?
- Do they understand the API key tutorial?
- Can they explain what a Gemini API key is after reading?
- Do they understand the difference between Free and Paid tiers?
- Do they feel confident they could obtain an API key?

**Questions:**
1. "What is your understanding of what an API key is?"
2. "How confident do you feel about getting your own API key? (1=not confident, 5=very confident)"
3. "What concerns, if any, do you have about providing your own API key?"
4. "Is there anything confusing about the onboarding process?"

### Task 2: Age Verification (5 minutes)

**Scenario:**
"You're now at the age verification screen. What do you think about this step?"

**Observe:**
- Do they understand why age verification is required?
- Do they have privacy concerns about providing DOB?
- Is the privacy notice clear?
- Do they understand the third-party verification option?

**Questions:**
1. "Why do you think the app requires age verification?"
2. "Do you feel comfortable providing your date of birth? Why or why not?"
3. "Is the privacy notice clear about how your DOB is used?"
4. "What would you do if you were denied access?"

### Task 3: Upload Clothing Item (10 minutes)

**Scenario:**
"You want to add a shirt to your digital closet. Show me how you would do that."

**Observe:**
- Can they find the upload button?
- Do they understand the face detection consent dialog?
- Do they understand why face detection is needed?
- Do they notice the processing steps?
- Do they understand what happens if a face is detected?

**Questions:**
1. "What is your understanding of why the app scans for faces?"
2. "Do you feel comfortable with this privacy protection measure?"
3. "Is it clear what happens to your photos?"
4. "Would you prefer to skip face detection? Why or why not?"

### Task 4: Virtual Try-On (10 minutes)

**Scenario:**
"You want to see how a clothing item looks on you. Show me how you would do that."

**Observe:**
- Can they find the try-on feature?
- Do they understand the biometric consent dialog?
- Can they select a clothing item and photo?
- Do they understand the generation mode options?
- Do they notice the generation progress?

**Questions:**
1. "What is your understanding of what happens to your photo?"
2. "Do you feel comfortable using this feature? Why or why not?"
3. "Is it clear how long the process will take?"
4. "What would you do with the generated result?"

### Task 5: Rate Limit Scenario (5 minutes)

**Scenario:**
"You've been using the app and see this warning banner. What does it mean?"

[Show 80% warning banner]

**Then:**
"Now you see this message. What would you do?"

[Show 100% rate limit modal]

**Observe:**
- Do they understand what a quota is?
- Do they understand when it resets?
- Do they understand how to upgrade?
- Is the messaging clear and not alarming?

**Questions:**
1. "What is your understanding of why you're seeing this message?"
2. "Is it clear what you need to do to continue using the app?"
3. "Is the reset time clear?"
4. "Would you consider upgrading to a paid tier? Why or why not?"

### Task 6: Free Exploration (5 minutes)

**Scenario:**
"Feel free to explore the app. Try to create an outfit or look at the settings."

**Observe:**
- What features do they naturally gravitate toward?
- Do they discover the outfit canvas?
- Do they explore settings?
- What do they comment on positively?
- What causes confusion?

**Questions:**
1. "What feature are you most excited about?"
2. "What feature would you use most often?"
3. "Is there anything you expected to find but didn't?"
4. "Is there anything that seems unnecessary?"

### Closing Questions (5 minutes)

1. "Overall, how would you rate the ease of use of this app? (1-5 scale)"
2. "How likely would you be to use this app? (1-5 scale)"
3. "What is the most confusing part of the app?"
4. "What is the best part of the app?"
5. "If you could change one thing, what would it be?"
6. "Do you have any other feedback or suggestions?"

**Thank participant:**
"Thank you so much for your time and feedback. Your input is incredibly valuable and will help us improve the app before we build it."

## Note-Taking Template

### Participant Information
- **ID**: P1, P2, P3, etc.
- **Date**: 
- **Technical Level**: Technical / Non-technical
- **Age Range**: 18-25, 26-35, 36-45, 46+
- **Device**: iOS / Android

### Task Observations

For each task, note:
- **Success**: Did they complete the task? (Yes/No/Partial)
- **Time**: How long did it take?
- **Errors**: What mistakes did they make?
- **Confusion**: What caused confusion?
- **Quotes**: Notable things they said
- **Suggestions**: Ideas they mentioned

### Ratings

| Question | Rating (1-5) | Notes |
|----------|--------------|-------|
| Confidence getting API key | | |
| Comfort with age verification | | |
| Comfort with face detection | | |
| Comfort with biometric consent | | |
| Understanding of rate limits | | |
| Overall ease of use | | |
| Likelihood to use app | | |

### Key Findings

**Positive:**
- What worked well?
- What did users like?

**Negative:**
- What didn't work?
- What caused frustration?

**Surprising:**
- What unexpected behaviors occurred?
- What assumptions were wrong?

## Analysis Framework

### Severity Ratings

**Critical (P0):**
- Prevents task completion
- Causes data loss or security concerns
- Violates legal/compliance requirements

**High (P1):**
- Causes significant confusion
- Requires workaround to complete task
- Affects majority of users

**Medium (P2):**
- Causes minor confusion
- Affects some users
- Has easy workaround

**Low (P3):**
- Cosmetic issues
- Affects few users
- Nice-to-have improvements

### Success Metrics

**Onboarding:**
- ✅ 80%+ understand how to get API key
- ✅ 80%+ feel confident they could obtain key
- ✅ 70%+ understand Free vs Paid tiers

**Consent Flows:**
- ✅ 90%+ understand face detection purpose
- ✅ 90%+ understand biometric consent
- ✅ 80%+ feel comfortable with privacy measures

**Age Verification:**
- ✅ 90%+ understand why verification is required
- ✅ 80%+ comfortable providing DOB
- ✅ 90%+ understand privacy notice

**Rate Limits:**
- ✅ 80%+ understand quota concept
- ✅ 80%+ understand reset time
- ✅ 70%+ understand upgrade path

**Navigation:**
- ✅ 90%+ can find upload feature
- ✅ 90%+ can find try-on feature
- ✅ 80%+ can find outfit canvas
- ✅ 80%+ can find settings

## Reporting Template

See `user-testing-report-template.md` for the complete report template.

## Tips for Facilitators

### Do:
- ✅ Encourage thinking aloud
- ✅ Ask open-ended questions
- ✅ Observe body language and facial expressions
- ✅ Take detailed notes
- ✅ Remain neutral and non-leading
- ✅ Give participants time to struggle (don't help immediately)

### Don't:
- ❌ Lead participants to answers
- ❌ Defend design decisions
- ❌ Interrupt participants
- ❌ Make participants feel bad about mistakes
- ❌ Skip tasks if time is short (prioritize instead)

### Handling Common Situations

**Participant is stuck:**
- Wait 30 seconds
- Ask: "What are you thinking right now?"
- If still stuck: "What would you expect to happen if you tapped here?"
- Last resort: "Let me show you where that is, and we'll continue"

**Participant is rushing:**
- "Take your time, there's no rush"
- "Can you tell me what you're thinking as you do that?"

**Participant is too polite:**
- "Remember, we're testing the design, not you"
- "Honest feedback, even if negative, is most helpful"
- "What would you tell a friend about this?"

## Post-Testing Actions

1. **Consolidate Notes**: Compile all participant notes within 24 hours
2. **Identify Patterns**: Look for issues mentioned by 2+ participants
3. **Prioritize Issues**: Use severity ratings
4. **Create Report**: Use report template
5. **Share Findings**: Present to team
6. **Update Prototype**: Iterate based on feedback
7. **Retest if Needed**: Test critical changes with 1-2 users

## Timeline

| Activity | Duration | Responsible |
|----------|----------|-------------|
| Recruit participants | 3-5 days | PM/Designer |
| Conduct sessions | 3-5 days | Designer/Researcher |
| Analyze findings | 2-3 days | Designer/Researcher |
| Create report | 1-2 days | Designer/Researcher |
| Present findings | 1 day | Designer/Researcher |
| Update prototype | 3-5 days | Designer |
| **Total** | **13-21 days** | |

