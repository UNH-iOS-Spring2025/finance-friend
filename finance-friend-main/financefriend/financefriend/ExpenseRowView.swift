//
//  ExpenseRowView.swift
//  financefriend
//
//  Created by Nidesh Sri on 22/07/25.
//

import Foundation
import SwiftUI

struct ExpenseRowView: View {
    var expense: ExpenseItem

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.category)
                    .font(.headline)
                Text(expense.dateFormatted)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("$\(expense.amount, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(expense.isLoan ? .red : .primary)
        }
        .padding(.horizontal)
    }
}
