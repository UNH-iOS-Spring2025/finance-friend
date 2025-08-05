import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    @Published var expenses: [ExpenseItem] = []
    @Published var incomes: [IncomeItem] = []

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
                } else {
                    self.fetchAllExpenses()
                }
            }
    }

    func addIncome(source: String, amount: Double, recurrence: String, date: Date) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let incomeData: [String: Any] = [
            "source": source,
            "history": [["date": formatDate(date), "amount": amount, "recurrence": recurrence]]
        ]

        db.collection("users").document(uid).collection("incomes")
            .addDocument(data: incomeData) { error in
                if let error = error {
                    print("Error adding income: \(error.localizedDescription)")
                } else {
                    self.fetchAllIncomes()
                }
            }
    }

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
                          let firstEntry = history.first else {
                        return nil
                    }

                    let amount = firstEntry["amount"] as? Double ?? 0.0
                    let date = firstEntry["date"] as? String ?? ""
                    let recurrence = firstEntry["recurrence"] as? String ?? "One-Time"

                    return IncomeItem(source: source, amount: amount, dateString: date, recurrence: recurrence)
                } ?? []
            }
    }



    func fetchAllExpenses() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).collection("expenses")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching expenses: \(error)")
                    return
                }

                var allExpenses: [ExpenseItem] = []

                for doc in snapshot?.documents ?? [] {
                    let data = doc.data()
                    let category = data["category"] as? String ?? "Unknown"
                    let isLoan = data["isLoan"] as? Bool ?? false
                    let history = data["history"] as? [[String: Any]] ?? []

                    for entry in history {
                        let amount = entry["amount"] as? Double ?? 0.0
                        let date = entry["date"] as? String ?? "Unknown"
                        allExpenses.append(ExpenseItem(category: category, amount: amount, dateString: date, isLoan: isLoan))
                    }
                }

                self.expenses = allExpenses
            }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
