//
//  IncomeItem.swift
//  financefriend
//
//  Created by Nidesh Sri on 22/07/25.
//

import Foundation

struct IncomeItem: Identifiable {
    var id = UUID()
    var source: String
    var amount: Double
    var dateString: String
    var recurrence: String = "One-Time"

    var dateFormatted: String {
        return dateString
    }
}
