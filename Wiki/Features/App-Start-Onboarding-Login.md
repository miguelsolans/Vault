# App Start, Onboarding, and Login

## Feature Summary

Vault starts by looking for a stored favorite Vault. If no valid favorite Vault exists, the app shows onboarding and drives the user into Vault creation. If a favorite Vault exists and PIN-on-launch is enabled, the app shows PIN login before entering the private tab area.

## Confirmed Behavior

- App entry is coordinated by `AppCoordinator.start()` and `navigateToInitialPage()`.
- The favorite Vault ID is stored in `UserDefaultsManager.favoriteVault`.
- If the favorite Vault value is missing, invalid, not found, or repository access fails, the app navigates to onboarding.
- If `requiresPinOnLaunch == true` and the coordinator has not authenticated during the current runtime, the app navigates to PIN login.
- Successful onboarding sets `isAuthenticated = true` and re-runs initial navigation.
- Successful PIN login sets `isAuthenticated = true` and re-runs initial navigation.
- Private area is a tab bar with Overview, Operations, Categories, and Settings.

## Inferred Behavior

- Onboarding is currently the recovery path for both first launch and broken favorite Vault state.
- Authentication state is in-memory only; it resets when a new `AppCoordinator` is created.

## Unknown Behavior

- Whether onboarding should be shown after data corruption or whether a dedicated recovery/error screen should exist.
- Whether users can skip onboarding without creating a Vault.
- Whether PIN should be required after app backgrounding, not only app launch.

## Primary Flow

1. User launches app.
2. `AppCoordinator` checks `favoriteVault`.
3. If no usable favorite Vault exists, onboarding starts.
4. User creates the first Vault.
5. `CreateVaultUseCase` stores the first Vault as favorite.
6. Onboarding finishes and initial navigation is re-evaluated.
7. If PIN is not required, user enters the private tab area.

## PIN Flow

1. User launches app with a valid favorite Vault.
2. `requiresPinOnLaunch` is true and `isAuthenticated` is false.
3. Login coordinator displays the 4-digit PIN screen.
4. `LoginPinViewModel` verifies input against Keychain.
5. On success, app enters the private tab area.

## Screens

- Onboarding intro: `Features/Onboarding/Intro/View/IntroViewController.swift`
- Create Vault: `Features/Vault/Create/View/CreateVaultViewController.swift`
- Login PIN: `Shared/ProjectUI/Pin View/PinViewController.swift`
- Private tab bar: `Features/TabBar/View/TabBar.swift`

## Business Rules

- A Vault is required before entering the private area.
- The first created Vault becomes the favorite Vault.
- PIN login is required only when `requiresPinOnLaunch` is true and the coordinator has not authenticated.
- A PIN must be exactly 4 digits at the PIN view model level.

## Edge Cases

- Favorite Vault ID exists in UserDefaults but cannot be parsed as UUID: onboarding opens.
- Favorite Vault ID parses but repository cannot find it: onboarding opens.
- User enters the wrong PIN: no navigation occurs; no lockout rule is implemented.
- Keychain has no PIN but PIN-on-launch is true: verification always fails.

## Calculations

No feature-specific formulas are confirmed.

## Architecture Notes

- `AppCoordinator` owns top-level routing.
- Onboarding and login are separate coordinators.
- Authentication state is split between persistent flags in UserDefaults and in-memory `isAuthenticated`.
- PIN secret storage is isolated in `KeychainManager`.

## Code Ownership

- Coordinator: `App/AppCoordinator.swift`, `App/AppCoordinator+Onboarding.swift`, `App/AppCoordinator+Login.swift`, `App/AppCoordinator+Private.swift`
- Auth storage: `Shared/Managers/UserDefaultsManager.swift`, `Shared/Managers/KeychainManager.swift`
- PIN UI: `Shared/ProjectUI/Pin View/*`

## Decision Blocks

> **Decision Block: START-001 - Broken Favorite Vault Recovery**
>
> Status: Unknown
>
> Current code routes missing or invalid favorite Vault states to onboarding. Decide whether this is intended recovery behavior or whether the user should see a data recovery/select Vault screen.

> **Decision Block: AUTH-001 - PIN Lockout and Retry Policy**
>
> Status: Unknown
>
> Current code has no retry limit, delay, lockout, error message, or recovery path for failed PIN attempts. Decide the security policy before presenting PIN as a protective feature.

> **Decision Block: AUTH-002 - App Background Authentication**
>
> Status: Unknown
>
> Current code checks PIN on launch routing only. Decide whether background/resume should also require authentication.
