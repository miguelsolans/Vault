//
//  UIViewController+Confirmation.swift
//  Vault
//
//  Created by Miguel Solans on 05/05/2026.
//

import UIKit

struct ConfirmationDialog {
    let title: String
    let message: String?
    let confirmTitle: String
    let cancelTitle: String
    let confirmStyle: UIAlertAction.Style

    static func delete(
        title: String = "Delete item?",
        message: String? = "This action cannot be undone.",
        confirmTitle: String = "Delete",
        cancelTitle: String = "Cancel"
    ) -> ConfirmationDialog {
        ConfirmationDialog(
            title: title,
            message: message,
            confirmTitle: confirmTitle,
            cancelTitle: cancelTitle,
            confirmStyle: .destructive
        )
    }
}

extension UIViewController {
    func presentConfirmation(
        _ dialog: ConfirmationDialog,
        sourceView: UIView? = nil,
        sourceRect: CGRect? = nil,
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: dialog.title,
            message: dialog.message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: dialog.confirmTitle, style: dialog.confirmStyle) { _ in
                onConfirm()
            }
        )

        alert.addAction(
            UIAlertAction(title: dialog.cancelTitle, style: .cancel) { _ in
                onCancel?()
            }
        )

        if let popover = alert.popoverPresentationController {
            popover.sourceView = sourceView ?? view
            popover.sourceRect = sourceRect ?? (sourceView ?? view).bounds
        }

        present(alert, animated: true)
    }

    func makeConfirmedContextualAction(
        title: String?,
        image: UIImage? = nil,
        dialog: ConfirmationDialog = .delete(),
        onConfirm: @escaping () -> Void
    ) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: title) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            self.presentConfirmation(
                dialog,
                onConfirm: {
                    onConfirm()
                    completion(true)
                },
                onCancel: {
                    completion(false)
                }
            )
        }

        action.image = image
        return action
    }

    func makeConfirmedMenuAction(
        title: String,
        image: UIImage? = nil,
        dialog: ConfirmationDialog = .delete(),
        onConfirm: @escaping () -> Void
    ) -> UIAction {
        UIAction(title: title, image: image, attributes: .destructive) { [weak self] _ in
            self?.presentConfirmation(dialog, onConfirm: onConfirm)
        }
    }
}
