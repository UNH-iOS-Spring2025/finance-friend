//
//  WealthSnapshot.swift
//  financefriend
//
//  Created by Nidesh on 8/11/25.
//

import Foundation

struct WealthSnapshot: Identifiable, Equatable {
    var id = UUID()
    let year: Int            // e.g. 2025
    let month: Int           // 1...12
    let total: Double        // total net worth at end of that month
    let dateString: String   // "yyyy-MM-dd" (we store last day of that month)

    var date: Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df.date(from: dateString) ?? Date()
    }
}
