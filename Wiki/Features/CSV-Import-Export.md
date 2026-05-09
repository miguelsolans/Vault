# CSV Import and Export

## Feature Summary

CSV import can be selected during Vault creation. CSV export is available from Vault management. The intended product behavior is field mapping from user-selected CSV headers to Vault operations, but the currently wired import implementation has code alignment issues.

## Confirmed Behavior

- Create Vault UI allows optional CSV file selection.
- CSV file picker accepts comma-separated text.
- Import screen reads CSV with semicolon separator and header row.
- Import screen asks user to select headers for operation type, category, amount, description, and date.
- Import validation requires all five mapping pickers to have a selected option.
- Current wired import use case processes in-memory rows from `ImportOperationsViewModel`.
- CSV export writes header: Date, Type, Category, Description, Amount.
- CSV export formats dates as `d MMMM yyyy` with `en_US_POSIX` formatter.
- CSV export formats currency using `pt_PT` locale.
- Export uses semicolon separator and header row from `ListVaultViewModel`.

## Inferred Behavior

- Import and export are intended to round-trip the same five fields.
- Import is intended to create missing categories.
- Import is intended to count row-level failures without failing the whole import.

## Unknown Behavior

- Whether CSV separator should be comma or semicolon.
- Whether import should accept localized Portuguese operation types.
- Whether invalid rows should be skipped, block the import, or be editable.
- Whether duplicate imported operations should be detected.
- Whether imported amounts can be negative.

## Current Code Alignment Notes

These are confirmed implementation issues, not product decisions:

- `ImportOperationsViewModel.didTapImport()` builds `ImportFieldMapping` with mismatched fields.
- The wired import use case in `Core/Domain/UseCases/Operations/ImportOperationsUseCase.swift` ignores the mapping values and reads hard-coded row keys: `Date`, `Amount`, `Type`, `Category`, `Description`.
- Duplicate CSV import/export use cases exist under `Core/Domain/UseCases/CSV/*`, but `rg` shows the wired view model references the Operations version.
- The older CSV import implementation uses `mapping.operation`, while the wired `ImportFieldMapping` type uses `type`; this indicates drift between versions.

## Primary Import Flow

1. User creates a Vault and enables import.
2. User selects a CSV file.
3. Vault is created.
4. Import coordinator opens mapping screen.
5. CSV header is loaded into picker options.
6. User maps each required field.
7. Import use case processes each row.
8. Valid rows create operations and categories as needed.
9. Import result reports success and failure counts.
10. User dismisses result and enters private area.

## Primary Export Flow

1. User opens Settings.
2. User opens Vault management.
3. User selects export action for a Vault.
4. `ExportOperationsUseCase` fetches all operations from the Vault.
5. Use case creates CSV string and suggested filename.
6. Coordinator presents document/export UI.

## Screens

- Create Vault import toggle/file: `Features/Vault/Create/*`
- Import mapping: `Features/Operations/Import/*`
- Vault export entry: `Features/Vault/List/*`
- CSV utilities: `Shared/Utils/CSVMigration.swift`

## Business Rules

- Import is optional.
- CSV import requires date, amount, type, category, and description selections at UI level.
- CSV reader skips malformed rows where value count does not match header count.
- Wired import date parser expects `d MMMM yyyy`.
- Wired import currency parser expects `pt_PT` currency format.
- Wired import defaults unknown operation types to expense.
- Export fails when Vault has no operations.

## Calculations

No finance formulas are specific to CSV. Import creates operations; exported and imported amounts then participate in the normal Operation, Dashboard, and Vault calculations.

## Edge Cases

- Empty file: CSV reader throws `emptyFile`; UI error handling is not defined.
- Non-UTF-8 file: CSV reader throws file-not-readable/encoding-style errors; UI behavior undefined.
- Header mismatch: malformed rows are silently skipped by CSV reader.
- User maps fields correctly but CSV headers are not exactly hard-coded names: wired import currently fails rows.
- Exported count in the wired Operations export response is currently `content.count`, not operation count.

## Architecture Notes

- CSV parsing/writing is shared utility code in `Shared/Utils/CSVMigration.swift`.
- Import UI reads CSV headers before invoking the import use case.
- Current import/export use cases exist in duplicate module locations; this is documented as a decision.
- Export is launched from Vault management, not from the Operations tab.

## Code Ownership

- Wired import VM: `Features/Operations/Import/ViewModel/ImportOperationsViewModel.swift`
- Wired import use case: `Core/Domain/UseCases/Operations/ImportOperationsUseCase.swift`
- Duplicate CSV use cases: `Core/Domain/UseCases/CSV/*`
- CSV reader/writer: `Shared/Utils/CSVMigration.swift`
- Export entry: `Features/Vault/List/ViewModel/ListVaultViewModel.swift`

## Decision Blocks

> **Decision Block: CSV-001 - Canonical CSV Implementation**
>
> Status: Unknown
>
> Two import/export implementations exist. Decide which module is canonical, remove or migrate the other, and align names/types.

> **Decision Block: CSV-002 - Field Mapping Contract**
>
> Status: Unknown
>
> Product flow requires mapping CSV headers. Current wired import ignores mapping. Decide whether to support arbitrary headers or require the fixed exported schema.

> **Decision Block: CSV-003 - Invalid Row Policy**
>
> Status: Unknown
>
> Decide whether invalid rows are skipped with report, block entire import, or move to a review/edit screen before persistence.
