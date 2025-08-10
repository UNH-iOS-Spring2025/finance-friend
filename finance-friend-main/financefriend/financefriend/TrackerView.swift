//import SwiftUI
//
//struct TrackerView: View {
//    @State private var showAddExpense = false
//    @State private var showAddIncome = false
//    @State private var selectedTab: Tab = .incomes
//    @StateObject private var manager = FirestoreManager()
//
//    enum Tab: String, CaseIterable, Identifiable {
//        case incomes = "Incomes"
//        case expenses = "Expenses"
//        var id: String { rawValue }
//    }
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 12) {
//                // Totals summary
//                HStack {
//                    SummaryPill(title: "Income", value: totalIncome(), color: .green.opacity(0.85))
//                    SummaryPill(title: "Expense", value: totalExpense(), color: .red.opacity(0.85))
//                    SummaryPill(title: "Net", value: totalIncome() - totalExpense(),
//                                color: (totalIncome() - totalExpense()) >= 0 ? .green : .red)
//                }
//                .padding(.horizontal)
//
//                // Segmented toggle
//                Picker("", selection: $selectedTab) {
//                    ForEach(Tab.allCases) { tab in
//                        Text(tab.rawValue).tag(tab)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .padding(.horizontal)
//
//                // List
//                Group {
//                    if selectedTab == .incomes {
//                        if manager.incomes.isEmpty {
//                            EmptyStateView(text: "No incomes added.")
//                        } else {
//                            List(manager.incomes) { income in
//                                HStack {
//                                    VStack(alignment: .leading, spacing: 4) {
//                                        Text(income.source).font(.headline)
//                                        Text("\(income.recurrence) • \(income.dateString)")
//                                            .font(.caption).foregroundColor(.gray)
//                                    }
//                                    Spacer()
//                                    Text("$\(income.amount, specifier: "%.2f")")
//                                        .font(.subheadline).foregroundColor(.primary)
//                                }
//                                .padding(.vertical, 2)
//                            }
//                            .listStyle(.plain)
//                        }
//                    } else {
//                        if manager.expenses.isEmpty {
//                            EmptyStateView(text: "No expenses added.")
//                        } else {
//                            List(manager.expenses) { expense in
//                                HStack {
//                                    VStack(alignment: .leading, spacing: 4) {
//                                        Text(expense.category).font(.headline)
//                                        Text(expense.dateString)
//                                            .font(.caption).foregroundColor(.gray)
//                                    }
//                                    Spacer()
//                                    Text("$\(expense.amount, specifier: "%.2f")")
//                                        .font(.subheadline)
//                                        .foregroundColor(expense.isLoan ? .red : .primary)
//                                }
//                                .padding(.vertical, 2)
//                            }
//                            .listStyle(.plain)
//                        }
//                    }
//                }
//                .refreshable {
//                    manager.fetchAllIncomes()
//                    manager.fetchAllExpenses()
//                }
//
//                // Bottom buttons
//                HStack(spacing: 12) {
//                    Button {
//                        showAddIncome = true
//                    } label: {
//                        Text("Add Income")
//                            .fontWeight(.semibold)
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.green.opacity(0.9))
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                    }
//
//                    Button {
//                        showAddExpense = true
//                    } label: {
//                        Text("Add Expense")
//                            .fontWeight(.semibold)
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.red.opacity(0.9))
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 8)
//            }
//            .navigationTitle("Tracker")
//            .sheet(isPresented: $showAddExpense) {
//                AddExpenseView(manager: manager)
//            }
//            .sheet(isPresented: $showAddIncome) {
//                AddIncomeView(manager: manager)
//            }
//            .onAppear {
//                manager.fetchAllIncomes()
//                manager.fetchAllExpenses()
//            }
//        }
//    }
//
//    // MARK: - Helpers
//    private func totalIncome() -> Double {
//        manager.incomes.reduce(0) { $0 + $1.amount }
//    }
//
//    private func totalExpense() -> Double {
//        manager.expenses.reduce(0) { $0 + $1.amount }
//    }
//}
//
//private struct SummaryPill: View {
//    let title: String
//    let value: Double
//    let color: Color
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text(title).font(.caption).foregroundColor(.secondary)
//            Text("$\(value, specifier: "%.2f")")
//                .font(.headline)
//                .foregroundColor(.primary)
//        }
//        .padding(.vertical, 10)
//        .padding(.horizontal, 12)
//        .background(color.opacity(0.12))
//        .cornerRadius(12)
//    }
//}
//
//private struct EmptyStateView: View {
//    let text: String
//    var body: some View {
//        VStack(spacing: 8) {
//            Spacer(minLength: 40)
//            Image(systemName: "tray")
//                .font(.system(size: 28, weight: .semibold))
//                .foregroundColor(.gray.opacity(0.7))
//            Text(text).foregroundColor(.gray)
//            Spacer(minLength: 10)
//        }
//    }
//}
import SwiftUI
import Charts

struct TrackerView: View {
    @State private var showAddExpense = false
    @State private var showAddIncome = false
    @State private var showAddAsset = false

    @State private var selectedTab: Tab = .incomes
    @StateObject private var manager = FirestoreManager()

    enum Tab: String, CaseIterable, Identifiable {
        case incomes = "Incomes"
        case expenses = "Expenses"
        case portfolio = "Portfolio"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                // Totals summary
                HStack {
                    SummaryPill(title: "Income", value: totalIncome(), color: .green.opacity(0.85))
                    SummaryPill(title: "Expense", value: totalExpense(), color: .red.opacity(0.85))
                    SummaryPill(title: "Wealth", value: totalWealthNow(), color: .blue.opacity(0.85))
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

                // Content
                Group {
                    switch selectedTab {
                    case .incomes:
                        incomesList
                    case .expenses:
                        expensesList
                    case .portfolio:
                        portfolioSection
                    }
                }
                .refreshable {
                    manager.fetchAllIncomes()
                    manager.fetchAllExpenses()
                    manager.fetchAccounts()
                }

                // Bottom row buttons
                HStack(spacing: 12) {
                    if selectedTab == .incomes {
                        Button {
                            showAddIncome = true
                        } label: {
                            ActionButtonLabel(text: "Add Income", bg: .green)
                        }
                    } else if selectedTab == .expenses {
                        Button {
                            showAddExpense = true
                        } label: {
                            ActionButtonLabel(text: "Add Expense", bg: .red)
                        }
                    } else {
                        Button {
                            showAddAsset = true
                        } label: {
                            ActionButtonLabel(text: "Add Asset", bg: .blue)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .navigationTitle("Tracker")
            .sheet(isPresented: $showAddExpense) { AddExpenseView(manager: manager) }
            .sheet(isPresented: $showAddIncome) { AddIncomeView(manager: manager) }
            .sheet(isPresented: $showAddAsset) { AddAssetView(manager: manager) }
            .onAppear {
                manager.fetchAllIncomes()
                manager.fetchAllExpenses()
                manager.fetchAccounts()
            }
        }
    }

    // MARK: - Incomes
    private var incomesList: some View {
        Group {
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
        }
    }

    // MARK: - Expenses
    private var expensesList: some View {
        Group {
            if manager.expenses.isEmpty {
                EmptyStateView(text: "No expenses added.")
            } else {
                List(manager.expenses) { expense in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(expense.category).font(.headline)
                            Text(expense.dateString).font(.caption).foregroundColor(.gray)
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

    // MARK: - Portfolio
    private var portfolioSection: some View {
        VStack(spacing: 12) {
            // Pie
            if manager.accounts.isEmpty {
                EmptyStateView(text: "No assets added.")
            } else {
                let alloc = allocationByType()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Portfolio Allocation").font(.headline).padding(.horizontal)

                    Chart {
                        ForEach(Array(alloc.enumerated()), id: \.offset) { idx, pair in
                            SectorMark(
                                angle: .value("Amount", pair.amount),
                                innerRadius: .ratio(0.65)
                            )
                            .foregroundStyle(palette[idx % palette.count])
                        }
                    }
                    .chartLegend(.hidden)
                    .frame(height: 220)
                    .padding(.horizontal)

                    // Legend
                    ForEach(Array(alloc.enumerated()), id: \.offset) { idx, pair in
                        HStack {
                            Circle().fill(palette[idx % palette.count]).frame(width: 10, height: 10)
                            Text(pair.type.capitalized).font(.subheadline)
                            Spacer()
                            Text("$\(pair.amount, specifier: "%.2f")").font(.caption).foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                .background(.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                .padding(.horizontal)
            }

            // List of accounts
            if !manager.accounts.isEmpty {
                List(manager.accounts) { acc in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(acc.name).font(.headline)
                            Text(acc.type.capitalized)
                                .font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("$\(acc.balance, specifier: "%.2f")")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 2)
                }
                .listStyle(.plain)
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
    private func totalWealthNow() -> Double {
        manager.accounts.reduce(0) { $0 + $1.balance }
    }

    private let palette: [Color] = [
        Color(red: 0.37, green: 0.62, blue: 0.86),
        Color(red: 0.63, green: 0.85, blue: 0.61),
        Color(red: 0.95, green: 0.66, blue: 0.51),
        Color(red: 0.75, green: 0.33, blue: 0.47),
        Color(red: 0.97, green: 0.86, blue: 0.44)
    ]

    private func allocationByType() -> [(type: String, amount: Double)] {
        var dict: [String: Double] = [:]
        for a in manager.accounts { dict[a.type, default: 0] += a.balance }
        return dict.map { ($0.key, $0.value) }.sorted { $0.amount > $1.amount }
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
                .font(.headline).foregroundColor(.primary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(color.opacity(0.12))
        .cornerRadius(12)
    }
}

private struct ActionButtonLabel: View {
    let text: String
    let bg: Color
    var body: some View {
        Text(text)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(bg.opacity(0.9))
            .foregroundColor(.white)
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
