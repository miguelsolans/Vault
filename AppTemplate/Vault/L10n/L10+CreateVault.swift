//
//  L10+CreateVault.swift
//  Vault
//
//  Created by Miguel Solans on 08/06/2026.
//

import Foundation

extension L10n.CreateVault {
    static let pageTitle = NSLocalizedString("common.general.createVault", comment: "Create vault page title")
    static let pageSubtitle = NSLocalizedString("vault.create.page.subtitle", comment: "Create vault page subtitle")
    static let name = NSLocalizedString("vault.create.field.name", comment: "Vault name field")
    static let enterName = NSLocalizedString("vault.create.field.enterName", comment: "Enter vault name placeholder")
    static let initialAmount = NSLocalizedString("vault.create.field.initialAmount", comment: "Initial amount field")
    static let setupInitialAmount = NSLocalizedString("vault.create.field.setupInitialAmount", comment: "Setup initial amount field")
    static let enterInitialAmount = NSLocalizedString("vault.create.field.enterInitialAmount", comment: "Enter initial amount placeholder")
    static let importOperations = NSLocalizedString("vault.create.field.importOperations", comment: "Import operations field")
    static let importFromCsv = NSLocalizedString("vault.create.field.importFromCsv", comment: "Import from CSV placeholder")
    static let csvFile = NSLocalizedString("vault.create.field.csvFile", comment: "CSV file field")
    static let nameRequired = NSLocalizedString("vault.create.validation.nameRequired", comment: "Name required validation")
    static let initialAmountRequired = NSLocalizedString("common.general.amountRequired", comment: "Initial amount required validation")
    static let fileRequired = NSLocalizedString("vault.create.validation.fileRequired", comment: "File required validation")
    static let vaultWithNameAlreadyExists = NSLocalizedString("vault.create.error.nameAlreadyExists", comment: "Vault name already exists error")
    static let errorCreatingVault = NSLocalizedString("vault.create.error.creatingVault", comment: "Error creating vault")
}
