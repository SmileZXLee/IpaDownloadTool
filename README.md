# IpaDownloadTool

Native Apple-only IPA extraction utility for iOS 26.

## Stack

- Swift
- SwiftUI
- WKWebView
- URLSession
- AVFoundation
- Xcode string catalog localization
- Liquid Glass on iOS 26 system surfaces and custom glass panels

## Features

- Open third-party download pages and detect `itms-services` manifests
- Detect direct `.ipa` links and save them into local history
- Download IPA files into local app storage and share them with system share sheets
- Scan QR codes with the built-in camera flow
- Import and export local history data
- Localized UI and app metadata for `en` and `zh-Hans`

## Structure

```text
IpaDownloadTool/
  IpaDownloadTool/
    Resources/
    Sources/
      App/
      Core/
      Features/
      Shared/
  Tests/
    UI/
    Unit/
```

## Notes

- The legacy Objective-C, XIB, CocoaPods, and workspace files have been removed.
- Provisioning-profile callback parsing from the old app is no longer emulated inside the app; those links are handed off to Safari.
- The app is intended for learning and testing only. Do not use it for illegal extraction or distribution.
