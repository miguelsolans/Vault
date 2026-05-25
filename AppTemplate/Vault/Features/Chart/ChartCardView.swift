//
//  ChartCardView.swift
//  Vault
//
//  Created by Miguel Solans on 14/04/2026.
//


import UIKit
import SwiftUI
import Charts
import AppUIKit
import VaultCore

final class ChartCardView: UIView {

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chartContainerView = UIView()

    private var hostingController: UIHostingController<ChartView>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        title: String,
        subtitle: String?,
        plotViewModel: ChartViewModel,
        parentViewController: UIViewController
    ) {
        titleLabel.text = title
        
        if(plotViewModel.chartType == .bar) {
            subtitleLabel.text = subtitle
            cardView.backgroundColor = .clear
        }
        
        subtitleLabel.isHidden = (subtitle?.isEmpty ?? true)

        let rootView = ChartView(viewModel: plotViewModel)

        if let hostingController {
            hostingController.rootView = rootView
            return
        }

        let hostingController = UIHostingController(rootView: rootView)
        self.hostingController = hostingController

        parentViewController.addChild(hostingController)
        chartContainerView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        hostingController.didMove(toParent: parentViewController)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: chartContainerView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor)
        ])
    }
}

private extension ChartCardView {

    func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor(resource: .accentBackground)
        cardView.layer.cornerRadius = 20
        cardView.layer.cornerCurve = .continuous

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        chartContainerView.translatesAutoresizingMaskIntoConstraints = false
        chartContainerView.backgroundColor = .clear

        addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(chartContainerView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            chartContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            chartContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            chartContainerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            chartContainerView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            chartContainerView.heightAnchor.constraint(equalToConstant: 340)
        ])
    }
}

struct ChartView: View {
    
    let viewModel: ChartViewModel
    
    var body: some View {
        if viewModel.items.isEmpty {
            ContentUnavailableView(
                "No data",
                systemImage: "chart.bar",
                description: Text("Redefine the filter criteria or add data in Operations")
            )
        } else {
            
            if viewModel.chartType == .pie {
                CategoryPieChartView(viewModel: viewModel)
            } else {
                if viewModel.items.count > 4 {
                    BarMarkChartView(viewModel: viewModel)
                        .frame(height: 300)
                        .chartScrollableAxes(.horizontal)
                        .scaledToFill()
                } else {
                    BarMarkChartView(viewModel: viewModel)
                        .frame(height: 300)
                        .scaledToFill()
                }
            }
        }
    }
}

struct BarMarkChartView: View {
    
    let viewModel: ChartViewModel
    
    var body: some View {
        Chart(viewModel.items) { item in
            BarMark(
                x: .value(NSLocalizedString("dashboard_category", tableName: "Dashboard", comment: ""), item.title),
                y: .value(NSLocalizedString("dashboard_value", tableName: "Dashboard", comment: ""), item.amount)
            )
            .foregroundStyle(Color(hexString: item.hexColor))
            .annotation(position: .top) {
                Text(item.amount, format: .currency(code: "EUR").precision(.fractionLength(0)))
                    .font(.caption)
                    .bold()
            }
        }
        .chartYScale(
            type: .symmetricLog
        )
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                AxisTick()
            }
        }
    }
}

struct CategoryPieChartView: View {
    
    let viewModel: ChartViewModel
    
    @State private var selectedAngle: Double?
    @State private var animationProgress = 0.0
    
    private var selectedItem: AmountPerCategory? {
        guard let selectedAngle else { return nil }
        
        var runningTotal = 0.0
        for item in viewModel.items {
            let nextTotal = runningTotal + item.amount
            if selectedAngle >= runningTotal && selectedAngle < nextTotal {
                return item
            }
            runningTotal = nextTotal
        }
        
        return nil
    }
    
    var body: some View {
        Chart(viewModel.items) { item in
            SectorMark(
                angle: .value("Count", item.amount * animationProgress),
                innerRadius: .ratio(0.6),
                angularInset: 2
            )
            .cornerRadius(5)
            .foregroundStyle(by: .value("Category", item.title))
            .opacity(selectedItem?.title == item.title ? 1.0 : 0.5)
        }
        .chartForegroundStyleScale(
            domain: viewModel.items.map { $0.title },
            range: viewModel.items.map { Color(hexString: $0.hexColor)  }
        )
        .chartAngleSelection(value: $selectedAngle)
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                if let anchor = chartProxy.plotFrame {
                    let frame = geometry[anchor]
                    titleView
                        .position(x: frame.midX, y: frame.midY)
                }
            }
        }
        .chartLegend(alignment: .center, spacing: 16)
        .scaledToFit()
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animationProgress = 1.0
            }
        }
    }
    
    private var titleView: some View {
        
        VStack {
            if let selectedItem {
                Text(selectedItem.title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                Text(selectedItem.amountString)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            } else {
                Text("Total")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                Text(viewModel.subtitle)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            
        }
        .frame(maxWidth: 200)
    }
}

extension AmountPerCategory {
    var amountString: String {
        LocalizedDecimalFormatter.init(numberStyle: .currency)
            .string(from: amount) ?? ""
    }
}
