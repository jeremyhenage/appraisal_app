---
description: Run the Appraisal App locally on macOS or connected device
---

## Prerequisites (macOS)

- **Xcode**: Must be installed from the Mac App Store.
- **CocoaPods**: Must be installed.
  - **Preferred**: `brew install cocoapods`
  - **Alternative**: `sudo gem install cocoapods` (May require system permissions)

1. Ensure dependencies are installed

```bash
flutter pub get
```

// turbo 2. Run on macOS (Desktop)

```bash
./scripts/run_macos.sh
```

OR run on a connected mobile device:

```bash
flutter run
```
