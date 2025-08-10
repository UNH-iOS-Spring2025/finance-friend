//
//  AccountView.swift
//  financefriend
//
//  Created by Nidesh Sri on 22/07/25.
//

import SwiftUI
import FirebaseAuth

struct AccountView: View {
    @AppStorage("appTheme") private var appTheme: ThemeOption = .system
    @State private var showLogoutConfirm = false
    @State private var showingShare = false
    @State private var shareItems: [Any] = []
    @StateObject private var manager = FirestoreManager()

    private var userEmail: String {
        Auth.auth().currentUser?.email ?? "Unknown"
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Profile")) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(Color.blue.opacity(0.15))
                                .frame(width: 48, height: 48)
                            Image(systemName: "person.fill")
                                .foregroundColor(.blue)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userEmail)
                                .font(.headline)
                            Text("Signed in")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $appTheme) {
                        ForEach(ThemeOption.allCases, id: \.self) { opt in
                            Text(opt.title).tag(opt)
                        }
                    }
                }

                Section(header: Text("Data")) {
                    Button {
                        exportData()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("Export CSV (Incomes & Expenses)")
                        }
                    }

                    NavigationLink {
                        BudgetGoalsView()
                    } label: {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.green)
                            Text("Budget Goals")
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showLogoutConfirm = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                    }
                }
            }
            .navigationTitle("Account")
            .confirmationDialog("Are you sure you want to log out?",
                                isPresented: $showLogoutConfirm,
                                titleVisibility: .visible) {
                Button("Logout", role: .destructive) { logout() }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingShare) {
                ShareSheet(activityItems: shareItems)
            }
            .onAppear {
                // keep data fresh for export
                manager.fetchAllIncomes()
                manager.fetchAllExpenses()
            }
        }
        // Apply theme just for this screen. To make it global,
        // also read appTheme at the app root and set preferredColorScheme there.
        .preferredColorScheme(appTheme.colorScheme)
    }

    // MARK: - Actions

    private func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    private func exportData() {
        // Build CSVs
        let incomeCSV = buildIncomeCSV(manager.incomes)
        let expenseCSV = buildExpenseCSV(manager.expenses)

        // Write temp files
        let incomeURL = writeTempFile(named: "incomes.csv", contents: incomeCSV)
        let expenseURL = writeTempFile(named: "expenses.csv", contents: expenseCSV)

        var items: [Any] = []
        if let i = incomeURL { items.append(i) }
        if let e = expenseURL { items.append(e) }

        if !items.isEmpty {
            shareItems = items
            showingShare = true
        }
    }

    private func buildIncomeCSV(_ incomes: [IncomeItem]) -> String {
        var rows = ["source,amount,recurrence,date"]
        for i in incomes {
            let source = i.source.replacingOccurrences(of: ",", with: " ")
            rows.append("\(source),\(i.amount),\(i.recurrence),\(i.dateString)")
        }
        return rows.joined(separator: "\n")
    }

    private func buildExpenseCSV(_ expenses: [ExpenseItem]) -> String {
        var rows = ["category,amount,isLoan,date"]
        for e in expenses {
            let category = e.category.replacingOccurrences(of: ",", with: " ")
            rows.append("\(category),\(e.amount),\(e.isLoan),\(e.dateString)")
        }
        return rows.joined(separator: "\n")
    }

    private func writeTempFile(named: String, contents: String) -> URL? {
        let dir = FileManager.default.temporaryDirectory
        let url = dir.appendingPathComponent(named)
        do {
            try contents.data(using: .utf8)?.write(to: url)
            return url
        } catch {
            print("Failed to write \(named): \(error)")
            return nil
        }
    }
}

// MARK: - Theme

enum ThemeOption: String, CaseIterable {
    case system, light, dark

    var title: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

// MARK: - Placeholder Budget Goals Screen

struct BudgetGoalsView: View {
    @StateObject private var manager = FirestoreManager()

    @State private var selectedCategory: String = "Groceries"
    @State private var limit: String = ""
    @State private var goalType: String = "under"
    @State private var showSaved = false
    @State private var showError = false

    // Use the same categories you track in expenses
    private let categories = [
        "Rent", "Groceries", "Utilities", "Subscriptions",
        "Entertainment", "Transportation", "Healthcare",
        "Loan", "Misc"
    ]
    private let goalTypes = ["under", "over"]

    var body: some View {
        Form {
            Section(header: Text("New / Update Goal")) {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)

                TextField("Limit (e.g., 300)", text: $limit)
                    .keyboardType(.decimalPad)

                Picker("Goal Type", selection: $goalType) {
                    ForEach(goalTypes, id: \.self) { Text($0.capitalized).tag($0) }
                }
                .pickerStyle(.segmented)

                Button("Save Goal") {
                    guard let lim = Double(limit) else { showError = true; return }
                    manager.upsertGoal(category: selectedCategory, limit: lim, goalType: goalType)
                    showSaved = true
                    limit = ""
                }
                .buttonStyle(.borderedProminent)
            }

            Section(header: Text("Existing Goals")) {
                if manager.goals.isEmpty {
                    Text("No goals set yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(manager.goals) { g in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(g.category).font(.headline)
                                Text("\(g.goalType == "over" ? "Target ≥" : "Limit ≤") \(g.limit, specifier: "%.2f")")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                manager.deleteGoal(category: g.category)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Budget Goals")
        .onAppear {
            manager.fetchGoals()
        }
        .alert("Saved", isPresented: $showSaved) {
            Button("OK", role: .cancel) {}
        }
        .alert("Please enter a valid limit", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        }
    }
}

   
