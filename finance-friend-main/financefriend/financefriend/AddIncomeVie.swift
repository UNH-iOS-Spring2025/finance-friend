import SwiftUI

struct AddIncomeView: View {
    @ObservedObject var manager: FirestoreManager
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedCategory: String = "Salary"
    @State private var customSource: String = ""
    @State private var amount: String = ""
    @State private var recurrence: String = "One-Time"
    @State private var selectedDate = Date()

    @State private var showConfirmation = false
    @State private var showSuccess = false
    @State private var showError = false

    private let incomeCategories = [
        "Salary", "Freelance", "Business", "Investment",
        "Gift", "Allowance", "Bonus", "Other"
    ]

    private let recurrenceOptions = ["One-Time", "Weekly", "Monthly", "Annually"]

    var body: some View {
        NavigationView {
            Form {
                // Source (dropdown)
                Section(header: Text("Source")) {
                    Picker("Select Source", selection: $selectedCategory) {
                        ForEach(incomeCategories, id: \.self) { s in
                            Text(s).tag(s)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    if selectedCategory == "Other" {
                        TextField("Custom source", text: $customSource)
                    }
                }

                // Amount
                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                }

                // Recurrence
                Section(header: Text("Recurrence")) {
                    Picker("Recurrence", selection: $recurrence) {
                        ForEach(recurrenceOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Date
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }

                // Save
                Section {
                    Button {
                        guard let _ = Double(amount) else { showError = true; return }
                        if selectedCategory == "Other", customSource.trimmingCharacters(in: .whitespaces).isEmpty {
                            showError = true; return
                        }
                        showConfirmation = true
                    } label: {
                        Text("Add Income")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Add Income")
            .navigationBarTitleDisplayMode(.inline)

            // Alerts
            .alert("Please fill all fields correctly", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            }

            .alert("Confirm Income", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm") {
                    if let amt = Double(amount) {
                        let finalSource = selectedCategory == "Other"
                            ? customSource.trimmingCharacters(in: .whitespaces)
                            : selectedCategory

                        manager.addIncome(
                            source: finalSource,
                            amount: amt,
                            recurrence: recurrence,
                            date: selectedDate
                        )
                        showSuccess = true
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text("Add this income to your tracker?")
            }

            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}
