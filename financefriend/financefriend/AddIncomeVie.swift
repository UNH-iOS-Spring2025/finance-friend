import SwiftUI

struct AddIncomeView: View {
    @ObservedObject var manager: FirestoreManager
    @Environment(\.presentationMode) var presentationMode

    @State private var source: String = ""
    @State private var amount: String = ""
    @State private var recurrence: String = "One-Time"
    @State private var selectedDate = Date()

    @State private var showConfirmation = false
    @State private var showSuccess = false
    @State private var showError = false

    let recurrenceOptions = ["One-Time", "Weekly", "Monthly", "Annually"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Source")) {
                    TextField("Income source", text: $source)
                }

                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Recurrence")) {
                    Picker("Recurrence", selection: $recurrence) {
                        ForEach(recurrenceOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }

                Section {
                    Button(action: {
                        guard let _ = Double(amount), !source.isEmpty else {
                            showError = true
                            return
                        }
                        showConfirmation = true
                    }) {
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

            // MARK: Alerts
            .alert("Please fill all fields correctly", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            }

            .alert("Confirm Income", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm", role: .none) {
                    if let amt = Double(amount) {
                        manager.addIncome(
                            source: source,
                            amount: amt,
                            recurrence: recurrence,
                            date: selectedDate
                        )
                        showSuccess = true
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to add this income?")
            }

            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}
