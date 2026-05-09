//
//  MonthSelectorViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import Foundation

public final class MonthSelectorViewModel {
    
    public struct DisplayState {
        let previousMonthText: String
        let currentMonthText: String
        let nextMonthText: String
        
        let canGoPrevious: Bool
        let canGoNext: Bool
    }
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter
    
    public var minDate: Date?
    public var maxDate: Date?
    
    public var currentDate: Date = Date() {
        didSet {
            updateUI?(displayState)
            onMonthChanged?(displayState)
        }
    }
    
    public var updateUI: ((DisplayState) -> Void)?
    
    public var onMonthChanged: ((DisplayState) -> Void)?
    
    var displayState: DisplayState {
        DisplayState(
            previousMonthText: formattedMonth(forOffset: -1),
            currentMonthText: formattedMonth(for: currentDate),
            nextMonthText: formattedMonth(forOffset: 1),
            canGoPrevious: canGoToPreviousMonth,
            canGoNext: canGoToNextMonth
        )
    }
    
    public init(minDate: Date? = nil, maxDate: Date? = nil) {
        self.minDate = minDate
        self.maxDate = maxDate
        
        dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMM yyyy"
    }
    
    // MARK: - Navigation
    
    var canGoToPreviousMonth: Bool {
        guard let previous = calendar.date(byAdding: .month, value: -1, to: currentDate) else {
            return false
        }
        guard let minDate else { return true }
        return previous >= startOfMonth(for: minDate)
    }
    
    var canGoToNextMonth: Bool {
        guard let next = calendar.date(byAdding: .month, value: 1, to: currentDate) else {
            return false
        }
        guard let maxDate else { return true }
        return next <= startOfMonth(for: maxDate)
    }
    
    func goToPreviousMonth() {
        guard canGoToPreviousMonth else { return }
        if let previous = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = previous
        }
    }
    
    func goToNextMonth() {
        guard canGoToNextMonth else { return }
        if let next = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = next
        }
    }
    
    // MARK: - Formatting
    
    private func formattedMonth(forOffset offset: Int) -> String {
        guard let date = calendar.date(byAdding: .month, value: offset, to: currentDate) else {
            return ""
        }
        return formattedMonth(for: date)
    }
    
    private func formattedMonth(for date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    private func startOfMonth(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
    }
}
