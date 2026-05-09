# 1. Product Overview

## Product Definition

Vault is an offline-first iOS personal finance app for tracking money across one or more Vaults. A Vault contains operations, categories, reimbursements, and dashboard metrics.

## Confirmed Product Surface

- Create, edit, list, favorite, delete, import, and export Vaults.
- Track income and expense operations.
- Categorize operations by income or expense categories.
- Show dashboard summaries for selected monthly/yearly periods.
- Model reimbursements for expense operations.
- Manage local security with a 4-digit PIN.
- Use OCR/Foundation Models where supported to prefill receipt operations and enable finance assistant features.

## Inferred Direction

- The product is designed for a single person managing personal finances locally.
- Multi-Vault support is intended for separating financial contexts.
- Reimbursements are important enough to affect balances and operation list display, not just notes.
- CSV import/export exists to support migration and backup workflows.

## Explicit Non-Goals for Current Scope

- Cloud sync.
- Multi-user collaboration.
- Shared Vault permissions.
- Bank integrations.
- Budget alerts.
- Cross-device identity/account system.

## Feature Map

- App start/onboarding/login: [Features/App-Start-Onboarding-Login.md](Features/App-Start-Onboarding-Login.md)
- Vaults: [Features/Vaults.md](Features/Vaults.md)
- Dashboard: [Features/Dashboard.md](Features/Dashboard.md)
- Operations: [Features/Operations.md](Features/Operations.md)
- Categories: [Features/Categories.md](Features/Categories.md)
- Reimbursements: [Features/Reimbursements.md](Features/Reimbursements.md)
- CSV import/export: [Features/CSV-Import-Export.md](Features/CSV-Import-Export.md)
- Settings/security: [Features/Settings-Security.md](Features/Settings-Security.md)
- OCR/assistant: [Features/OCR-and-Finance-Assistant.md](Features/OCR-and-Finance-Assistant.md)

## Product Decision Backlog

Open product decisions are documented inside feature pages as Decision Blocks. Before implementing behavior that touches one of those areas, resolve the block or keep the implementation deliberately narrow.
