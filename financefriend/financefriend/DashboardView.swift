import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var manager = FirestoreManager()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: Income vs Expense
                    Text("Income vs Expense")
                        .font(.title2)
                        .padding(.horizontal)

                    Chart {
                        BarMark(x: .value("Type", "Income"), y: .value("Amount", totalIncome()))
                            .foregroundStyle(.green)
                        BarMark(x: .value("Type", "Expense"), y: .value("Amount", totalExpense()))
                            .foregroundStyle(.red)
                    }
                    .frame(height: 220)
                    .padding(.horizontal)

                    // MARK: Expense by Category
                    Text("Expenses by Category")
                        .font(.title2)
                        .padding(.horizontal)

                    Chart {
                        ForEach(expensesByCategory(), id: \.category) { item in
                            SectorMark(angle: .value("Amount", item.amount), innerRadius: .ratio(0.5))
                                .foregroundStyle(by: .value("Category", item.category))
                        }
                    }
                    .frame(height: 220)
                    .padding(.horizontal)

                    // MARK: Summary
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Summary")
                            .font(.headline)
                        Text("Total Income: $\(totalIncome(), specifier: "%.2f")")
                        Text("Total Expense: $\(totalExpense(), specifier: "%.2f")")
                        Text("Net: $\(totalIncome() - totalExpense(), specifier: "%.2f")")
                            .foregroundColor(totalIncome() >= totalExpense() ? .green : .red)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Dashboard")
            .onAppear {
                manager.fetchAllExpenses()
                manager.fetchAllIncomes()
            }
        }
    }

    private func totalIncome() -> Double {
        manager.incomes.reduce(0) { $0 + $1.amount }
    }

    private func totalExpense() -> Double {
        manager.expenses.reduce(0) { $0 + $1.amount }
    }

    private func expensesByCategory() -> [CategoryAmount] {
        var grouped: [String: Double] = [:]
        for expense in manager.expenses {
            grouped[expense.category, default: 0] += expense.amount
        }
        return grouped.map { CategoryAmount(category: $0.key, amount: $0.value) }
    }
}

struct CategoryAmount {
    let category: String
    let amount: Double
}
