import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var manager = FirestoreManager()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    HeaderAndBarCard(
                        incomeTotal: totalIncome(),
                        expenseTotal: totalExpense()
                    )

                    ExpensesByCategoryCard(
                        data: expensesByCategory()
                    )

                    TrendCard(
                        incomeData: groupedIncomeHistory(),
                        expenseData: groupedExpenseHistory()
                    )

                    DTICard(
                        debt: totalLoanPayments(),
                        income: totalIncome()
                    )

                    SummaryCard(
                        income: totalIncome(),
                        expense: totalExpense()
                    )
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

    // MARK: - Local models for charts
    struct CategoryAmount: Identifiable, Equatable {
        let id = UUID()
        let category: String
        let amount: Double
    }
    struct DateAmount: Identifiable, Equatable {
        let id = UUID()
        let date: String
        let amount: Double
    }

    // MARK: - Aggregations (unchanged)
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
        var dict: [String: Double] = [:]
        for e in manager.expenses { dict[e.category, default: 0] += e.amount }
        return dict.map { CategoryAmount(category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    private func groupedIncomeHistory() -> [DateAmount] {
        var dict: [String: Double] = [:]
        for i in manager.incomes { dict[i.dateString, default: 0] += i.amount }
        return dict.map { DateAmount(date: $0.key, amount: $0.value) }
            .sorted { $0.date < $1.date }
    }
    private func groupedExpenseHistory() -> [DateAmount] {
        var dict: [String: Double] = [:]
        for e in manager.expenses { dict[e.dateString, default: 0] += e.amount }
        return dict.map { DateAmount(date: $0.key, amount: $0.value) }
            .sorted { $0.date < $1.date }
    }
}

// MARK: - Header + Blue Bar Card (YouTube-like)
private struct HeaderAndBarCard: View {
    let incomeTotal: Double
    let expenseTotal: Double

    private var cardHeight: CGFloat {
        UIScreen.main.bounds.height * 0.42
    }

    var body: some View {
        VStack(spacing: 24) {
            // Top row: gear + title
            HStack {
                Image(systemName: "gearshape.fill")
                    .resizable().scaledToFill().frame(width: 20, height: 20)
                Spacer()
                Text("Spending")
                    .font(.headline.weight(.semibold))
                    .padding(.trailing, 20)
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.top, 16)
            .padding(.horizontal)

            // Subheader + legend
            HStack {
                HStack(spacing: 10) {
                    Text("Monthly")
                        .font(.title.bold())
                    Image(systemName: "chevron.down")
                        .resizable().scaledToFill().frame(width: 8, height: 8)
                        .fontWeight(.bold).padding(.top, 6)
                }
                .foregroundStyle(.white)

                Spacer()

                HStack(spacing: 14) {
                    LegendDot(title: "Earned", color: Color.white.opacity(0.9))
                    LegendDot(title: "Spent",  color: Color.white.opacity(0.6))
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 18)
                .background(.black.opacity(0.22))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal)

            // White rounded bars on blue background
            Chart {
                BarMark(x: .value("Type", "Income"),
                        y: .value("Amount", incomeTotal))
                .clipShape(YTRoundedBar(radius: 8))
                .foregroundStyle(.white)

                BarMark(x: .value("Type", "Expense"),
                        y: .value("Amount", expenseTotal))
                .clipShape(YTRoundedBar(radius: 8))
                .foregroundStyle(.white)
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisGridLine().foregroundStyle(.clear)
                    AxisTick().foregroundStyle(.white)
                    AxisValueLabel().foregroundStyle(.white)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine().foregroundStyle(.white.opacity(0.5))
                    AxisTick().foregroundStyle(.white)
                    AxisValueLabel() {
                        if let v = value.as(Double.self) {
                            Text("$\(v, specifier: "%.0f")").foregroundStyle(.white)
                        }
                    }
                }
            }
            .frame(height: 180)
            .padding(.horizontal)
            .animation(.easeOut(duration: 0.6), value: incomeTotal)
            .animation(.easeOut(duration: 0.6), value: expenseTotal)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)   // fix: no 'height:' label here
        .frame(height: cardHeight)    // height set in a separate frame
        .background(Color(UIColor.systemBlue))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

private struct LegendDot: View {
    let title: String
    let color: Color
    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 9, height: 9).padding(.top, 2)
            Text(title).font(.subheadline).foregroundStyle(.white)
        }
    }
}

// Renamed to avoid duplicate-definition error
private struct YTRoundedBar: Shape {
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height),
                            cornerSize: CGSize(width: radius, height: radius),
                            style: .continuous)
        return path
    }
}

// MARK: - Donut + Legend
private struct ExpensesByCategoryCard: View {
    let data: [DashboardView.CategoryAmount]

    // Avoid type ambiguity: explicitly typed palette
    private let palette: [Color] = [
        Color(red: 0.37, green: 0.62, blue: 0.86),
        Color(red: 0.46, green: 0.72, blue: 0.84),
        Color(red: 0.63, green: 0.85, blue: 0.61),
        Color(red: 0.94, green: 0.87, blue: 0.87),
        Color(red: 0.75, green: 0.33, blue: 0.47),
        Color(red: 0.95, green: 0.66, blue: 0.51),
        Color(red: 0.97, green: 0.86, blue: 0.44),
        Color(red: 0.68, green: 0.84, blue: 0.95)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Expenses by Category").font(.headline)
                .foregroundColor(.black).padding(.horizontal)

            let sorted = data.sorted { $0.amount > $1.amount }
            let total = max(sorted.reduce(0) { $0 + $1.amount }, 0.0001)
            let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())] // explicit to avoid ambiguity

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

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(sorted.enumerated()), id: \.offset) { idx, item in
                        HStack(spacing: 10) {
                            Circle().fill(palette[idx % palette.count]).frame(width: 10, height: 10)
                            Text(item.category).font(.subheadline).lineLimit(1).foregroundColor(.primary)
                            Spacer()
                            let pct = Int((item.amount / total) * 100)
                            Text("$\(item.amount, specifier: "%.2f") • \(pct)%")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.bottom, 6)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

// MARK: - Trend
private struct TrendCard: View {
    let incomeData: [DashboardView.DateAmount]
    let expenseData: [DashboardView.DateAmount]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Income vs Expense Trend").font(.headline)
                .foregroundColor(.black).padding(.horizontal)

            Chart {
                ForEach(incomeData) { item in
                    LineMark(x: .value("Date", item.date), y: .value("Income", item.amount))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.green).symbol(Circle())
                }
                ForEach(expenseData) { item in
                    LineMark(x: .value("Date", item.date), y: .value("Expense", item.amount))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.red).symbol(Circle())
                }
            }
            .frame(height: 240)
            .animation(.easeInOut(duration: 0.6), value: incomeData)
            .animation(.easeInOut(duration: 0.6), value: expenseData)
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

// MARK: - DTI
private struct DTICard: View {
    let debt: Double
    let income: Double

    var body: some View {
        let remaining = max(income - debt, 0)
        let ratio = income > 0 ? (debt / income) * 100 : 0

        VStack(alignment: .leading, spacing: 12) {
            Text("Debt-to-Income Ratio").font(.headline)
                .foregroundColor(.black).padding(.horizontal)

            VStack {
                Chart {
                    SectorMark(angle: .value("Debt", debt), innerRadius: .ratio(0.5)).foregroundStyle(.red)
                    SectorMark(angle: .value("Remaining", remaining), innerRadius: .ratio(0.5)).foregroundStyle(.green)
                }
                .frame(height: 220)
                .animation(.easeInOut(duration: 0.6), value: debt)
                .animation(.easeInOut(duration: 0.6), value: income)

                Text("DTI: \(ratio, specifier: "%.1f")%")
                    .font(.subheadline)
                    .foregroundColor(ratio > 35 ? .red : .green)
                    .padding(.top, 4)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

// MARK: - Summary
private struct SummaryCard: View {
    let income: Double
    let expense: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary").font(.headline)
                .foregroundColor(.black).padding(.horizontal)

            VStack(alignment: .leading, spacing: 6) {
                Text("Total Income: $\(income, specifier: "%.2f")")
                Text("Total Expense: $\(expense, specifier: "%.2f")")
                Text("Net: $\(income - expense, specifier: "%.2f")")
                    .foregroundColor((income - expense) >= 0 ? .green : .red)
            }
            .font(.body)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.vertical, 12)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}
