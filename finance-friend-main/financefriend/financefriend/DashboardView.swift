////import SwiftUI
////import Charts
////
////struct DashboardView: View {
////    @StateObject private var manager = FirestoreManager()
////
////    var body: some View {
////        NavigationView {
////            ScrollView {
////                VStack(spacing: 24) {
////                    HeaderAndBarCard(
////                        incomeTotal: totalIncome(),
////                        expenseTotal: totalExpense()
////                    )
////
////                    BudgetProgressCard(
////                        goals: manager.goals,
////                        expenses: manager.expenses
////                    )
////
////                    ExpensesByCategoryCard(
////                        data: expensesByCategory()
////                    )
////
////                    TrendCard(
////                        incomeData: groupedIncomeHistory(),
////                        expenseData: groupedExpenseHistory()
////                    )
////
////                    DTICard(
////                        debt: totalLoanPayments(),
////                        income: totalIncome()
////                    )
////
////                    SummaryCard(
////                        income: totalIncome(),
////                        expense: totalExpense()
////                    )
////                }
////                .padding(.vertical)
////            }
////            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
////            .navigationTitle("Dashboard")
////            .onAppear {
////                manager.fetchAllExpenses()
////                manager.fetchAllIncomes()
////                manager.fetchGoals()
////            }
////        }
////    }
////
////    // MARK: - Local simple models for charts
////    struct CategoryAmount: Identifiable, Equatable {
////        let id = UUID()
////        let category: String
////        let amount: Double
////    }
////    struct DateAmount: Identifiable, Equatable {
////        let id = UUID()
////        let date: String
////        let amount: Double
////    }
////
////    // MARK: - Aggregations
////    private func totalIncome() -> Double {
////        manager.incomes.reduce(0) { $0 + $1.amount }
////    }
////    private func totalExpense() -> Double {
////        manager.expenses.reduce(0) { $0 + $1.amount }
////    }
////    private func totalLoanPayments() -> Double {
////        manager.expenses.filter { $0.isLoan }.reduce(0) { $0 + $1.amount }
////    }
////    private func expensesByCategory() -> [CategoryAmount] {
////        var dict: [String: Double] = [:]
////        for e in manager.expenses { dict[e.category, default: 0] += e.amount }
////        return dict.map { CategoryAmount(category: $0.key, amount: $0.value) }
////            .sorted { $0.amount > $1.amount }
////    }
////    private func groupedIncomeHistory() -> [DateAmount] {
////        var dict: [String: Double] = [:]
////        for i in manager.incomes { dict[i.dateString, default: 0] += i.amount }
////        return dict.map { DateAmount(date: $0.key, amount: $0.value) }
////            .sorted { $0.date < $1.date }
////    }
////    private func groupedExpenseHistory() -> [DateAmount] {
////        var dict: [String: Double] = [:]
////        for e in manager.expenses { dict[e.dateString, default: 0] += e.amount }
////        return dict.map { DateAmount(date: $0.key, amount: $0.value) }
////            .sorted { $0.date < $1.date }
////    }
////}
////
////// MARK: - Header + Blue Bar Card (slim, centered bars on iOS16)
////private struct HeaderAndBarCard: View {
////    let incomeTotal: Double
////    let expenseTotal: Double
////
////    private let expenseColor = Color(red: 0.95, green: 0.35, blue: 0.30)
////
////    // Compact height to look good on modern devices
////    private var cardHeight: CGFloat {
////        max(260, UIScreen.main.bounds.height * 0.33)
////    }
////
////    var body: some View {
////        VStack(spacing: 18) {
////            // Title row
////            HStack {
////                Image(systemName: "gearshape.fill")
////                    .resizable().scaledToFill().frame(width: 20, height: 20)
////                Spacer()
////                Text("Spending")
////                    .font(.headline.weight(.semibold))
////                    .padding(.trailing, 16)
////                Spacer()
////            }
////            .foregroundStyle(.white)
////            .padding(.top, 10)
////            .padding(.horizontal)
////
////            // Subheader + legend
////            HStack {
////                HStack(spacing: 8) {
////                    Text("Monthly").font(.title.bold())
////                    Image(systemName: "chevron.down")
////                        .resizable().scaledToFill().frame(width: 8, height: 8)
////                        .fontWeight(.bold).padding(.top, 4)
////                }
////                .foregroundStyle(.white)
////
////                Spacer()
////
////                HStack(spacing: 12) {
////                    LegendDot(title: "Earned", color: Color.white.opacity(0.95))
////                    LegendDot(title: "Spent",  color: expenseColor)
////                }
////                .padding(.vertical, 6)
////                .padding(.horizontal, 14)
////                .background(.black.opacity(0.22))
////                .clipShape(RoundedRectangle(cornerRadius: 18))
////            }
////            .padding(.horizontal)
////
////            // Symmetric domain to center two slim bars
////            let domain = ["spL1","spL2","Income","spM1","spM2","Expense","spR1","spR2"]
////            let bars: [(label: String, value: Double, visible: Bool, color: Color)] = [
////                ("spL1", 0, false, .clear),
////                ("spL2", 0, false, .clear),
////                ("Income", incomeTotal, true, .white),
////                ("spM1", 0, false, .clear),
////                ("spM2", 0, false, .clear),
////                ("Expense", expenseTotal, true, expenseColor),
////                ("spR1", 0, false, .clear),
////                ("spR2", 0, false, .clear)
////            ]
////
////            Chart {
////                ForEach(Array(bars.enumerated()), id: \.offset) { _, item in
////                    BarMark(
////                        x: .value("Type", item.label),
////                        y: .value("Amount", item.value)
////                    )
////                    .clipShape(YTRoundedBar(radius: 8))
////                    .foregroundStyle(item.color)
////                    .opacity(item.visible ? 1 : 0) // hide spacers
////                }
////            }
////            .chartXScale(domain: domain)
////            .chartXAxis {
////                AxisMarks(position: .bottom) { value in
////                    if let s = value.as(String.self), s == "Income" || s == "Expense" {
////                        AxisGridLine().foregroundStyle(.clear)
////                        AxisTick().foregroundStyle(.white)
////                        AxisValueLabel().foregroundStyle(.white)
////                    } else {
////                        AxisGridLine().foregroundStyle(.clear)
////                        AxisTick().foregroundStyle(.clear)
////                        AxisValueLabel("").foregroundStyle(.clear)
////                    }
////                }
////            }
////            .chartYAxis {
////                AxisMarks(position: .leading) { value in
////                    AxisGridLine().foregroundStyle(.white.opacity(0.5))
////                    AxisTick().foregroundStyle(.white)
////                    AxisValueLabel() {
////                        if let v = value.as(Double.self) {
////                            Text("$\(v, specifier: "%.0f")").foregroundStyle(.white)
////                        }
////                    }
////                }
////            }
////            .frame(height: 150)
////            .padding(.horizontal, 10)
////            .animation(.easeOut(duration: 0.6), value: incomeTotal)
////            .animation(.easeOut(duration: 0.6), value: expenseTotal)
////
////            Spacer(minLength: 0)
////        }
////        .frame(maxWidth: .infinity)
////        .frame(height: cardHeight)
////        .background(Color(UIColor.systemBlue))
////        .clipShape(RoundedRectangle(cornerRadius: 16))
////        .padding(.horizontal, 14)
////        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
////    }
////}
////
////private struct LegendDot: View {
////    let title: String
////    let color: Color
////    var body: some View {
////        HStack(spacing: 8) {
////            Circle().fill(color).frame(width: 9, height: 9).padding(.top, 2)
////            Text(title).font(.subheadline).foregroundStyle(.white)
////        }
////    }
////}
////
////private struct YTRoundedBar: Shape {
////    var radius: CGFloat
////    func path(in rect: CGRect) -> Path {
////        var path = Path()
////        path.addRoundedRect(in: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height),
////                            cornerSize: CGSize(width: radius, height: radius),
////                            style: .continuous)
////        return path
////    }
////}
////
////// MARK: - Budget Progress Card
////private struct BudgetProgressCard: View {
////    let goals: [GoalItem]
////    let expenses: [ExpenseItem]
////
////    var body: some View {
////        VStack(alignment: .leading, spacing: 12) {
////            Text("Budget Progress").font(.headline)
////                .foregroundColor(.black).padding(.horizontal)
////
////            if goals.isEmpty {
////                Text("No goals set. Add goals in Account → Budget Goals.")
////                    .foregroundColor(.secondary)
////                    .padding(.horizontal)
////                    .padding(.bottom, 8)
////            } else {
////                VStack(spacing: 10) {
////                    ForEach(goals) { goal in
////                        BudgetRow(goal: goal, spent: totalSpent(for: goal.category))
////                    }
////                }
////                .padding(.horizontal)
////                .padding(.bottom, 6)
////            }
////        }
////        .padding(.vertical, 12)
////        .background(.white)
////        .cornerRadius(16)
////        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
////        .padding(.horizontal, 14)
////    }
////
////    private func totalSpent(for category: String) -> Double {
////        expenses.filter { $0.category == category }
////            .reduce(0) { $0 + $1.amount }
////    }
////}
////
////private struct BudgetRow: View {
////    let goal: GoalItem
////    let spent: Double
////
////    private var percent: Double {
////        guard goal.limit > 0 else { return 0 }
////        let p = spent / goal.limit
////        return min(max(p, 0), 2) // clamp 0...200%
////    }
////
////    private var barColor: Color {
////        if goal.goalType == "under" {
////            switch percent {
////            case ..<1.0: return .green
////            case 1.0..<1.2: return .yellow
////            default: return .red
////            }
////        } else {
////            return spent >= goal.limit ? .green : .red
////        }
////    }
////
////    var body: some View {
////        VStack(alignment: .leading, spacing: 6) {
////            HStack {
////                Text(goal.category).font(.subheadline).fontWeight(.semibold)
////                Spacer()
////                Text(goal.goalType == "over" ? "Target ≥ \(goal.limit, specifier: "%.2f")"
////                                             : "Limit ≤ \(goal.limit, specifier: "%.2f")")
////                    .font(.caption)
////                    .foregroundColor(.secondary)
////            }
////
////            GeometryReader { geo in
////                ZStack(alignment: .leading) {
////                    RoundedRectangle(cornerRadius: 8)
////                        .fill(Color.secondary.opacity(0.15))
////                        .frame(height: 10)
////
////                    let width = min(max(percent, 0), 1.0) * geo.size.width
////                    RoundedRectangle(cornerRadius: 8)
////                        .fill(barColor)
////                        .frame(width: width, height: 10)
////                        .animation(.easeInOut(duration: 0.4), value: width)
////                }
////            }
////            .frame(height: 10)
////
////            HStack {
////                Text("Spent: $\(spent, specifier: "%.2f")")
////                Spacer()
////                Text("Limit: $\(goal.limit, specifier: "%.2f")")
////            }
////            .font(.caption)
////            .foregroundColor(.secondary)
////        }
////    }
////}
////
////// MARK: - Expenses by Category (Donut + Legend)
////private struct ExpensesByCategoryCard: View {
////    let data: [DashboardView.CategoryAmount]
////
////    private let palette: [Color] = [
////        Color(red: 0.37, green: 0.62, blue: 0.86),
////        Color(red: 0.46, green: 0.72, blue: 0.84),
////        Color(red: 0.63, green: 0.85, blue: 0.61),
////        Color(red: 0.94, green: 0.87, blue: 0.87),
////        Color(red: 0.75, green: 0.33, blue: 0.47),
////        Color(red: 0.95, green: 0.66, blue: 0.51),
////        Color(red: 0.97, green: 0.86, blue: 0.44),
////        Color(red: 0.68, green: 0.84, blue: 0.95)
////    ]
////
////    var body: some View {
////        VStack(alignment: .leading, spacing: 10) {
////            Text("Expenses by Category").font(.headline)
////                .foregroundColor(.black).padding(.horizontal)
////
////            let sorted = data.sorted { $0.amount > $1.amount }
////            let total = max(sorted.reduce(0) { $0 + $1.amount }, 0.0001)
////            let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
////
////            VStack(spacing: 12) {
////                Chart {
////                    ForEach(Array(sorted.enumerated()), id: \.offset) { idx, item in
////                        SectorMark(
////                            angle: .value("Amount", item.amount),
////                            innerRadius: .ratio(0.7)
////                        )
////                        .foregroundStyle(palette[idx % palette.count])
////                        .cornerRadius(2)
////                    }
////                }
////                .chartLegend(.hidden)
////                .frame(height: 200)
////                .animation(.easeInOut(duration: 0.6), value: sorted)
////
////                LazyVGrid(columns: columns, spacing: 8) {
////                    ForEach(Array(sorted.enumerated()), id: \.offset) { idx, item in
////                        HStack(spacing: 8) {
////                            Circle().fill(palette[idx % palette.count]).frame(width: 10, height: 10)
////                            Text(item.category).font(.subheadline).lineLimit(1).foregroundColor(.primary)
////                            Spacer()
////                            let pct = Int((item.amount / total) * 100)
////                            Text("$\(item.amount, specifier: "%.0f") • \(pct)%")
////                                .font(.caption).foregroundColor(.secondary)
////                        }
////                        .padding(.horizontal, 6)
////                    }
////                }
////                .padding(.bottom, 6)
////            }
////            .padding(.horizontal)
////        }
////        .padding(.vertical, 10)
////        .background(.white)
////        .cornerRadius(16)
////        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
////        .padding(.horizontal, 14)
////    }
////}
////
////// MARK: - Trend (Income vs Expense)
////private struct TrendCard: View {
////    let incomeData: [DashboardView.DateAmount]
////    let expenseData: [DashboardView.DateAmount]
////
////    private let expenseColor = Color(red: 0.95, green: 0.35, blue: 0.30)
////
////    var body: some View {
////        VStack(alignment: .leading, spacing: 10) {
////            Text("Income vs Expense Trend").font(.headline)
////                .foregroundColor(.black).padding(.horizontal)
////
////            Chart {
////                ForEach(incomeData) { item in
////                    LineMark(x: .value("Date", item.date), y: .value("Income", item.amount))
////                        .interpolationMethod(.catmullRom)
////                        .foregroundStyle(.green).symbol(Circle())
////                }
////                ForEach(expenseData) { item in
////                    LineMark(x: .value("Date", item.date), y: .value("Expense", item.amount))
////                        .interpolationMethod(.catmullRom)
////                        .foregroundStyle(expenseColor)
////                        .symbol(Circle())
////                }
////            }
////            .frame(height: 200)
////            .animation(.easeInOut(duration: 0.6), value: incomeData)
////            .animation(.easeInOut(duration: 0.6), value: expenseData)
////            .padding(.horizontal, 10)
////        }
////        .padding(.vertical, 10)
////        .background(.white)
////        .cornerRadius(16)
////        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
////        .padding(.horizontal, 14)
////    }
////}
////
////// MARK: - DTI
////private struct DTICard: View {
////    let debt: Double
////    let income: Double
////
////    var body: some View {
////        let remaining = max(income - debt, 0)
////        let ratio = income > 0 ? (debt / income) * 100 : 0
////
////        VStack(alignment: .leading, spacing: 10) {
////            Text("Debt-to-Income Ratio").font(.headline)
////                .foregroundColor(.black).padding(.horizontal)
////
////            VStack(spacing: 8) {
////                Chart {
////                    SectorMark(angle: .value("Debt", debt), innerRadius: .ratio(0.6)).foregroundStyle(.red)
////                    SectorMark(angle: .value("Remaining", remaining), innerRadius: .ratio(0.6)).foregroundStyle(.green)
////                }
////                .frame(height: 180)
////                .animation(.easeInOut(duration: 0.6), value: debt)
////                .animation(.easeInOut(duration: 0.6), value: income)
////
////                Text("DTI: \(ratio, specifier: "%.1f")%")
////                    .font(.subheadline)
////                    .foregroundColor(ratio > 35 ? .red : .green)
////            }
////            .padding(.horizontal, 10)
////        }
////        .padding(.vertical, 10)
////        .background(.white)
////        .cornerRadius(16)
////        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
////        .padding(.horizontal, 14)
////    }
////}
////
////// MARK: - Summary
////private struct SummaryCard: View {
////    let income: Double
////    let expense: Double
////    var body: some View {
////        VStack(alignment: .leading, spacing: 10) {
////            Text("Summary").font(.headline)
////                .foregroundColor(.black).padding(.horizontal)
////
////            VStack(alignment: .leading, spacing: 4) {
////                Text("Total Income: $\(income, specifier: "%.2f")")
////                Text("Total Expense: $\(expense, specifier: "%.2f")")
////                Text("Net: $\(income - expense, specifier: "%.2f")")
////                    .foregroundColor((income - expense) >= 0 ? .green : .red)
////            }
////            .font(.body)
////            .padding(.horizontal, 10)
////            .padding(.bottom, 6)
////        }
////        .padding(.vertical, 10)
////        .background(.white)
////        .cornerRadius(16)
////        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
////        .padding(.horizontal, 14)
////    }
////}
//import SwiftUI
//import Charts
//
//struct DashboardView: View {
//    @StateObject private var manager = FirestoreManager()
//    @State private var timeRange: WealthRange = .oneMonth   // for Wealth Over Time
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 24) {
//
//                    // YouTube-style top card with two slim centered bars (Income/Expense)
//                    HeaderAndBarCard(
//                        incomeTotal: totalIncome(),
//                        expenseTotal: totalExpense()
//                    )
//
//                    // Budget goals progress (reads manager.goals + manager.expenses)
//                    BudgetProgressCard(
//                        goals: manager.goals,
//                        expenses: manager.expenses
//                    )
//
//                    // Monthly expenses breakdown (current month, bars by category)
//                    MonthlyExpensesBarCard(
//                        monthly: monthlyExpensesByCategory()
//                    )
//
//                    // Donut with legend under it
//                    ExpensesByCategoryCard(
//                        data: expensesByCategory()
//                    )
//
//                    // Wealth over time with time range selector
//                    WealthOverTimeCard(
//                        series: wealthSeries(range: timeRange),
//                        range: $timeRange
//                    )
//
//                    // Income vs Expense trend lines
//                    TrendCard(
//                        incomeData: groupedIncomeHistory(),
//                        expenseData: groupedExpenseHistory()
//                    )
//
//                    // Debt to income donut + DTI label
//                    DTICard(
//                        debt: totalLoanPayments(),
//                        income: totalIncome()
//                    )
//
//                    // Simple totals
//                    SummaryCard(
//                        income: totalIncome(),
//                        expense: totalExpense()
//                    )
//                }
//                .padding(.vertical)
//            }
//            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
//            .navigationTitle("Dashboard")
//            .onAppear {
//                manager.fetchAllExpenses()
//                manager.fetchAllIncomes()
//                manager.fetchGoals()
//                manager.fetchAccounts() // needed for Wealth Over Time
//            }
//        }
//    }
//
//    // MARK: - Local simple models for charts
//    struct CategoryAmount: Identifiable, Equatable {
//        let id = UUID()
//        let category: String
//        let amount: Double
//    }
//
//    struct DateAmount: Identifiable, Equatable {
//        let id = UUID()
//        let date: String
//        let amount: Double
//    }
//
//    struct SeriesPoint: Identifiable, Equatable {
//        let id = UUID()
//        let date: Date
//        let total: Double
//    }
//
//    // MARK: - Aggregations
//    private func totalIncome() -> Double {
//        manager.incomes.reduce(0) { $0 + $1.amount }
//    }
//
//    private func totalExpense() -> Double {
//        manager.expenses.reduce(0) { $0 + $1.amount }
//    }
//
//    private func totalLoanPayments() -> Double {
//        manager.expenses.filter { $0.isLoan }.reduce(0) { $0 + $1.amount }
//    }
//
//    private func expensesByCategory() -> [CategoryAmount] {
//        var dict: [String: Double] = [:]
//        for e in manager.expenses { dict[e.category, default: 0] += e.amount }
//        return dict.map { CategoryAmount(category: $0.key, amount: $0.value) }
//            .sorted { $0.amount > $1.amount }
//    }
//
//    private func groupedIncomeHistory() -> [DateAmount] {
//        var dict: [String: Double] = [:]
//        for i in manager.incomes { dict[i.dateString, default: 0] += i.amount }
//        return dict.map { DateAmount(date: $0.key, amount: $0.value) }
//            .sorted { $0.date < $1.date }
//    }
//
//    private func groupedExpenseHistory() -> [DateAmount] {
//        var dict: [String: Double] = [:]
//        for e in manager.expenses { dict[e.dateString, default: 0] += e.amount }
//        return dict.map { DateAmount(date: $0.key, amount: $0.value) }
//            .sorted { $0.date < $1.date }
//    }
//
//    // MARK: - Monthly Expenses Breakdown (current month)
//    private func monthlyExpensesByCategory() -> [CategoryAmount] {
//        let cur = Date()
//        let fm = DateFormatter()
//        fm.dateFormat = "yyyy-MM"
//        let key = fm.string(from: cur)
//
//        var dict: [String: Double] = [:]
//        for e in manager.expenses {
//            let monthKey = String(e.dateString.prefix(7)) // "yyyy-MM"
//            if monthKey == key {
//                dict[e.category, default: 0] += e.amount
//            }
//        }
//        return dict.map { CategoryAmount(category: $0.key, amount: $0.value) }
//            .sorted { $0.amount > $1.amount }
//    }
//
//    // MARK: - Wealth Over Time
//    enum WealthRange: String, CaseIterable, Identifiable {
//        case oneMonth = "1M", sixMonths = "6M", oneYear = "1Y", fiveYears = "5Y"
//        var id: String { rawValue }
//        var months: Int {
//            switch self {
//            case .oneMonth: return 1
//            case .sixMonths: return 6
//            case .oneYear:   return 12
//            case .fiveYears: return 60
//            }
//        }
//    }
//
//    private func wealthSeries(range: WealthRange) -> [SeriesPoint] {
//        let f = DateFormatter()
//        f.dateFormat = "yyyy-MM-dd"
//        var dict: [String: Double] = [:]
//
//        if manager.accounts.isEmpty {
//            return []
//        } else {
//            for acc in manager.accounts {
//                if acc.history.isEmpty {
//                    dict[acc.createdAt, default: 0] += acc.balance
//                } else {
//                    for h in acc.history {
//                        dict[h.date, default: 0] += h.amount
//                    }
//                }
//            }
//        }
//
//        var pts: [SeriesPoint] = []
//        for (k, v) in dict {
//            if let d = f.date(from: k) {
//                pts.append(.init(date: d, total: v))
//            }
//        }
//        pts.sort { $0.date < $1.date }
//
//        let end = Date()
//        let start = Calendar.current.date(byAdding: .month, value: -range.months, to: end) ?? end
//        let filtered = pts.filter { $0.date >= start && $0.date <= end }
//
//        if filtered.isEmpty {
//            let totalNow = manager.accounts.reduce(0) { $0 + $1.balance }
//            let seedDates: [Date] = stride(from: 5, through: 0, by: -1).compactMap {
//                Calendar.current.date(byAdding: .day, value: -$0 * 6, to: end)
//            }
//            return seedDates.map { SeriesPoint(date: $0, total: totalNow) }
//        }
//
//        return filtered
//    }
//}
//
//// MARK: - Header + Blue Bar Card (YouTube-like, slim centered bars iOS16-safe)
//private struct HeaderAndBarCard: View {
//    let incomeTotal: Double
//    let expenseTotal: Double
//
//    private let expenseColor = Color(red: 0.95, green: 0.35, blue: 0.30)
//    private var cardHeight: CGFloat { max(260, UIScreen.main.bounds.height * 0.33) }
//
//    var body: some View {
//        VStack(spacing: 18) {
//            HStack {
//                Image(systemName: "gearshape.fill")
//                    .resizable().scaledToFill().frame(width: 20, height: 20)
//                Spacer()
//                Text("Spending")
//                    .font(.headline.weight(.semibold))
//                    .padding(.trailing, 16)
//                Spacer()
//            }
//            .foregroundStyle(.white)
//            .padding(.top, 10)
//            .padding(.horizontal)
//
//            HStack {
//                HStack(spacing: 8) {
//                    Text("Monthly").font(.title.bold())
//                    Image(systemName: "chevron.down")
//                        .resizable().scaledToFill().frame(width: 8, height: 8)
//                        .fontWeight(.bold).padding(.top, 4)
//                }
//                .foregroundStyle(.white)
//
//                Spacer()
//
//                HStack(spacing: 12) {
//                    LegendDot(title: "Earned", color: Color.white.opacity(0.95))
//                    LegendDot(title: "Spent",  color: expenseColor)
//                }
//                .padding(.vertical, 6)
//                .padding(.horizontal, 14)
//                .background(.black.opacity(0.22))
//                .clipShape(RoundedRectangle(cornerRadius: 18))
//            }
//            .padding(.horizontal)
//
//            // Centered slim bars using spacer buckets in the x domain
//            let domain = ["spL1","spL2","Income","spM1","spM2","Expense","spR1","spR2"]
//            let bars: [(label: String, value: Double, visible: Bool, color: Color)] = [
//                ("spL1", 0, false, .clear),
//                ("spL2", 0, false, .clear),
//                ("Income", incomeTotal, true, .white),
//                ("spM1", 0, false, .clear),
//                ("spM2", 0, false, .clear),
//                ("Expense", expenseTotal, true, expenseColor),
//                ("spR1", 0, false, .clear),
//                ("spR2", 0, false, .clear)
//            ]
//
//            Chart {
//                ForEach(Array(bars.enumerated()), id: \.offset) { _, item in
//                    BarMark(
//                        x: .value("Type", item.label),
//                        y: .value("Amount", item.value)
//                    )
//                    .clipShape(YTRoundedBar(radius: 8))
//                    .foregroundStyle(item.color)
//                    .opacity(item.visible ? 1 : 0) // hide spacers
//                }
//            }
//            .chartXScale(domain: domain)
//            .chartXAxis {
//                AxisMarks(position: .bottom) { value in
//                    if let s = value.as(String.self), s == "Income" || s == "Expense" {
//                        AxisGridLine().foregroundStyle(.clear)
//                        AxisTick().foregroundStyle(.white)
//                        AxisValueLabel().foregroundStyle(.white)
//                    } else {
//                        AxisGridLine().foregroundStyle(.clear)
//                        AxisTick().foregroundStyle(.clear)
//                        AxisValueLabel("").foregroundStyle(.clear)
//                    }
//                }
//            }
//            .chartYAxis {
//                AxisMarks(position: .leading) { value in
//                    AxisGridLine().foregroundStyle(.white.opacity(0.5))
//                    AxisTick().foregroundStyle(.white)
//                    AxisValueLabel() {
//                        if let v = value.as(Double.self) {
//                            Text("$\(v, specifier: "%.0f")").foregroundStyle(.white)
//                        }
//                    }
//                }
//            }
//            .frame(height: 150)
//            .padding(.horizontal, 10)
//            .animation(.easeOut(duration: 0.6), value: incomeTotal)
//            .animation(.easeOut(duration: 0.6), value: expenseTotal)
//
//            Spacer(minLength: 0)
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: cardHeight)
//        .background(Color(UIColor.systemBlue))
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .padding(.horizontal, 14)
//        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
//    }
//}
//
//private struct LegendDot: View {
//    let title: String
//    let color: Color
//    var body: some View {
//        HStack(spacing: 8) {
//            Circle().fill(color).frame(width: 9, height: 9).padding(.top, 2)
//            Text(title).font(.subheadline).foregroundStyle(.white)
//        }
//    }
//}
//
//private struct YTRoundedBar: Shape {
//    var radius: CGFloat
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        path.addRoundedRect(in: rect, cornerSize: CGSize(width: radius, height: radius), style: .continuous)
//        return path
//    }
//}
//
//// MARK: - Budget Progress Card
//private struct BudgetProgressCard: View {
//    let goals: [GoalItem]
//    let expenses: [ExpenseItem]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Budget Progress").font(.headline)
//                .foregroundColor(.black).padding(.horizontal)
//
//            if goals.isEmpty {
//                Text("No goals set. Add goals in Account → Budget Goals.")
//                    .foregroundColor(.secondary)
//                    .padding(.horizontal)
//                    .padding(.bottom, 8)
//            } else {
//                VStack(spacing: 10) {
//                    ForEach(goals) { goal in
//                        BudgetRow(goal: goal, spent: totalSpent(for: goal.category))
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 6)
//            }
//        }
//        .padding(.vertical, 12)
//        .background(.white)
//        .cornerRadius(16)
//        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
//        .padding(.horizontal, 14)
//    }
//
//    private func totalSpent(for category: String) -> Double {
//        expenses.filter { $0.category == category }
//            .reduce(0) { $0 + $1.amount }
//    }
//}
//
//private struct BudgetRow: View {
//    let goal: GoalItem
//    let spent: Double
//
//    private var percent: Double {
//        guard goal.limit > 0 else { return 0 }
//        let p = spent / goal.limit
//        return min(max(p, 0), 2) // clamp 0...200%
//    }
//
//    private var barColor: Color {
//        if goal.goalType == "under" {
//            switch percent {
//            case ..<1.0: return .green
//            case 1.0..<1.2: return .yellow
//            default: return .red
//            }
//        } else {
//            return spent >= goal.limit ? .green : .red
//        }
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            HStack {
//                Text(goal.category).font(.subheadline).fontWeight(.semibold)
//                Spacer()
//                Text(goal.goalType == "over" ? "Target ≥ \(goal.limit, specifier: "%.2f")"
//                                             : "Limit ≤ \(goal.limit, specifier: "%.2f")")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//
//            GeometryReader { geo in
//                ZStack(alignment: .leading) {
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(Color.secondary.opacity(0.15))
//                        .frame(height: 10)
//
//                    let width = min(max(percent, 0), 1.0) * geo.size.width
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(barColor)
//                        .frame(width: width, height: 10)
//                        .animation(.easeInOut(duration: 0.4), value: width)
//                }
//            }
//            .frame(height: 10)
//
//            HStack {
//                Text("Spent: $\(spent, specifier: "%.2f")")
//                Spacer()
//                Text("Limit: $\(goal.limit, specifier: "%.2f")")
//            }
//            .font(.caption)
//            .foregroundColor(.secondary)
//        }
//    }
//}
//
//// MARK: - Monthly Expenses Breakdown
//private struct MonthlyExpensesBarCard: View {
//    let monthly: [DashboardView.CategoryAmount]
//
//    private let expenseColor = Color(red: 0.95, green: 0.35, blue: 0.30)
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Monthly Expenses Breakdown").font(.headline)
//                .foregroundColor(.black).padding(.horizontal)
//
//            if monthly.isEmpty {
//                Text("No expenses this month.")
//                    .foregroundColor(.secondary)
//                    .padding(.horizontal)
//                    .padding(.bottom, 8)
//            } else {
//                Chart {
//                    ForEach(monthly) { item in
//                        BarMark(x: .value("Category", item.category),
//                                y: .value("Amount", item.amount))
//                        .foregroundStyle(expenseColor)
//                    }
//                }
//                .chartXAxis {
//                    AxisMarks(position: .bottom) { value in
//                        AxisGridLine().foregroundStyle(.clear)
//                        AxisTick().foregroundStyle(.secondary)
//                        AxisValueLabel() {
//                            if let s = value.as(String.self) {
//                                Text(s).lineLimit(1).minimumScaleFactor(0.7)
//                            }
//                        }
//                    }
//                }
//                .chartYAxis {
//                    AxisMarks(position: .leading)
//                }
//                .frame(height: 200)
//                .padding(.horizontal, 10)
//            }
//        }
//        .padding(.vertical, 10)
//        .background(.white)
//        .cornerRadius(16)
//        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
//        .padding(.horizontal, 14)
//    }
//}
//
//// MARK: - Expenses by Category (Donut + Legend)
//private struct ExpensesByCategoryCard: View {
//    let data: [DashboardView.CategoryAmount]
//
//    private let palette: [Color] = [
//        Color(red: 0.37, green: 0.62, blue: 0.86),
//        Color(red: 0.46, green: 0.72, blue: 0.84),
//        Color(red: 0.63, green: 0.85, blue: 0.61),
//        Color(red: 0.94, green: 0.87, blue: 0.87),
//        Color(red: 0.75, green: 0.33, blue: 0.47),
//        Color(red: 0.95, green: 0.66, blue: 0.51),
//        Color(red: 0.97, green: 0.86, blue: 0.44),
//        Color(red: 0.68, green: 0.84, blue: 0.95)
//    ]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Expenses by Category").font(.headline)
//                .foregroundColor(.black).padding(.horizontal)
//
//            let sorted = data.sorted { $0.amount > $1.amount }
//            let total = max(sorted.reduce(0) { $0 + $1.amount }, 0.0001)
//            let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
//
//            VStack(spacing: 12) {
//                Chart {
//                    ForEach(Array(sorted.enumerated()), id: \.offset) { idx, item in
//                        SectorMark(
//                            angle: .value("Amount", item.amount),
//                            innerRadius: .ratio(0.7)
//                        )
//                        .foregroundStyle(palette[idx % palette.count])
//                        .cornerRadius(2)
//                    }
//                }
//                .chartLegend(.hidden)
//                .frame(height: 200)
//                .animation(.easeInOut(duration: 0.6), value: sorted)
//
//                LazyVGrid(columns: columns, spacing: 8) {
//                    ForEach(Array(sorted.enumerated()), id: \.offset) { idx, item in
//                        HStack(spacing: 8) {
//                            Circle().fill(palette[idx % palette.count]).frame(width: 10, height: 10)
//                            Text(item.category).font(.subheadline).lineLimit(1).foregroundColor(.primary)
//                            Spacer()
//                            let pct = Int((item.amount / total) * 100)
//                            Text("$\(item.amount, specifier: "%.0f") • \(pct)%")
//                                .font(.caption).foregroundColor(.secondary)
//                        }
//                        .padding(.horizontal, 6)
//                    }
//                }
//                .padding(.bottom, 6)
//            }
//            .padding(.horizontal)
//        }
//        .padding(.vertical, 10)
//        .background(.white)
//        .cornerRadius(16)
//        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
//        .padding(.horizontal, 14)
//    }
//}
//
//// MARK: - Wealth Over Time with range control
//private struct WealthOverTimeCard: View {
//    let series: [DashboardView.SeriesPoint]
//    @Binding var range: DashboardView.WealthRange
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            HStack {
//                Text("Wealth Over Time").font(.headline)
//                Spacer()
//                Picker("", selection: $range) {
//                    ForEach(DashboardView.WealthRange.allCases) { r in
//                        Text(r.rawValue).tag(r)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .frame(width: 220)
//            }
//            .padding(.horizontal)
//
//            if series.isEmpty {
//                Text("No portfolio history yet.")
//                    .foregroundColor(.secondary)
//                    .padding(.horizontal)
//                    .padding(.bottom, 8)
//            } else {
//                Chart {
//                    ForEach(series) { p in
//                        LineMark(x: .value("Date", p.date),
//                                 y: .value("Total", p.total))
//                        .interpolationMethod(.catmullRom)
//                        .foregroundStyle(.blue)
//                        .symbol(Circle())
//                    }
//                }
//                .frame(height: 220)
//                .padding(.horizontal, 10)
//            }
//        }
//        .padding(.vertical, 10)
//        .background(.white)
//        .cornerRadius(16)
//        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
//        .padding(.horizontal, 14)
//    }
//}
//
//// MARK: - Trend (Income vs Expense)
//private struct TrendCard: View {
//    let incomeData: [DashboardView.DateAmount]
//    let expenseData: [DashboardView.DateAmount]
//
//    private let expenseColor = Color(red: 0.95, green: 0.35, blue: 0.30)
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Income vs Expense Trend").font(.headline)
//                .foregroundColor(.black).padding(.horizontal)
//
//            Chart {
//                ForEach(incomeData) { item in
//                    LineMark(x: .value("Date", item.date), y: .value("Income", item.amount))
//                        .interpolationMethod(.catmullRom)
//                        .foregroundStyle(.green).symbol(Circle())
//                }
//                ForEach(expenseData) { item in
//                    LineMark(x: .value("Date", item.date), y: .value("Expense", item.amount))
//                        .interpolationMethod(.catmullRom)
//                        .foregroundStyle(expenseColor)
//                        .symbol(Circle())
//                }
//            }
//            .frame(height: 200)
//            .animation(.easeInOut(duration: 0.6), value: incomeData)
//            .animation(.easeInOut(duration: 0.6), value: expenseData)
//            .padding(.horizontal, 10)
//        }
//        .padding(.vertical, 10)
//        .background(.white)
//        .cornerRadius(16)
//        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
//        .padding(.horizontal, 14)
//    }
//}
//
//// MARK: - DTI
//private struct DTICard: View {
//    let debt: Double
//    let income: Double
//
//    var body: some View {
//        let remaining = max(income - debt, 0)
//        let ratio = income > 0 ? (debt / income) * 100 : 0
//
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Debt-to-Income Ratio").font(.headline)
//                .foregroundColor(.black).padding(.horizontal)
//
//            VStack(spacing: 8) {
//                Chart {
//                    SectorMark(angle: .value("Debt", debt), innerRadius: .ratio(0.6)).foregroundStyle(.red)
//                    SectorMark(angle: .value("Remaining", remaining), innerRadius: .ratio(0.6)).foregroundStyle(.green)
//                }
//                .frame(height: 180)
//                .animation(.easeInOut(duration: 0.6), value: debt)
//                .animation(.easeInOut(duration: 0.6), value: income)
//
//                Text("DTI: \(ratio, specifier: "%.1f")%")
//                    .font(.subheadline)
//                    .foregroundColor(ratio > 35 ? .red : .green)
//            }
//            .padding(.horizontal, 10)
//        }
//        .padding(.vertical, 10)
//        .background(.white)
//        .cornerRadius(16)
//        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
//        .padding(.horizontal, 14)
//    }
//}
//
//// MARK: - Summary
//private struct SummaryCard: View {
//    let income: Double
//    let expense: Double
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Summary").font(.headline)
//                .foregroundColor(.black).padding(.horizontal)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Total Income: $\(income, specifier: "%.2f")")
//                Text("Total Expense: $\(expense, specifier: "%.2f")")
//                Text("Net: $\(income - expense, specifier: "%.2f")")
//                    .foregroundColor((income - expense) >= 0 ? .green : .red)
//            }
//            .font(.body)
//            .padding(.horizontal, 10)
//            .padding(.bottom, 6)
//        }
//        .padding(.vertical, 10)
//        .background(.white)
//        .cornerRadius(16)
//        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
//        .padding(.horizontal, 14)
//    }
//}
import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var manager = FirestoreManager()
    @State private var timeRange: WealthRange = .oneMonth
    @State private var showAddSnapshot = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    HeaderAndBarCard(
                        incomeTotal: totalIncome(),
                        expenseTotal: totalExpense()
                    )

                    BudgetProgressCard(
                        goals: manager.goals,
                        expenses: manager.expenses
                    )

                    MonthlyExpensesBarCard(
                        monthly: monthlyExpensesByCategory()
                    )

                    ExpensesByCategoryCard(
                        data: expensesByCategory()
                    )

                    WealthOverTimeCard(
                        series: wealthSeries(range: timeRange),
                        range: $timeRange
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
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSnapshot = true
                    } label: {
                        Label("Add Wealth Snapshot", systemImage: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $showAddSnapshot) {
                AddWealthSnapshotView(manager: manager)
            }
            .onAppear {
                manager.fetchAllExpenses()
                manager.fetchAllIncomes()
                manager.fetchGoals()
                manager.fetchWealthSnapshots()
            }
        }
    }

    // MARK: - Local simple models for charts
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
    struct SeriesPoint: Identifiable, Equatable {
        let id = UUID()
        let date: Date
        let total: Double
    }

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

    // Current month breakdown
    private func monthlyExpensesByCategory() -> [CategoryAmount] {
        let cur = Date()
        let fm = DateFormatter()
        fm.dateFormat = "yyyy-MM"
        let key = fm.string(from: cur)

        var dict: [String: Double] = [:]
        for e in manager.expenses {
            let monthKey = String(e.dateString.prefix(7))
            if monthKey == key {
                dict[e.category, default: 0] += e.amount
            }
        }
        return dict.map { CategoryAmount(category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }

    // MARK: - Wealth Over Time (from snapshots)
    enum WealthRange: String, CaseIterable, Identifiable {
        case oneMonth = "1M", sixMonths = "6M", oneYear = "1Y", fiveYears = "5Y"
        var id: String { rawValue }
        var months: Int {
            switch self {
            case .oneMonth: return 1
            case .sixMonths: return 6
            case .oneYear:   return 12
            case .fiveYears: return 60
            }
        }
    }

    private func wealthSeries(range: WealthRange) -> [SeriesPoint] {
        let all = manager.wealthSnapshots.sorted { $0.date < $1.date }
        guard !all.isEmpty else { return [] }

        let end = Date()
        let start = Calendar.current.date(byAdding: .month, value: -range.months, to: end) ?? end
        let filtered = all.filter { $0.date >= start && $0.date <= end }
        let use = filtered.isEmpty ? all.suffix(1) : filtered

        return use.map { SeriesPoint(date: $0.date, total: $0.total) }
    }
}

// MARK: - Header + Blue Bar Card (slim, centered bars)
private struct HeaderAndBarCard: View {
    let incomeTotal: Double
    let expenseTotal: Double

    private let expenseColor = Color(red: 0.95, green: 0.35, blue: 0.30)
    private var cardHeight: CGFloat { max(260, UIScreen.main.bounds.height * 0.33) }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .resizable().scaledToFill().frame(width: 20, height: 20)
                Spacer()
                Text("Spending")
                    .font(.headline.weight(.semibold))
                    .padding(.trailing, 16)
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.top, 10)
            .padding(.horizontal)

            HStack {
                HStack(spacing: 8) {
                    Text("Monthly").font(.title.bold())
                    Image(systemName: "chevron.down")
                        .resizable().scaledToFill().frame(width: 8, height: 8)
                        .fontWeight(.bold).padding(.top, 4)
                }
                .foregroundStyle(.white)

                Spacer()

                HStack(spacing: 12) {
                    LegendDot(title: "Earned", color: Color.white.opacity(0.95))
                    LegendDot(title: "Spent",  color: expenseColor)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .background(.black.opacity(0.22))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(.horizontal)

            // center slim bars with spacer buckets
            let domain = ["spL1","spL2","Income","spM1","spM2","Expense","spR1","spR2"]
            let bars: [(label: String, value: Double, visible: Bool, color: Color)] = [
                ("spL1", 0, false, .clear),
                ("spL2", 0, false, .clear),
                ("Income", incomeTotal, true, .white),
                ("spM1", 0, false, .clear),
                ("spM2", 0, false, .clear),
                ("Expense", expenseTotal, true, expenseColor),
                ("spR1", 0, false, .clear),
                ("spR2", 0, false, .clear)
            ]

            Chart {
                ForEach(Array(bars.enumerated()), id: \.offset) { _, item in
                    BarMark(
                        x: .value("Type", item.label),
                        y: .value("Amount", item.value)
                    )
                    .clipShape(YTRoundedBar(radius: 8))
                    .foregroundStyle(item.color)
                    .opacity(item.visible ? 1 : 0)
                }
            }
            .chartXScale(domain: domain)
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    if let s = value.as(String.self), s == "Income" || s == "Expense" {
                        AxisGridLine().foregroundStyle(.clear)
                        AxisTick().foregroundStyle(.white)
                        AxisValueLabel().foregroundStyle(.white)
                    } else {
                        AxisGridLine().foregroundStyle(.clear)
                        AxisTick().foregroundStyle(.clear)
                        AxisValueLabel("").foregroundStyle(.clear)
                    }
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
            .frame(height: 150)
            .padding(.horizontal, 10)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background(Color(UIColor.systemBlue))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 14)
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

private struct YTRoundedBar: Shape {
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: radius, height: radius), style: .continuous)
        return path
    }
}

// MARK: - Budget Progress Card
private struct BudgetProgressCard: View {
    let goals: [GoalItem]
    let expenses: [ExpenseItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Budget Progress").font(.headline)
                .foregroundColor(.black).padding(.horizontal)

            if goals.isEmpty {
                Text("No goals set. Add goals in Account → Budget Goals.")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            } else {
                VStack(spacing: 10) {
                    ForEach(goals) { goal in
                        BudgetRow(goal: goal, spent: totalSpent(for: goal.category))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 6)
            }
        }
        .padding(.vertical, 12)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 14)
    }

    private func totalSpent(for category: String) -> Double {
        expenses.filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }
}

private struct BudgetRow: View {
    let goal: GoalItem
    let spent: Double

    private var percent: Double {
        guard goal.limit > 0 else { return 0 }
        let p = spent / goal.limit
        return min(max(p, 0), 2) // clamp 0...200%
    }

    private var barColor: Color {
        if goal.goalType == "under" {
            switch percent {
            case ..<1.0: return .green
            case 1.0..<1.2: return .yellow
            default: return .red
            }
        } else {
            return spent >= goal.limit ? .green : .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(goal.category).font(.subheadline).fontWeight(.semibold)
                Spacer()
                Text(goal.goalType == "over" ? "Target ≥ \(goal.limit, specifier: "%.2f")"
                                             : "Limit ≤ \(goal.limit, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 10)

                    let width = min(max(percent, 0), 1.0) * geo.size.width
                    RoundedRectangle(cornerRadius: 8)
                        .fill(barColor)
                        .frame(width: width, height: 10)
                }
            }
            .frame(height: 10)

            HStack {
                Text("Spent: $\(spent, specifier: "%.2f")")
                Spacer()
                Text("Limit: $\(goal.limit, specifier: "%.2f")")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - Monthly Expenses Breakdown
private struct MonthlyExpensesBarCard: View {
    let monthly: [DashboardView.CategoryAmount]
    private let expenseColor = Color(red: 0.95, green: 0.35, blue: 0.30)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Monthly Expenses Breakdown").font(.headline)
                .foregroundColor(.black).padding(.horizontal)

            if monthly.isEmpty {
                Text("No expenses this month.")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            } else {
                Chart {
                    ForEach(monthly) { item in
                        BarMark(
                            x: .value("Category", item.category),
                            y: .value("Amount", item.amount)
                        )
                        .foregroundStyle(expenseColor)
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { value in
                        AxisGridLine().foregroundStyle(.clear)
                        AxisTick().foregroundStyle(.secondary)
                        AxisValueLabel() {
                            if let s = value.as(String.self) {
                                Text(s).lineLimit(1).minimumScaleFactor(0.7)
                            }
                        }
                    }
                }
                .chartYAxis { AxisMarks(position: .leading) }
                .frame(height: 200)
                .padding(.horizontal, 10)
            }
        }
        .padding(.vertical, 10)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 14)
    }
}

// MARK: - Expenses by Category (Donut + Legend)
private struct ExpensesByCategoryCard: View {
    let data: [DashboardView.CategoryAmount]
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
        VStack(alignment: .leading, spacing: 10) {
            Text("Expenses by Category").font(.headline)
                .foregroundColor(.black).padding(.horizontal)

            let sorted = data.sorted { $0.amount > $1.amount }
            let total = max(sorted.reduce(0) { $0 + $1.amount }, 0.0001)
            let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

            VStack(spacing: 12) {
                Chart {
                    ForEach(Array(sorted.enumerated()), id: \.offset) { idx, item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.7)
                        )
                        .foregroundStyle(palette[idx % palette.count])
                        .cornerRadius(2)
                    }
                }
                .chartLegend(.hidden)
                .frame(height: 200)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(sorted.enumerated()), id: \.offset) { idx, item in
                        HStack(spacing: 8) {
                            Circle().fill(palette[idx % palette.count]).frame(width: 10, height: 10)
                            Text(item.category).font(.subheadline).lineLimit(1).foregroundColor(.primary)
                            Spacer()
                            let pct = Int((item.amount / total) * 100)
                            Text("$\(item.amount, specifier: "%.0f") • \(pct)%")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 6)
                    }
                }
                .padding(.bottom, 6)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 14)
    }
}

// MARK: - Wealth Over Time with range control
private struct WealthOverTimeCard: View {
    let series: [DashboardView.SeriesPoint]
    @Binding var range: DashboardView.WealthRange

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Wealth Over Time").font(.headline)
                Spacer()
                Picker("", selection: $range) {
                    ForEach(DashboardView.WealthRange.allCases) { r in
                        Text(r.rawValue).tag(r)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 220)
            }
            .padding(.horizontal)

            if series.isEmpty {
                Text("No portfolio history yet.")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            } else {
                Chart {
                    ForEach(series) { p in
                        LineMark(x: .value("Date", p.date),
                                 y: .value("Total", p.total))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.blue)
                        .symbol(Circle())
                    }
                }
                .frame(height: 220)
                .padding(.horizontal, 10)
            }
        }
        .padding(.vertical, 10)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 14)
    }
}

// MARK: - Trend (Income vs Expense)
private struct TrendCard: View {
    let incomeData: [DashboardView.DateAmount]
    let expenseData: [DashboardView.DateAmount]
    private let expenseColor = Color(red: 0.95, green: 0.35, blue: 0.30)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
                        .foregroundStyle(expenseColor)
                        .symbol(Circle())
                }
            }
            .frame(height: 200)
            .padding(.horizontal, 10)
        }
        .padding(.vertical, 10)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 14)
    }
}

// MARK: - DTI
private struct DTICard: View {
    let debt: Double
    let income: Double

    var body: some View {
        let remaining = max(income - debt, 0)
        let ratio = income > 0 ? (debt / income) * 100 : 0

        VStack(alignment: .leading, spacing: 10) {
            Text("Debt-to-Income Ratio").font(.headline)
                .foregroundColor(.black).padding(.horizontal)

            VStack(spacing: 8) {
                Chart {
                    SectorMark(angle: .value("Debt", debt), innerRadius: .ratio(0.6)).foregroundStyle(.red)
                    SectorMark(angle: .value("Remaining", remaining), innerRadius: .ratio(0.6)).foregroundStyle(.green)
                }
                .frame(height: 180)

                Text("DTI: \(ratio, specifier: "%.1f")%")
                    .font(.subheadline)
                    .foregroundColor(ratio > 35 ? .red : .green)
            }
            .padding(.horizontal, 10)
        }
        .padding(.vertical, 10)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 14)
    }
}

// MARK: - Summary
private struct SummaryCard: View {
    let income: Double
    let expense: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Summary").font(.headline)
                .foregroundColor(.black).padding(.horizontal)

            VStack(alignment: .leading, spacing: 4) {
                Text("Total Income: $\(income, specifier: "%.2f")")
                Text("Total Expense: $\(expense, specifier: "%.2f")")
                Text("Net: $\(income - expense, specifier: "%.2f")")
                    .foregroundColor((income - expense) >= 0 ? .green : .red)
            }
            .font(.body)
            .padding(.horizontal, 10)
            .padding(.bottom, 6)
        }
        .padding(.vertical, 10)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 14)
    }
}
