# Xcode Security Settings

Security build settings decisions for CopyKit. Audited on 2026-11-02 with Apple's `audit-xcode-security-settings` skill (Xcode 27.2, macOS 27.2). The project is 100 % Swift, with one app target and two test bundles.

## Enabled settings

- `ENABLE_ENHANCED_SECURITY`: set at the project level (Debug and Release) and on the CopyKit app target. It cascades pointer authentication, security compiler warnings, stack zero-initialization, typed allocators and C++ stdlib hardening. The app now builds as `arm64e`.
- `com.apple.security.hardened-process`: on the CopyKit app, in `CopyKit/CopyKit.entitlements`, with `enhanced-security-version-string` set to `2`.
- `com.apple.security.hardened-process.hardened-heap`: on the CopyKit app (Memory Safety).
- `com.apple.security.hardened-process.dyld-ro`: on the CopyKit app (Runtime Protections).
- `com.apple.security.hardened-process.platform-restrictions-string` to `2`: on the CopyKit app (Runtime Protections).
- `com.apple.security.hardened-process.checked-allocations` with `soft-mode`: hardware memory tagging on the CopyKit app, in soft mode (simulated crash reports, no termination). It only takes effect on Mac computers with an M5 chip or later. Disable soft mode once the simulated crash reports are reviewed and fixed.
- `ENABLE_HARDENED_RUNTIME`: kept on the CopyKit app, required for Developer ID notarization.

## Disabled settings

- `ENABLE_APP_SANDBOX` to `NO`: the App Sandbox blocks the photos arriving from the iPhone through Universal Clipboard and makes the V3 window management impossible (Accessibility APIs are unsupported in the sandbox). The encrypted history is the main data protection instead. See `aidd_docs/memory/internal/decisions/hors-app-sandbox.md`.

## Deferred

Settings considered but not yet enabled. Revisit them later.

- `ENABLE_HARDWARE_CHECKED_POINTER_ARITHMETIC_SLICE` and `com.apple.security.hardened-process.checked-allocations.enforce-checked-pointer-arithmetic-overflow`: checked pointer arithmetic is only available on iOS and watchOS. Not applicable to a macOS app.
- Additional diagnostic settings (`CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION`, `CLANG_ANALYZER_SECURITY_BUFFER_OVERFLOW_EXPERIMENTAL`, `CLANG_WARN_ASSIGN_ENUM`, `GCC_WARN_SIGN_COMPARE`): they target C and Objective-C code; the project is 100 % Swift. Revisit if C or Objective-C code is added.
- C-family compiler, static analyzer and clang-tidy warnings: not applicable to a 100 % Swift project. Revisit if C or Objective-C code is added.
- `SWIFT_STRICT_MEMORY_SAFETY`: flags every unsafe Swift construct. Considered useful for an app that handles sensitive data, but not adopted yet. Revisit when the first code using raw pointers or `unsafe` APIs lands.
- `ENABLE_POINTER_AUTHENTICATION` on targets linking Sparkle: when Sparkle is added, check that its binary ships an `arm64e` slice. If it does not, set `ENABLE_POINTER_AUTHENTICATION = NO` (and `ENABLE_HARDWARE_CHECKED_POINTER_ARITHMETIC_SLICE = NO`) on the target that links it, without dropping the rest of Enhanced Security.
