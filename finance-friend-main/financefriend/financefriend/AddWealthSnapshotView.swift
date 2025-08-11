//
//  AddWealthSnapshotView.swift
//  financefriend
//
//  Created by Chanikya Ch on 8/11/25.
//

import Foundation
import SwiftUI

struct AddWealthSnapshotView: View {
    @ObservedObject var manager: FirestoreManager
    @Environment(\.dismiss) var dismiss

    @State private var year  = Calendar.current.component(.year, from: Date())
    @State private var month = Calendar.current.component(.month, from: Date())
    @State private var totalString = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Period")) {
                    Stepper("Year: \(year)", value: $year, in: 2000...2100)
                    Stepper("Month: \(month)", value: $month, in: 1...12)
                }

                Section(header: Text("Total Wealth")) {
                    TextField("e.g. 12500.00", text: $totalString)
                        .keyboardType(.decimalPad)
                }

                Section {
                    Button("Save Snapshot") {
                        if let total = Double(totalString) {
                            manager.upsertWealthSnapshot(year: year, month: month, total: total)
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Add Wealth Snapshot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
