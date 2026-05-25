//
//  InputStyles.swift
//  Vault
//
//  Created by Miguel Solans on 04/04/2026.
//

import AppUIKit
import UIKit

final class InputStyles {
    
    static let datePickerStyle: InputStyle = {
        let style = InputStyle(
            backgroundColor: UIColor(resource: .accentBackground),
            borderColor: UIColor(resource: .border),
            selectedBorderColor: UIColor(resource: .selected),
            titleColor: UIColor(resource: .text),
            bottomLabelColor: UIColor(resource: .text),
            successColor: UIColor(resource: .success),
            warningColor: UIColor(resource: .warning),
            errorColor: UIColor(resource: .error),
            titleFont: AppFonts.inputTitle,
            placeholderFont: AppFonts.inputPlaceholder,
            bottomLabelFont: AppFonts.inputBottomLabel,
            cornerRadius: 8,
            borderWidth: 1
        );
        
        return style
    }()
    
    static let textFieldStyle: InputStyle = {
        let style = InputStyle(
            backgroundColor: UIColor(resource: .accentBackground),
            borderColor: UIColor(resource: .border),
            selectedBorderColor: UIColor(resource: .selected),
            titleColor: UIColor(resource: .text),
            bottomLabelColor: UIColor(resource: .text),
            successColor: UIColor(resource: .success),
            warningColor: UIColor(resource: .warning),
            errorColor: UIColor(resource: .error),
            titleFont: AppFonts.inputTitle,
            placeholderFont: AppFonts.inputPlaceholder,
            bottomLabelFont: AppFonts.inputBottomLabel,
            cornerRadius: 8,
            borderWidth: 1
        );
        
        return style
    }()
    
    static let segmentedStyle: InputStyle = {
        let style = InputStyle(
            backgroundColor: UIColor(resource: .accentBackground),
            borderColor: UIColor(resource: .border),
            selectedBorderColor: UIColor(resource: .selected),
            titleColor: UIColor(resource: .text),
            bottomLabelColor: UIColor(resource: .text),
            successColor: UIColor(resource: .success),
            warningColor: UIColor(resource: .warning),
            errorColor: UIColor(resource: .error),
            titleFont: AppFonts.inputTitle,
            placeholderFont: AppFonts.inputPlaceholder,
            bottomLabelFont: AppFonts.inputBottomLabel,
            cornerRadius: 8,
            borderWidth: 1
        );
        
        return style
    }()
    
    static let pickerStyle: InputStyle = {
        let style = InputStyle(
            backgroundColor: UIColor(resource: .accentBackground),
            borderColor: UIColor(resource: .border),
            selectedBorderColor: UIColor(resource: .selected),
            titleColor: UIColor(resource: .text),
            bottomLabelColor: UIColor(resource: .text),
            successColor: UIColor(resource: .success),
            warningColor: UIColor(resource: .warning),
            errorColor: UIColor(resource: .error),
            titleFont: AppFonts.inputTitle,
            placeholderFont: AppFonts.inputPlaceholder,
            bottomLabelFont: AppFonts.inputBottomLabel,
            cornerRadius: 8,
            borderWidth: 1
        );
        
        return style
    }()
    
    static let switchStyle: InputStyle = {
        let style = InputStyle(
            backgroundColor: UIColor(resource: .accentBackground),
            borderColor: UIColor(resource: .border),
            selectedBorderColor: UIColor(resource: .selected),
            titleColor: UIColor(resource: .text),
            bottomLabelColor: UIColor(resource: .text),
            successColor: UIColor(resource: .success),
            warningColor: UIColor(resource: .warning),
            errorColor: UIColor(resource: .error),
            titleFont: AppFonts.inputTitle,
            placeholderFont: AppFonts.inputPlaceholder,
            bottomLabelFont: AppFonts.inputBottomLabel,
            cornerRadius: 8,
            borderWidth: 1
        );
        
        return style
    }()
    
    static let colorPickerStyle: InputStyle = {
        let style = InputStyle(
            backgroundColor: UIColor(resource: .accentBackground),
            borderColor: UIColor(resource: .border),
            selectedBorderColor: UIColor(resource: .selected),
            titleColor: UIColor(resource: .text),
            bottomLabelColor: UIColor(resource: .text),
            successColor: UIColor(resource: .success),
            warningColor: UIColor(resource: .warning),
            errorColor: UIColor(resource: .error),
            titleFont: AppFonts.inputTitle,
            placeholderFont: AppFonts.inputPlaceholder,
            bottomLabelFont: AppFonts.inputBottomLabel,
            cornerRadius: 8,
            borderWidth: 1
        );
        
        return style
    }()
}

final class ButtonStyles {
    
    static let primary: ButtonStyle = {
        ButtonStyle(
            materialStyle: .prominentGlass,
            backgroundColor: UIColor(resource: .brand),
            titleColor: .white,
            borderColor: .systemBlue,
            disabledBackgroundColor: .systemGray4,
            disabledTitleColor: .systemGray,
            cornerRadius: 8,
            borderWidth: 1,
            font: AppFonts.buttonPrimary,
            contentInsets: NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        )
    }()
    
    static let secondary: ButtonStyle = {
        ButtonStyle(
            backgroundColor: .secondarySystemBackground,
            titleColor: .systemBlue,
            borderColor: .systemBlue,
            disabledBackgroundColor: .systemGray6,
            disabledTitleColor: .systemGray2,
            cornerRadius: 8,
            borderWidth: 1,
            font: AppFonts.buttonSecondary,
            contentInsets: NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        )
    }()
    
    static let destructive: ButtonStyle = {
        ButtonStyle(
            backgroundColor: .systemRed,
            titleColor: .white,
            borderColor: .systemRed,
            disabledBackgroundColor: .systemGray4,
            disabledTitleColor: .systemGray,
            cornerRadius: 8,
            borderWidth: 1,
            font:  AppFonts.buttonDestructive,
            contentInsets: NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        )
    }()
}

final class FeedbackStyles {

    static let informativeFeedback: FeedbackStyle = {
        return FeedbackStyle(
            backgroundColor: UIColor(resource: .accentBackground),
            titleColor: UIColor.label,
            subtitleColor: UIColor.secondaryLabel,
            iconColor: UIColor.white,
            successColor: UIColor.systemGreen,
            warningColor: UIColor.systemOrange,
            errorColor: UIColor.systemRed,
            informativeColor: UIColor.systemBlue,
            titleFont: AppFonts.sectionTitle,
            subtitleFont: AppFonts.feedbackBody,
            cornerRadius: 12,
            spacing: 8,
            contentInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12),
            iconWidth: 32
        )
    }()
    
    static let successFeedback: FeedbackStyle = {
        return FeedbackStyle(
            backgroundColor: UIColor(resource: .accentBackground),
            titleColor: UIColor.label,
            subtitleColor: UIColor.secondaryLabel,
            iconColor: UIColor.white,
            successColor: UIColor.systemGreen,
            warningColor: UIColor.systemOrange,
            errorColor: UIColor.systemRed,
            informativeColor: UIColor.systemBlue,
            titleFont: AppFonts.sectionTitle,
            subtitleFont: AppFonts.feedbackBody,
            cornerRadius: 12,
            spacing: 8,
            contentInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12),
            iconWidth: 32
        )
    }()
    
    static let warningFeedback: FeedbackStyle = {
        return FeedbackStyle(
            backgroundColor: UIColor(resource: .accentBackground),
            titleColor: UIColor.label,
            subtitleColor: UIColor.secondaryLabel,
            iconColor: UIColor.white,
            successColor: UIColor.systemGreen,
            warningColor: UIColor.systemOrange,
            errorColor: UIColor.systemRed,
            informativeColor: UIColor.systemBlue,
            titleFont: AppFonts.sectionTitle,
            subtitleFont: AppFonts.feedbackBody,
            cornerRadius: 12,
            spacing: 8,
            contentInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12),
            iconWidth: 32
        )
    }()
    
    static let errorFeedback: FeedbackStyle = {
        return FeedbackStyle(
            backgroundColor: UIColor(resource: .accentBackground),
            titleColor: UIColor.label,
            subtitleColor: UIColor.secondaryLabel,
            iconColor: UIColor.white,
            successColor: UIColor.systemGreen,
            warningColor: UIColor.systemOrange,
            errorColor: UIColor.systemRed,
            informativeColor: UIColor.systemBlue,
            titleFont: AppFonts.sectionTitle,
            subtitleFont: AppFonts.feedbackBody,
            cornerRadius: 12,
            spacing: 8,
            contentInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12),
            iconWidth: 32
        )
    }()
}

final class AppFonts {
    
    static let screenTitle = UIFont.preferredFont(forTextStyle: .title2)
    
    static let sectionTitle = UIFont.preferredFont(forTextStyle: .headline)
    
    static let cardTitle = UIFont.preferredFont(forTextStyle: .subheadline)
    
    static let primaryValue = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .bold)
    
    static let secondaryValue = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
    
    static let boldTitle = UIFont.preferredFont(forTextStyle: .headline)
    
    static let rowTitle = UIFont.preferredFont(forTextStyle: .body)
    
    static let rowSubtitle = UIFont.preferredFont(forTextStyle: .footnote)
    
    static let rowAmount = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .semibold)
    
    static let groupHeaderTitle = UIFont.preferredFont(forTextStyle: .headline)
    
    static let groupHeaderSubtitle = UIFont.preferredFont(forTextStyle: .caption1)
    
    static let groupHeaderAmount = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
    
    static let inputTitle = UIFont.preferredFont(forTextStyle: .subheadline)
    
    static let inputPlaceholder = UIFont.preferredFont(forTextStyle: .body)
    
    static let inputBottomLabel = UIFont.preferredFont(forTextStyle: .footnote)
    
    static let buttonPrimary = UIFont.systemFont(ofSize: 17, weight: .semibold)
    
    static let buttonSecondary = UIFont.preferredFont(forTextStyle: .body)
    
    static let buttonDestructive = UIFont.systemFont(ofSize: 17, weight: .semibold)
    
    static let feedbackBody = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    static let feedbackBodyBold = UIFont.systemFont(ofSize: 14, weight: .bold)
    
    static let operationHeaderTitle = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
    
    static let operationHeaderAmount = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .bold)
    
    static let percentageHighlight = UIFont.monospacedDigitSystemFont(ofSize: 17.0, weight: .semibold)
}
