//
//  PieChartView.swift
//  financefriend
//
//  Created by Nidesh Sri on 07/08/25.
//

import Foundation
import SwiftUI
import Charts

struct PieChartView: View {
    @State private var defaultData: [PieChartResponse] = pieChartDefaultData
    @State private var targetData: [PieChartResponse] = pieChartTargetData

    var body: some View {
        Chart(defaultData) { data in
            SectorMark(
                angle: .value("Amount", data.amount),
                innerRadius: .ratio(0.6)
            )
            .foregroundStyle(by: .value("Category", data.name))
        }
        .onAppear {
            animateChart()
        }
    }

    private func animateChart() {
        for (index, target) in targetData.enumerated() {
            withAnimation(.easeOut(duration: 1.0).delay(Double(index) * 0.2)) {
                defaultData[index].amount = target.amount
            }
        }
    }
}
