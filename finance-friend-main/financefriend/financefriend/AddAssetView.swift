import SwiftUI

struct AddAssetView: View {
    @ObservedObject var manager: FirestoreManager
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var type: String = "bank"
    @State private var balanceText: String = ""
    @State private var selectedDate: Date = Date()

    @State private var showError = false
    @State private var showConfirm = false

    private let types = ["bank", "credit", "cash", "stock", "bond", "crypto", "real estate", "other"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    TextField("Name (e.g. Checking, Robinhood)", text: $name)

                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.self) { t in
                            Text(t.capitalized).tag(t)
                        }
                    }
                }

                Section(header: Text("Balance")) {
                    TextField("e.g. 1200.50", text: $balanceText)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("As of Date")) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }

                Section {
                    Button {
                        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
                              Double(balanceText) != nil else {
                            showError = true
                            return
                        }
                        showConfirm = true
                    } label: {
                        Text("Save Asset")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Add Asset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Invalid Input", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a name and a valid balance.")
            }
            .alert("Confirm Asset", isPresented: $showConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Add") {
                    if let balance = Double(balanceText) {
                        // NOTE: matches FirestoreManager signature:
                        // func addAccount(name:type:balance:date:)
                        manager.addAccount(name: name, type: type, balance: balance, date: selectedDate)
                        dismiss()
                    }
                }
            } message: {
                Text("Add \(name) (\(type.capitalized)) with balance $\(balanceText)?")
            }
        }
    }
}
