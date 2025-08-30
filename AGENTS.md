# Repository Guidelines

## Project Structure & Module Organization
- `ReceiptOrganizer/`: SwiftUI app sources (`ReceiptOrganizerApp.swift`, `ContentView.swift`).
- `ReceiptOrganizer/Assets.xcassets`: Images, app icon, and colors.
- `ReceiptOrganizer.xcodeproj/`: Xcode project, schemes, and workspace data.
- Suggested organization: group code by feature under `ReceiptOrganizer/Features/<FeatureName>/` (e.g., `ReceiptsList/`, `Scanner/`, `Storage/`). Place shared types in `ReceiptOrganizer/Shared/`.

## Build, Test, and Development Commands
- Open in Xcode: `open ReceiptOrganizer.xcodeproj`
- Build (CLI): `xcodebuild -project ReceiptOrganizer.xcodeproj -scheme ReceiptOrganizer -destination 'platform=iOS Simulator,name=iPhone 15' build`
- Run tests (once a test target exists): `xcodebuild test -project ReceiptOrganizer.xcodeproj -scheme ReceiptOrganizer -destination 'platform=iOS Simulator,name=iPhone 15'`
- SwiftUI previews: edit and run previews in Xcode; keep preview code lightweight and deterministic.

## Coding Style & Naming Conventions
- Swift 6, Observable pattern for View models
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

## Security & Configuration Tips
- Do not commit secrets. Prefer `.xcconfig` files for API keys and add them to `.gitignore`.
- Use SF Symbols where possible to minimize bundled assets; place custom images under `Assets.xcassets` with descriptive names.
