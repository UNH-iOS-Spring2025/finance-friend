//
//  PieChartData.swift
//  financefriend
//
//  Created by Nidesh Sri on 07/08/25.
//

import Foundation

var pieChartDefaultData: [PieChartResponse] = [
    PieChartResponse(name: "Rent", amount: 0),
    PieChartResponse(name: "Groceries", amount: 0),
    PieChartResponse(name: "Utilities", amount: 0),
    PieChartResponse(name: "Other", amount: 0)
]

var pieChartTargetData: [PieChartResponse] = [
    PieChartResponse(name: "Rent", amount: 1200),
    PieChartResponse(name: "Groceries", amount: 500),
    PieChartResponse(name: "Utilities", amount: 300),
    PieChartResponse(name: "Other", amount: 200)
]
