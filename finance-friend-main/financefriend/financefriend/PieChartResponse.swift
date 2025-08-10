//
//  PieChartResponse.swift
//  financefriend
//
//  Created by Nidesh Sri on 07/08/25.
//

import Foundation

struct PieChartResponse: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var amount: Double
}
