# Settings and Security

## Feature Summary

Settings provides Vault management, security settings, app information placeholder, and delete-all-data. Security supports a 4-digit PIN stored in Keychain and a launch authentication toggle. Biometric authentication is present in UI state but disabled.

## Confirmed Behavior

- Settings tab has Vaults, Security, About, and Delete All Data rows.
- Vaults opens Vault management with create/edit/delete/favorite/export options.
- Security opens PIN/security settings.
- Delete All Data deletes all Vaults, resets UserDefaults, deletes PIN, and returns to initial app routing.
- PIN creation saves the PIN in Keychain.
- Enabling PIN sets `hasPinAuthentication` and `requiresPinOnLaunch`.
- Disabling the PIN toggle sets both values false but does not delete the stored PIN.
- PIN login verifies input using constant-time byte comparison for equal-length strings.
- Biometric authentication row is disabled.

## Inferred Behavior

- PIN is intended as app access protection, not encryption of Core Data contents.
- Auto-lock is a display-only setting at present.
- About is a placeholder.

## Unknown Behavior

- Whether disabling PIN should delete the Keychain PIN.
- Whether changing PIN should require current PIN verification.
- Whether biometric authentication should be implemented.
- Whether Delete All Data should require PIN or additional confirmation.
- Whether any data export should be suggested before destructive delete.

## Settings Flow

1. User opens Settings tab.
2. User chooses Vaults, Security, About, or Delete All Data.
3. Vaults and Security push child coordinators.
4. Delete All Data triggers confirmation callback in the view model.
5. Confirmed delete removes all Vault data, resets app settings, deletes PIN, and returns app to initial routing.

## PIN Flow

1. User opens Security.
2. If PIN is disabled, PIN row is navigable.
3. User creates a 4-digit PIN.
4. PIN is saved to Keychain.
5. `hasPinAuthentication` and `requiresPinOnLaunch` are enabled.
6. Future app launch requires PIN before private area.

## Screens

- Settings list: `Features/Settings/List/*`
- Security list: `Features/Settings/Security/*`
- Create PIN: `Features/Settings/Create PIN/*`
- Login PIN: `Features/Login/PIN/*`
- Shared PIN UI: `Shared/ProjectUI/Pin View/*`

## Business Rules

- PIN length is 4 digits.
- PIN is stored in Keychain under account `userPIN`.
- `requiresPinOnLaunch` controls launch-time PIN routing.
- Delete All Data removes Core Data Vaults and clears UserDefaults domain.
- Delete All Data also deletes stored PIN.

## Calculations

No feature-specific formulas are confirmed.

## Edge Cases

- Wrong PIN: no navigation and no user-facing failure state is defined.
- Missing Keychain PIN while PIN-on-launch is true: user cannot authenticate.
- Disabling PIN does not remove Keychain PIN; re-enabling behavior depends on UI path.
- Biometric authentication flags can be set by `CreatePinViewModel.setupFaceID()`, but UI has Face ID disabled.

## Architecture Notes

- Settings and Security use child coordinators under the Settings tab.
- PIN creation and login share the reusable PIN UI.
- UserDefaults stores security flags; Keychain stores the PIN value.
- Delete All Data bridges repository, UserDefaults, and Keychain cleanup.

## Code Ownership

- Settings VM/coordinator: `Features/Settings/List/*`
- Security VM/coordinator: `Features/Settings/Security/*`
- PIN creation: `Features/Settings/Create PIN/ViewModel/CreatePinViewModel.swift`
- PIN verification: `Features/Login/PIN/ViewModel/LoginPinViewModel.swift`
- Storage: `Shared/Managers/UserDefaultsManager.swift`, `Shared/Managers/KeychainManager.swift`

## Decision Blocks

> **Decision Block: SEC-001 - Disabling PIN**
>
> Status: Unknown
>
> Disabling PIN toggles flags but leaves Keychain PIN. Decide whether this is intended for easy re-enable or whether stored PIN should be deleted.

> **Decision Block: SEC-002 - Change PIN Verification**
>
> Status: Unknown
>
> Current create/change PIN path does not require current PIN. Decide whether changing PIN requires existing authentication.

> **Decision Block: SEC-003 - Delete All Data Confirmation**
>
> Status: Unknown
>
> Delete All Data is destructive. Define required confirmation copy, authentication requirement, and post-delete navigation.
