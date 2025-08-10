import Foundation

struct GoalItem: Identifiable, Equatable {
    var id = UUID()
    var category: String
    var limit: Double
    /// "under" means you want to stay under the limit; "over" means you want to exceed it (e.g., savings, debt paydown).
    var goalType: String

    var goalDescription: String {
        goalType == "over" ? "Target ≥ \(limit)" : "Limit ≤ \(limit)"
    }
}
