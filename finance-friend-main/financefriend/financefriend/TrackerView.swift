import SwiftUI

struct TrackerView: View {
    @State private var showAddExpense = false
    @State private var showAddIncome = false
    @State private var selectedTab: Tab = .incomes
    @StateObject private var manager = FirestoreManager()

    enum Tab: String, CaseIterable, Identifiable {
        case incomes = "Incomes"
        case expenses = "Expenses"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                // Totals summary
                HStack {
                    SummaryPill(title: "Income", value: totalIncome(), color: .green.opacity(0.85))
                    SummaryPill(title: "Expense", value: totalExpense(), color: .red.opacity(0.85))
                    SummaryPill(title: "Net", value: totalIncome() - totalExpense(),
                                color: (totalIncome() - totalExpense()) >= 0 ? .green : .red)
                }
                .padding(.horizontal)

                // Segmented toggle
                Picker("", selection: $selectedTab) {
                    ForEach(Tab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // List
                Group {
                    if selectedTab == .incomes {
                        if manager.incomes.isEmpty {
                            EmptyStateView(text: "No incomes added.")
                        } else {
                            List(manager.incomes) { income in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(income.source).font(.headline)
                                        Text("\(income.recurrence) • \(income.dateString)")
                                            .font(.caption).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text("$\(income.amount, specifier: "%.2f")")
                                        .font(.subheadline).foregroundColor(.primary)
                                }
                                .padding(.vertical, 2)
                            }
                            .listStyle(.plain)
                        }
                    } else {
                        if manager.expenses.isEmpty {
                            EmptyStateView(text: "No expenses added.")
                        } else {
                            List(manager.expenses) { expense in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(expense.category).font(.headline)
                                        Text(expense.dateString)
                                            .font(.caption).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text("$\(expense.amount, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(expense.isLoan ? .red : .primary)
                                }
                                .padding(.vertical, 2)
                            }
                            .listStyle(.plain)
                        }
                    }
                }
                .refreshable {
                    manager.fetchAllIncomes()
                    manager.fetchAllExpenses()
                }

                // Bottom buttons
                HStack(spacing: 12) {
                    Button {
                        showAddIncome = true
                    } label: {
                        Text("Add Income")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button {
                        showAddExpense = true
                    } label: {
                        Text("Add Expense")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .navigationTitle("Tracker")
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView(manager: manager)
            }
            .sheet(isPresented: $showAddIncome) {
                AddIncomeView(manager: manager)
            }
            .onAppear {
                manager.fetchAllIncomes()
                manager.fetchAllExpenses()
            }
        }
    }

    // MARK: - Helpers
    private func totalIncome() -> Double {
        manager.incomes.reduce(0) { $0 + $1.amount }
    }

    private func totalExpense() -> Double {
        manager.expenses.reduce(0) { $0 + $1.amount }
    }
}

private struct SummaryPill: View {
    let title: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text("$\(value, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(color.opacity(0.12))
        .cornerRadius(12)
    }
}

private struct EmptyStateView: View {
    let text: String
    var body: some View {
        VStack(spacing: 8) {
            Spacer(minLength: 40)
            Image(systemName: "tray")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.gray.opacity(0.7))
            Text(text).foregroundColor(.gray)
            Spacer(minLength: 10)
        }
    }
}
