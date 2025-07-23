import SwiftUI

struct AddIncomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var source = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var recurrence = "One-Time"

    @ObservedObject var manager: FirestoreManager

    let recurrenceOptions = ["One-Time", "Daily", "Weekly", "Monthly", "Yearly"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Income Details")) {
                    TextField("Source", text: $source)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)

                    Picker("Recurrence", selection: $recurrence) {
                        ForEach(recurrenceOptions, id: \.self) {
                            Text($0)
                        }
                    }

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Button("Save") {
                    guard let amt = Double(amount) else { return }
                    manager.addIncome(source: source, amount: amt, recurrence: recurrence, date: date)
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.blue)
            }
            .navigationTitle("Add Income")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
