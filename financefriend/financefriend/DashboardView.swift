import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var manager = FirestoreManager()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Dashboard")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // 1) Income vs Expense
                    dashboardCard(title: "Income vs Expense") {
                        let inc = totalIncome()
                        let exp = totalExpense()

                        Chart {
                            BarMark(x: .value("Type", "Income"),
                                    y: .value("Amount", inc))
                                .foregroundStyle(.green.gradient)

                            BarMark(x: .value("Type", "Expense"),
                                    y: .value("Amount", exp))
                                .foregroundStyle(.red.gradient)
                        }
                        .chartYAxis { AxisMarks(position: .leading) }
                        .frame(height: 220)
                        .animation(.easeInOut(duration: 0.6), value: inc)
                        .animation(.easeInOut(duration: 0.6), value: exp)
                    }

                    // 2) Expenses by Category (donut + legend)
                    dashboardCard(title: "Expenses by Category") {
                        let sorted = expensesByCategory().sorted { $0.amount > $1.amount }
                        let total = max(sorted.reduce(0) { $0 + $1.amount }, 0.0001)

                        VStack(spacing: 16) {
                            Chart {
                                ForEach(Array(sorted.enumerated()), id: \.offset) { idx, item in
                                    SectorMark(
                                        angle: .value("Amount", item.amount),
                                        innerRadius: .ratio(0.62)
                                    )
                                    .foregroundStyle(palette[idx % palette.count])
                                    .cornerRadius(2)
                                }
                            }
                            .chartLegend(.hidden)
                            .frame(height: 240)
                            .animation(.easeInOut(duration: 0.6), value: sorted)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(Array(sorted.enumerated()), id: \.offset) { idx, item in
                                    LegendRow(
                                        color: palette[idx % palette.count],
                                        title: item.category,
                                        amountText: "$\(item.amount, specifier: "%.2f")",
                                        percentText: "\(Int((item.amount / total) * 100))%"
                                    )
                                }
                            }
                        }
                    }

                    // 3) Income vs Expense Trend
                    dashboardCard(title: "Income vs Expense Trend") {
                        let incomeData = groupedIncomeHistory()
                        let expenseData = groupedExpenseHistory()

                        Chart {
                            ForEach(incomeData, id: \.date) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Income", item.amount)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(.green)
                                .symbol(Circle())
                            }
                            ForEach(expenseData, id: \.date) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Expense", item.amount)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(.red)
                                .symbol(Circle())
                            }
                        }
                        .frame(height: 240)
                        .animation(.easeInOut(duration: 0.6), value: incomeData)
                        .animation(.easeInOut(duration: 0.6), value: expenseData)
                    }

                    // 4) DTI
                    dashboardCard(title: "Debt-to-Income Ratio") {
                        let debt = totalLoanPayments()
                        let inc = totalIncome()
                        let remaining = max(inc - debt, 0)
                        let ratio = inc > 0 ? (debt / inc) * 100 : 0

                        VStack {
                            Chart {
                                SectorMark(angle: .value("Debt", debt), innerRadius: .ratio(0.5))
                                    .foregroundStyle(.red)
                                SectorMark(angle: .value("Remaining", remaining), innerRadius: .ratio(0.5))
                                    .foregroundStyle(.green)
                            }
                            .frame(height: 240)
                            .animation(.easeInOut(duration: 0.6), value: debt)
                            .animation(.easeInOut(duration: 0.6), value: inc)

                            Text("DTI: \(ratio, specifier: "%.1f")%")
                                .font(.subheadline)
                                .foregroundColor(ratio > 35 ? .red : .green)
                                .padding(.top, 4)
                        }
                    }

                    // 5) Summary
                    dashboardCard(title: "Summary") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Total Income: $\(totalIncome(), specifier: "%.2f")")
                            Text("Total Expense: $\(totalExpense(), specifier: "%.2f")")
                            Text("Net: $\(totalIncome() - totalExpense(), specifier: "%.2f")")
                                .foregroundColor((totalIncome() - totalExpense()) >= 0 ? .green : .red)
                        }
                        .font(.body)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .onAppear {
                manager.fetchAllExpenses()
                manager.fetchAllIncomes()
            }
        }
    }

    // MARK: - Card shell
    private func dashboardCard<Content: View>(title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            content()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }

    // MARK: - Data models for charts
    struct CategoryAmount { let category: String; let amount: Double }
    struct DateAmount { let date: String; let amount: Double }

    // MARK: - Aggregations
    private func totalIncome() -> Double {
        manager.incomes.reduce(0) { $0 + $1.amount }
    }
    private func totalExpense() -> Double {
        manager.expenses.reduce(0) { $0 + $1.amount }
    }
    private func totalLoanPayments() -> Double {
        manager.expenses.filter { $0.isLoan }.reduce(0) { $0 + $1.amount }
    }
    private func expensesByCategory() -> [CategoryAmount] {
        var grouped: [String: Double] = [:]
        for e in manager.expenses { grouped[e.category, default: 0] += e.amount }
        return grouped.map { CategoryAmount(category: $0.key, amount: $0.value) }
    }
    private func groupedIncomeHistory() -> [DateAmount] {
        var grouped: [String: Double] = [:]
        for i in manager.incomes { grouped[i.dateString, default: 0] += i.amount }
        return grouped.map { DateAmount(date: $0.key, amount: $0.value) }
            .sorted { $0.date < $1.date }
    }
    private func groupedExpenseHistory() -> [DateAmount] {
        var grouped: [String: Double] = [:]
        for e in manager.expenses { grouped[e.dateString, default: 0] += e.amount }
        return grouped.map { DateAmount(date: $0.key, amount: $0.value) }
            .sorted { $0.date < $1.date }
    }

    // palette for donut
    private var palette: [Color] {
        [
            Color(hex: "#5F9DDC"), Color(hex: "#76B7D5"),
            Color(hex: "#A1D99B"), Color(hex: "#F0DFDD"),
            Color(hex: "#BE5579"), Color(hex: "#F3A683"),
            Color(hex: "#F7DC6F"), Color(hex: "#AED6F1")
        ]
    }
}

// MARK: - Legend row
private struct LegendRow: View {
    let color: Color; let title: String; let amountText: String; let percentText: String
    var body: some View {
        HStack(spacing: 10) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(title).font(.subheadline).lineLimit(1).foregroundColor(.primary)
            Spacer()
            Text("\(amountText) • \(percentText)").font(.caption).foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Hex color init
extension Color {
    init(hex: String, opacity: Double = 1.0) {
        let s = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0; Scanner(string: s).scanHexInt64(&rgb)
        self.init(.sRGB,
                  red:   Double((rgb & 0xFF0000) >> 16)/255.0,
                  green: Double((rgb & 0x00FF00) >> 8)/255.0,
                  blue:  Double(rgb & 0x0000FF)/255.0,
                  opacity: opacity)
    }
}
