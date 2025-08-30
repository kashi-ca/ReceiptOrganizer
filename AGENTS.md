# Repository Guidelines

## Project Structure & Module Organization
- `ReceiptOrganizer/`: SwiftUI app sources (`ReceiptOrganizerApp.swift`, `ContentView.swift`).
- `ReceiptOrganizer/Models`, `Views`, `Store`, `Services`, `Utilities`, `Config`: app modules (OCR, camera, state, helpers, flags).
- `ReceiptOrganizer/Assets.xcassets`: Images, app icon, and colors.
- `ReceiptOrganizer.xcodeproj/`: Xcode project, schemes, and workspace data.

## Build, Test, and Development Commands
- Open in Xcode: `open ReceiptOrganizer.xcodeproj`
- Build (generic sim): `xcodebuild -project ReceiptOrganizer.xcodeproj -scheme ReceiptOrganizer -destination 'generic/platform=iOS Simulator' build`
- Build (iPhone 16 Pro): `xcodebuild -project ReceiptOrganizer.xcodeproj -scheme ReceiptOrganizer -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build`
- Run tests (when a test target exists): `xcodebuild test -project ReceiptOrganizer.xcodeproj -scheme ReceiptOrganizer -destination 'platform=iOS Simulator,name=iPhone 16 Pro'`
- SwiftUI previews: edit and run previews in Xcode; keep preview code lightweight and deterministic.

## Coding Style & Naming Conventions
- Swift 6; Observable pattern for view models.
- Indentation: 4 spaces; line length ~120.
- Naming: `PascalCase` for types/protocols, `lowerCamelCase` for vars/functions, `SCREAMING_SNAKE_CASE` for constants only when appropriate.
- SwiftUI: views end with `View` (e.g., `ReceiptsListView`); modifiers on separate lines for readability.
- Prefer `struct` over `class` when possible; use `let` for immutability.
- Linters/formatters: none configured yet. If using locally, align with Swift API Design Guidelines; optional tools: `swiftformat .`, `swiftlint`.

## Testing Guidelines
- Framework: XCTest. Create a `ReceiptOrganizerTests` target in Xcode.
- File naming: `<FeatureName>Tests.swift`; test functions `test...()` with clear arrange/act/assert sections.
- Coverage: target 80%+ for core logic (parsing, storage, utilities). UI snapshot tests optional.
- Run via Xcode or CLI command above after adding the test target.

## Commit & Pull Request Guidelines
- Commits: adopt Conventional Commits (e.g., `feat: add receipt model`, `fix: prevent duplicate scans`, `chore: update icons`). Keep changes focused.
- PRs: include a concise summary, linked issues, screenshots for UI changes, and testing steps. Ensure project builds and tests pass.
- Branch naming: `type/short-topic` (e.g., `feat/scanner-flow`, `fix/crash-on-save`).

## Dev Flags & OCR Notes
- Toggle sample image vs camera in `ReceiptOrganizer/Config/AppConfig.swift`: `useLocalSampleReceipt = true` (sample) or `false` (camera).
- Sample asset override: add `SampleReceipt` to `Assets.xcassets`; otherwise a receipt-like image is generated at runtime.
- OCR uses Vision `VNRecognizeTextRequest` with language correction (default `en_US`).

## Security & Configuration Tips
- Do not commit secrets. Prefer `.xcconfig` files for API keys and add them to `.gitignore`.
- Use SF Symbols where possible to minimize bundled assets; place custom images under `Assets.xcassets` with descriptive names.
