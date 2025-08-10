//import Foundation
//import Firebase
//import FirebaseAuth
//import FirebaseFirestore
//
//class FirestoreManager: ObservableObject {
//    static let shared = FirestoreManager()
//    private let db = Firestore.firestore()
//
//    @Published var expenses: [ExpenseItem] = []
//    @Published var incomes: [IncomeItem] = []
//
//    func addExpense(category: String, amount: Double, isLoan: Bool, date: Date) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        let expenseData: [String: Any] = [
//            "category": category,
//            "isLoan": isLoan,
//            "paymentAmount": amount,
//            "history": [["date": formatDate(date), "amount": amount]]
//        ]
//
//        db.collection("users").document(uid).collection("expenses")
//            .addDocument(data: expenseData) { error in
//                if let error = error {
//                    print("Error adding expense: \(error.localizedDescription)")
//                } else {
//                    self.fetchAllExpenses()
//                }
//            }
//    }
//
//    func addIncome(source: String, amount: Double, recurrence: String, date: Date) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        let incomeData: [String: Any] = [
//            "source": source,
//            "history": [["date": formatDate(date), "amount": amount, "recurrence": recurrence]]
//        ]
//
//        db.collection("users").document(uid).collection("incomes")
//            .addDocument(data: incomeData) { error in
//                if let error = error {
//                    print("Error adding income: \(error.localizedDescription)")
//                } else {
//                    self.fetchAllIncomes()
//                }
//            }
//    }
//
//    func fetchAllIncomes() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        db.collection("users").document(uid).collection("incomes")
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("Error fetching incomes: \(error)")
//                    return
//                }
//
//                self.incomes = snapshot?.documents.compactMap { doc -> IncomeItem? in
//                    let data = doc.data()
//                    let source = data["source"] as? String ?? "Unknown"
//
//                    guard let history = data["history"] as? [[String: Any]],
//                          let firstEntry = history.first else {
//                        return nil
//                    }
//
//                    let amount = firstEntry["amount"] as? Double ?? 0.0
//                    let date = firstEntry["date"] as? String ?? ""
//                    let recurrence = firstEntry["recurrence"] as? String ?? "One-Time"
//
//                    return IncomeItem(source: source, amount: amount, dateString: date, recurrence: recurrence)
//                } ?? []
//            }
//    }
//
//
//
//    func fetchAllExpenses() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        db.collection("users").document(uid).collection("expenses")
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("Error fetching expenses: \(error)")
//                    return
//                }
//
//                var allExpenses: [ExpenseItem] = []
//
//                for doc in snapshot?.documents ?? [] {
//                    let data = doc.data()
//                    let category = data["category"] as? String ?? "Unknown"
//                    let isLoan = data["isLoan"] as? Bool ?? false
//                    let history = data["history"] as? [[String: Any]] ?? []
//
//                    for entry in history {
//                        let amount = entry["amount"] as? Double ?? 0.0
//                        let date = entry["date"] as? String ?? "Unknown"
//                        allExpenses.append(ExpenseItem(category: category, amount: amount, dateString: date, isLoan: isLoan))
//                    }
//                }
//
//                self.expenses = allExpenses
//            }
//    }
//
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        return formatter.string(from: date)
//    }
//}
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    @Published var expenses: [ExpenseItem] = []
    @Published var incomes: [IncomeItem] = []
    @Published var goals: [GoalItem] = []

    // MARK: - Expenses

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

    // MARK: - Incomes

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

    // MARK: - Goals

    func fetchGoals() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).collection("goals")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching goals: \(error)")
                    return
                }

                self.goals = snapshot?.documents.compactMap { doc -> GoalItem? in
                    let d = doc.data()
                    guard let category = d["category"] as? String,
                          let limit = d["limit"] as? Double,
                          let goalType = d["goalType"] as? String else { return nil }
                    return GoalItem(id: UUID(), category: category, limit: limit, goalType: goalType)
                } ?? []
            }
    }

    /// Upsert: overwrite if a goal already exists for the same category; otherwise create a new doc.
    func upsertGoal(category: String, limit: Double, goalType: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = db.collection("users").document(uid).collection("goals")

        // Find existing by category
        ref.whereField("category", isEqualTo: category).getDocuments { snap, err in
            if let err = err {
                print("Error checking goal: \(err)")
                return
            }

            let data: [String: Any] = [
                "category": category,
                "limit": limit,
                "goalType": goalType
            ]

            if let doc = snap?.documents.first {
                ref.document(doc.documentID).setData(data, merge: true) { e in
                    if let e = e { print("Update goal error: \(e)") }
                    self.fetchGoals()
                }
            } else {
                ref.addDocument(data: data) { e in
                    if let e = e { print("Add goal error: \(e)") }
                    self.fetchGoals()
                }
            }
        }
    }

    func deleteGoal(category: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = db.collection("users").document(uid).collection("goals")
        ref.whereField("category", isEqualTo: category).getDocuments { snap, err in
            if let err = err {
                print("Delete query error: \(err)")
                return
            }
            snap?.documents.forEach { doc in
                ref.document(doc.documentID).delete { e in
                    if let e = e { print("Delete goal error: \(e)") }
                    self.fetchGoals()
                }
            }
        }
    }

    // MARK: - Util

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
