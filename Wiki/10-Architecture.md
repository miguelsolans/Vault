# 10. Architecture

## Platform

Confirmed:

- iOS app.
- Swift.
- UIKit-first UI with selected SwiftUI components.
- Core Data persistence.
- AppIntents shortcuts.
- Vision/VisionKit for OCR.
- FoundationModels for AI features.

## Project Shape

```text
App/
  AppDelegate, SceneDelegate, AppCoordinator, DependenciesContainer

Features/
  Feature modules with View, ViewModel, Coordinator, resources

Core/
  Data/
    Core Data model, repositories, persistence
  Domain/
    DTOs, use cases, shortcuts, Foundation Model assistants

Shared/
  Managers, utilities, shared project UI

Resources/
  Assets, colors, plist, launch screen
```

## Architectural Pattern

Confirmed hybrid:

- Coordinator-based navigation.
- MVVM-style ViewModels for screen state and actions.
- Use case objects for domain workflows.
- Repository layer for Core Data access.
- DTOs bridge Core Data objects to presentation/domain values.
- `DependenciesContainer` acts as a manual dependency factory/service locator.

## Layer Responsibilities

### Presentation

Owns:

- View controllers.
- Input view models and UI state.
- Local UI validation.
- User actions.
- Coordinator delegate calls.

Examples: `Features/*/ViewModel/*ViewModel.swift`

### Domain

Owns:

- Use case orchestration.
- Business rule checks that must survive UI changes.
- DTO creation.
- Foundation Model tools/assistants.
- AppIntents shortcuts.

Examples: `Core/Domain/UseCases/*`

### Data

Owns:

- Core Data persistence setup.
- Fetch predicates and aggregations.
- Entity creation/update/delete.
- Core Data helper computed properties.

Examples: `Core/Data/Repository/*`

## Navigation

Confirmed:

- `AppCoordinator` chooses onboarding, login, or private area.
- Private area uses tab bar.
- Each tab owns a feature coordinator.
- Child coordinators are added/removed by parent coordinators.
- Settings can push Vault management and Security child coordinators.
- Operations can push add/edit/OCR child coordinators and present operation detail.

## State Management

Confirmed:

- Persistent finance data: Core Data.
- Lightweight app preferences: UserDefaults through `UserDefaultsManager`.
- PIN secret: Keychain through `KeychainManager`.
- In-memory runtime auth: `AppCoordinator.isAuthenticated`.
- View state: ViewModels with callback closures such as `updateUI`.

## Dependency Management

Confirmed:

- `DependenciesContainer.shared` lazily creates repositories, managers, assistants, and view models.
- Most dependencies are injected into view models/use cases from `DependenciesContainer`.
- Some code still constructs repositories/use cases directly inside view models.

Examples needing alignment:

- `AddOperationViewModel.createReimbursement` creates repositories/use case directly.
- `ListVaultViewModel.exportVault` creates export use case directly despite having `exportUseCase`.
- `ImportOperationsViewModel.didTapImport` creates repositories/use case directly.

## Persistence

Confirmed:

- `PersistenceController.shared` owns `NSPersistentContainer`.
- Automatic lightweight migration is enabled.
- Main view context uses `NSMergeByPropertyObjectTrumpMergePolicy`.
- Repository default context is `PersistenceController.shared.viewContext`.
- Background context factory exists but most repositories use main context by default.

## External/Internal Dependencies

Confirmed imports/dependencies:

- `CoreKit` from `AppCoreKit`.
- `AppUIKit` local package.
- `CoreData`.
- `Charts`.
- `IQKeyboardManagerSwift`.
- `Vision` and `VisionKit`.
- `FoundationModels`.
- `AppIntents`.

## Architecture Risks

- Domain rules are split between UI validation, use cases, and repositories.
- Some view models bypass `DependenciesContainer` and instantiate repositories directly.
- Duplicate CSV use cases exist in different folders.
- DTOs force unwrap optional Core Data relationships.
- Error handling is often placeholder/print-only.
- Some business rules exist only in UI, not domain use cases.

## Drift Prevention Rules

- A new feature behavior must update its feature doc.
- A new cross-feature rule must update this page or `7-Business rules.md`.
- A new formula must update `8-Calculations and formulas.md`.
- A Core Data model change must update `6-Domain model.md`.
- A new open behavior must be recorded as a Decision Block.

## Decision Blocks

> **Decision Block: ARCH-001 - Dependency Creation Boundary**
>
> Status: Unknown
>
> Decide whether all repositories/use cases must come from `DependenciesContainer`, or whether local construction in ViewModels is acceptable.

> **Decision Block: ARCH-002 - Error Presentation Standard**
>
> Status: Unknown
>
> Define how use case/repository errors surface to users and whether ViewModels should own error state.

> **Decision Block: ARCH-003 - Domain Rule Placement**
>
> Status: Unknown
>
> Decide which validations are UI-only and which must be enforced in use cases/repositories.
