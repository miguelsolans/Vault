# Vault Wiki

This wiki is organized around features first. Each feature page is intended to be useful on its own: it lists the product behavior, confirmed code paths, business rules, edge cases, and open decisions for that feature.

## How to use this wiki

- Use `Features/*` when changing product behavior.
- Use `6-Domain model.md` when changing Core Data entities, DTOs, or repository contracts.
- Use `10-Architecture.md` when changing app structure, dependencies, navigation, persistence, or external frameworks.
- Add a Decision Block whenever behavior is not confirmed by code or current docs.

## Feature Docs

- [App Start, Onboarding, and Login](Features/App-Start-Onboarding-Login.md)
- [Vaults](Features/Vaults.md)
- [Dashboard](Features/Dashboard.md)
- [Operations](Features/Operations.md)
- [Categories](Features/Categories.md)
- [Reimbursements](Features/Reimbursements.md)
- [CSV Import and Export](Features/CSV-Import-Export.md)
- [Settings and Security](Features/Settings-Security.md)
- [OCR and Finance Assistant](Features/OCR-and-Finance-Assistant.md)

## Cross-Cutting Docs

- [1. Product overview](1-Product%20overview.md)
- [2. Core concepts](2-Core%20concepts.md)
- [3. Users and assumptions](3-Users%20and%20assumptions.md)
- [4. User flows](4-User%20flows.md)
- [5. Screens inventory](5-Screens%20inventory.md)
- [6. Domain model](6-Domain%20model.md)
- [7. Business rules](7-Business%20rules.md)
- [8. Calculations and formulas](8-Calculations%20and%20formulas.md)
- [9. Edge cases](9-Edge%20cases.md)
- [10. Architecture](10-Architecture.md)

## Documentation Drift Guard

When code changes a feature, update the corresponding feature page in the same change. Minimum required updates:

- confirmed behavior
- business rules
- edge cases
- calculations
- code ownership
- decision blocks affected by the change
