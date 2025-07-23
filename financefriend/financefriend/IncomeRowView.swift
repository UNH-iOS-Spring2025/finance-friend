//
//  IncomeRowView.swift
//  financefriend
//
//  Created by Nidesh Sri on 22/07/25.
//

import Foundation
import SwiftUI

struct IncomeRowView: View {
    var income: IncomeItem

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(income.source)
                    .font(.headline)
                Text("\(income.recurrence) • \(income.dateFormatted)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("$\(income.amount, specifier: "%.2f")")
                .font(.subheadline)
        }
        .padding(.horizontal)
    }
}
