//
//  BudgetGoalsView.swift
//  financefriend
//
//  Created by nidesh on 8/10/25.
//

import Foundation
import SwiftUI

//struct BudgetGoalsView: View {
//    @StateObject private var manager = FirestoreManager()
//
//    @State private var selectedCategory: String = "Groceries"
//    @State private var limit: String = ""
//    @State private var goalType: String = "under"
//    @State private var showSaved = false
//    @State private var showError = false
//
//    // Use the same categories you track in expenses
//    private let categories = [
//        "Rent", "Groceries", "Utilities", "Subscriptions",
//        "Entertainment", "Transportation", "Healthcare",
//        "Loan", "Misc"
//    ]
//    private let goalTypes = ["under", "over"]
//
//    var body: some View {
//        Form {
//            Section(header: Text("New / Update Goal")) {
//                Picker("Category", selection: $selectedCategory) {
//                    ForEach(categories, id: \.self) { Text($0).tag($0) }
//                }
//                .pickerStyle(.menu)
//
//                TextField("Limit (e.g., 300)", text: $limit)
//                    .keyboardType(.decimalPad)
//
//                Picker("Goal Type", selection: $goalType) {
//                    ForEach(goalTypes, id: \.self) { Text($0.capitalized).tag($0) }
//                }
//                .pickerStyle(.segmented)
//
//                Button("Save Goal") {
//                    guard let lim = Double(limit) else { showError = true; return }
//                    manager.upsertGoal(category: selectedCategory, limit: lim, goalType: goalType)
//                    showSaved = true
//                    limit = ""
//                }
//                .buttonStyle(.borderedProminent)
//            }
//
//            Section(header: Text("Existing Goals")) {
//                if manager.goals.isEmpty {
//                    Text("No goals set yet.")
//                        .foregroundColor(.secondary)
//                } else {
//                    ForEach(manager.goals) { g in
//                        HStack {
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text(g.category).font(.headline)
//                                Text("\(g.goalType == "over" ? "Target ≥" : "Limit ≤") \(g.limit, specifier: "%.2f")")
//                                    .font(.caption).foregroundColor(.secondary)
//                            }
//                            Spacer()
//                            Button(role: .destructive) {
//                                manager.deleteGoal(category: g.category)
//                            } label: {
//                                Image(systemName: "trash")
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .navigationTitle("Budget Goals")
//        .onAppear {
//            manager.fetchGoals()
//        }
//        .alert("Saved", isPresented: $showSaved) {
//            Button("OK", role: .cancel) {}
//        }
//        .alert("Please enter a valid limit", isPresented: $showError) {
//            Button("OK", role: .cancel) {}
//        }
//    }
//}
