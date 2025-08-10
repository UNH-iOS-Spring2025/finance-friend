//
//  PortfolioItem.swift
//  financefriend
//
//  Created by Chanikya Ch on 8/10/25.
//

import Foundation

struct PortfolioItem: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    /// "stock" | "bond" | "crypto" | "cash" | "other"
    var type: String
    var balance: Double
    var createdAt: String // "yyyy-MM-dd"
    var history: [HistoryPoint] = []

    struct HistoryPoint: Identifiable, Equatable {
        var id = UUID()
        var date: String // "yyyy-MM-dd"
        var amount: Double
    }
}
