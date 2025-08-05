//
//  ExpenseItem.swift
//  financefriend
//
//  Created by Nidesh Sri on 22/07/25.
//

import Foundation

struct ExpenseItem: Identifiable {
    var id = UUID()
    var category: String
    var amount: Double
    var dateString: String
    var isLoan: Bool

    var dateFormatted: String {
        dateString
    }
}


