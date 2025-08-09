//
//  BarChartView.swift
//  financefriend
//
//  Created by Nidesh Sri on 07/08/25.
//

import Foundation
import SwiftUI
import Charts

struct BarChartView: View {
    @State private var defaultData: [BarChartResponse] = barChartDefaultData
    @State private var targetData: [BarChartResponse] = barChartTargetData

    var body: some View {
        Chart {
            ForEach(defaultData) { data in
                BarMark(
                    x: .value("Month", data.month),
                    y: .value("Amount", data.amount)
                )
                .clipShape(BarRoundedRectangle(radius: 8))
                .foregroundStyle(.white)
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom) {
                AxisGridLine().foregroundStyle(.clear)
                AxisTick().foregroundStyle(.white)
                AxisValueLabel().foregroundStyle(.white)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine().foregroundStyle(.white.opacity(0.5))
                AxisTick().foregroundStyle(.white)
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text("$\(amount, specifier: "%.0f")").foregroundStyle(.white)
                    }
                }
            }
        }
        .background(Color.primaryColor)
        .onAppear {
            animateChart()
        }
    }

    private func animateChart() {
        for (index, target) in targetData.enumerated() {
            withAnimation(.easeOut(duration: 1.0).delay(Double(index) * 0.1)) {
                defaultData[index].amount = target.amount
            }
        }
    }
}

struct BarRoundedRectangle: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: radius, height: radius))
        return path
    }
}
