//
//  AddAssetView.swift
//  financefriend
//
//  Created by Chanikya Ch on 8/10/25.
//

import Foundation
import SwiftUI

struct AddAssetView: View {
    @ObservedObject var manager: FirestoreManager
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var type: String = "stock"
    @State private var balance: String = ""
    @State private var date = Date()

    @State private var showError = false

    private let types = ["stock","bond","crypto","cash","other"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Asset")) {
                    TextField("Name (e.g., Apple, Savings)", text: $name)
                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.self) { Text($0.capitalized).tag($0) }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("Balance")) {
                    TextField("Amount", text: $balance)
                        .keyboardType(.decimalPad)
                    DatePicker("As of", selection: $date, displayedComponents: .date)
                }

                Section {
                    Button("Save Asset") {
                        guard let amt = Double(balance), !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                            showError = true; return
                        }
                        manager.addAccount(name: name, type: type, balance: amt, date: date)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Add Asset")
            .alert("Please fill valid values", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}
