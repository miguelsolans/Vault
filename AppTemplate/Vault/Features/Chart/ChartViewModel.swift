//
//  ChartViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 14/04/2026.
//

import Foundation
import SwiftUI
import AppUIKit
import VaultCore

public enum ChartType {
    case pie
    case bar
}

public struct ChartItemViewModel: Identifiable {
    public let id = UUID()

    public let label: String
    
    public let value: Double
    
    public let color: Color
}

public struct ChartViewModel: Identifiable {
    public let id = UUID()
    
    public let title: String
    
    public let items: [AmountPerCategory];
    
    public let chartType: ChartType
    
    public let subtitle: String
    
    public let average: Double?
    
    init(
        title: String,
        items: [AmountPerCategory],
        chartType: ChartType,
        subtitle: String,
        average: Double? = nil
    ) {
        self.title = title
        self.items = items
        self.chartType = chartType
        self.subtitle = subtitle
        self.average = average
    }
}
