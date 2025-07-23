import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    @Published var expenses: [ExpenseItem] = []
    @Published var incomes: [IncomeItem] = []

    // MARK: - Add Expense
    func addExpense(category: String, amount: Double, isLoan: Bool, date: Date) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let expenseData: [String: Any] = [
            "category": category,
            "isLoan": isLoan,
            "paymentAmount": amount,
            "history": [["date": formatDate(date), "amount": amount]]
        ]

        db.collection("users").document(uid).collection("expenses")
            .addDocument(data: expenseData) { error in
                if let error = error {
                    print("Error adding expense: \(error.localizedDescription)")
                }
            }
    }

    // MARK: - Add Income
    func addIncome(source: String, amount: Double, recurrence: String, date: Date) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let incomeData: [String: Any] = [
            "source": source,
            "amount": amount,
            "recurrence": recurrence,
            "date": formatDate(date)
        ]

        db.collection("users").document(uid).collection("incomes")
            .addDocument(data: incomeData) { error in
                if let error = error {
                    print("Error adding income: \(error.localizedDescription)")
                }
            }
    }

    // MARK: - Fetch Expenses
    func fetchAllExpenses() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).collection("expenses")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching expenses: \(error.localizedDescription)")
                    return
                }

                self.expenses = snapshot?.documents.compactMap { doc -> ExpenseItem? in
                    let data = doc.data()
                    let category = data["category"] as? String ?? "Unknown"
                    let amount = data["paymentAmount"] as? Double ?? 0.0
                    let history = data["history"] as? [[String: Any]]
                    let date = history?.first?["date"] as? String ?? ""
                    let isLoan = data["isLoan"] as? Bool ?? false

                    return ExpenseItem(category: category, amount: amount, dateString: date, isLoan: isLoan)
                } ?? []
            }
    }

    // MARK: - Fetch Incomes
    func fetchAllIncomes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).collection("incomes")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching incomes: \(error)")
                    return
                }

                self.incomes = snapshot?.documents.compactMap { doc -> IncomeItem? in
                    let data = doc.data()

                    let source = data["source"] as? String ?? "Unknown"

                    guard let history = data["history"] as? [[String: Any]],
                          let first = history.first else { return nil }

                    let amount = first["amount"] as? Double ?? 0.0
                    let date = first["date"] as? String ?? ""
                    let recurrence = first["recurrence"] as? String ?? "One-Time"

                    return IncomeItem(source: source, amount: amount, dateString: date, recurrence: recurrence)
                } ?? []
            }
    }




    // MARK: - Format Date
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
