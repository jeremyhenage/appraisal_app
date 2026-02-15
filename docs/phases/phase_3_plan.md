# Implementation Plan - Phase 3: Frontend UI Development

## Goal Description

Build the "Tactical Dark" UI for the Flutter application. This includes the global theme, the real-time Camera/OCR screen with reticle overlay, and the Deal Dashboard for displaying analysis results.

## User Review Required

> [!NOTE]
> The design system uses specific colors defined in the PRD (Deep Matte Grey #121212, Neon Cyan #00E5FF). Verify these on a real device if possible.

## Proposed Changes

### Core / Design System

#### [NEW] [lib/core/theme/app_theme.dart](file:///Users/jeremy/Documents/projects/AppraisalApp/lib/core/theme/app_theme.dart)

- Implement `flex_color_scheme` or manual `ThemeData`.
- Colors:
  - Surface: `#121212`
  - Primary: `#00E5FF` (Cyan)
  - Success: `#00FF41` (Matrix Green)
  - Error: `#FF0055` (Bitcrush Red)
- Typography: `JetBrains Mono` (Headers), `Inter` (Body).

### Features

#### [NEW] [lib/features/appraisal/presentation/screens/camera_screen.dart](file:///Users/jeremy/Documents/projects/AppraisalApp/lib/features/appraisal/presentation/screens/camera_screen.dart)

- Uses `camera` package.
- Overlay: "Targeting Reticle" (CustomPainter).
- Integration: `google_ml_kit_text_recognition` for real-time text block highlighting.
- logic: Tap text to "Lock" (add to chip list).

#### [NEW] [lib/features/appraisal/presentation/screens/deal_dashboard_screen.dart](file:///Users/jeremy/Documents/projects/AppraisalApp/lib/features/appraisal/presentation/screens/deal_dashboard_screen.dart)

- Displays `AppraisalResponse` data.
- "Deal Card" layout.
- "Liquidity Traffic Light" widget.

### Navigation

#### [MODIFY] [lib/main.dart](file:///Users/jeremy/Documents/projects/AppraisalApp/lib/main.dart)

- Set up routing/navigation.
- Apply `AppTheme`.

## Verification Plan

### Manual Verification

- **Visual Check**: Run on iOS Simulator / Android Emulator.
- Verify "Tactical Dark" aesthetic (contrast, fonts).
- Verify Camera permission handling and preview feed.
