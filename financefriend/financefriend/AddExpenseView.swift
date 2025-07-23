import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var manager: FirestoreManager
    @Environment(\.presentationMode) var presentationMode

    @State private var category: String = ""
    @State private var amount: String = ""
    @State private var isLoan: Bool = false
    @State private var selectedDate = Date()
    @State private var showSuccess = false
    @State private var showError = false

    let expenseCategories = ["Rent", "Groceries", "Utilities", "Subscriptions", "Entertainment", "Loan", "Misc"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category")) {
                    Picker("Select Category", selection: $category) {
                        ForEach(expenseCategories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                }

                Section {
                    Toggle("Is this a loan?", isOn: $isLoan)
                }

                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }

                Section {
                    Button(action: {
                        guard let amt = Double(amount), !category.isEmpty else {
                            showError = true
                            return
                        }

                        manager.addExpense(
                            category: category,
                            amount: amt,
                            isLoan: isLoan,
                            date: selectedDate
                        )
                        showSuccess = true
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Add Expense")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {}
            }
            .alert("Please fill all fields correctly", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}
