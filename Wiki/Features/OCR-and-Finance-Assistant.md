# OCR and Finance Assistant

## Feature Summary

Vault has two AI-adjacent features gated by Foundation Models support: receipt OCR-assisted operation creation and a finance assistant/chat entry from dashboard.

## Confirmed Behavior

- Operations list can show an add-from-camera action when `FoundationModelAvailability.isSupported` is true.
- OCR uses Vision/VisionKit services to capture or recognize text.
- After OCR returns text, `ReceiptAssistant` decodes receipt data using current expense categories as allowed category context.
- Decoded receipt can prefill add operation fields.
- Add operation shows an OCR feedback block when created from receipt output.
- Dashboard chat/agent availability also depends on `FoundationModelAvailability.isSupported`.
- Finance assistant is created in `DependenciesContainer` with `DashboardUseCase`.

## Inferred Behavior

- Receipt OCR is intended to accelerate expense entry, not silently create operations.
- User review is required because OCR opens the add operation form with prefilled data.
- Foundation Models are optional; core finance tracking works without them.

## Unknown Behavior

- Supported OS/device matrix for Foundation Models.
- Whether OCR should be available without Foundation Models by using text recognition only.
- What confidence thresholds should be shown or enforced.
- What finance assistant can and cannot answer.
- Whether assistant outputs can create/edit data or only summarize.

## OCR Flow

1. User opens Operations tab.
2. If supported, user taps add-from-camera.
3. OCR coordinator collects text.
4. Operations coordinator loads expense categories for the active Vault.
5. Categories are formatted as bullet strings for receipt assistant context.
6. Receipt assistant decodes text into `ReceiptOutput`.
7. Add Operation opens with receipt-derived amount, description, and category.
8. User reviews and saves manually.

## Finance Assistant Flow

1. User opens Dashboard.
2. If supported, chat/agent action is available.
3. User opens chat.
4. `ChatViewModel` uses `FinanceAssistant`.
5. Finance assistant can access dashboard metrics through `DashboardUseCase` and related tools.

## Screens

- OCR: `Features/OCR/*`
- Operations OCR bridge: `Features/Operations/List/Coordinator/OperationsCoordinator.swift`
- Add Operation OCR state: `Features/Operations/Add/ViewModel/AddOperationViewModel.swift`
- Chat: `Features/Chat/*`
- Foundation Model domain: `Core/Domain/FoundationModel/*`

## Business Rules

- AI features are gated by support checks.
- Receipt OCR prefill must be reviewed by the user before saving.
- Receipt categories are constrained by current Vault expense categories in prompt/tool context.
- Add operation amount/category validation still runs after OCR prefill.

## Calculations

No feature-specific formulas are confirmed. Assistant answers may use dashboard metrics through `DashboardUseCase`.

## Edge Cases

- OCR decode failure prints an error and stops normal navigation; user-facing error is not defined.
- Receipt category may not match a current category option; save then fails category validation.
- Receipt amount may be nil; amount field remains empty or invalid.
- If Foundation Models are unsupported, AI entry points should be hidden or disabled.

## Architecture Notes

- OCR is coordinated from Operations.
- OCR text recognition and Foundation Model receipt decoding are separate steps.
- Receipt output is passed into Add Operation as prefilled state.
- Chat uses `ChatViewModel` and `FinanceAssistant` created by `DependenciesContainer`.

## Code Ownership

- Availability: `Core/Domain/FoundationModel/FoundationModelAvailability.swift`
- Receipt assistant: `Core/Domain/FoundationModel/ReceiptAssistant/ReceiptAssistant.swift`
- Finance assistant: `Core/Domain/FoundationModel/FinanceAssistant/*`
- OCR service: `Features/OCR/Services/OCRTextRecognitionService.swift`
- Chat UI: `Features/Chat/*`

## Decision Blocks

> **Decision Block: AI-001 - AI Feature Scope**
>
> Status: Unknown
>
> Decide whether assistant features are read-only, can draft operations, or can directly mutate data.

> **Decision Block: AI-002 - OCR Failure UX**
>
> Status: Unknown
>
> Current failure path prints errors. Define retry, manual-entry fallback, and error messaging.

> **Decision Block: AI-003 - Category Matching**
>
> Status: Unknown
>
> Receipt assistant receives category names, but category matching is string-based in the add operation flow. Decide fuzzy matching or explicit review behavior for mismatches.
