import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var manager: FirestoreManager
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedCategory: String = "Groceries"
    @State private var customCategory: String = ""
    @State private var amount: String = ""
    @State private var isLoan: Bool = false
    @State private var selectedDate = Date()

    @State private var showError = false
    @State private var showConfirmation = false
    @State private var showSuccess = false

    // Edit this list if you want different categories
    private let expenseCategories = [
        "Rent", "Groceries", "Utilities", "Subscriptions",
        "Entertainment", "Transportation", "Healthcare",
        "Loan", "Misc", "Other"
    ]

    var body: some View {
        NavigationView {
            Form {
                // Category
                Section(header: Text("Category")) {
                    Picker("Select Category", selection: $selectedCategory) {
                        ForEach(expenseCategories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    if selectedCategory == "Other" {
                        TextField("Custom category", text: $customCategory)
                    }
                }

                // Amount
                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                }

                // Loan?
                Section {
                    Toggle("Is this a loan?", isOn: $isLoan)
                }

                // Date
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }

                // Save
                Section {
                    Button {
                        guard let _ = Double(amount) else { showError = true; return }
                        if selectedCategory == "Other", customCategory.trimmingCharacters(in: .whitespaces).isEmpty {
                            showError = true; return
                        }
                        showConfirmation = true
                    } label: {
                        Text("Add Expense")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)

            // Alerts
            .alert("Please fill all fields correctly", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            }

            .alert("Confirm Expense", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm") {
                    if let amt = Double(amount) {
                        let finalCategory = selectedCategory == "Other"
                            ? customCategory.trimmingCharacters(in: .whitespaces)
                            : selectedCategory

                        manager.addExpense(
                            category: finalCategory,
                            amount: amt,
                            isLoan: isLoan,
                            date: selectedDate
                        )
                        showSuccess = true
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text("Add this expense to your tracker?")
            }

            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}
