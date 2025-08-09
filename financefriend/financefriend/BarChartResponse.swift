//
//  BarChartResponse.swift
//  financefriend
//
//  Created by Nidesh Sri on 07/08/25.
//

import Foundation

struct BarChartResponse: Identifiable, Hashable {
    var id = UUID()
    var amount: Double
    var month: String
}

