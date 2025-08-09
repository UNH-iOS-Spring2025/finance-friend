import SwiftUI

struct TrackerView: View {
    @State private var showAddExpense = false
    @State private var showAddIncome = false
    @StateObject private var manager = FirestoreManager()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Tracker")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)

                    GroupBox(label: Text("Incomes").font(.headline)) {
                        if manager.incomes.isEmpty {
                            Text("No incomes added.")
                                .foregroundColor(.gray)
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(manager.incomes) { income in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(income.source)
                                                .font(.headline)
                                            Text("\(income.recurrence) • \(income.dateFormatted)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text("$\(income.amount, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                    }
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    GroupBox(label: Text("Expenses").font(.headline)) {
                        if manager.expenses.isEmpty {
                            Text("No expenses added.")
                                .foregroundColor(.gray)
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(manager.expenses) { expense in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(expense.category)
                                                .font(.headline)
                                            Text(expense.dateFormatted)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text("$\(expense.amount, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(expense.isLoan ? .red : .primary)
                                    }
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    HStack(spacing: 16) {
                        Button(action: { showAddIncome = true }) {
                            Text("Add Income")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                        }

                        Button(action: { showAddExpense = true }) {
                            Text("Add Expense")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView(manager: manager)
            }
            .sheet(isPresented: $showAddIncome) {
                AddIncomeView(manager: manager)
            }
            .onAppear {
                manager.fetchAllExpenses()
                manager.fetchAllIncomes()
            }
        }
    }
}
