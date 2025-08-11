////import Foundation
////import Firebase
////import FirebaseAuth
////import FirebaseFirestore
////
////class FirestoreManager: ObservableObject {
////    static let shared = FirestoreManager()
////    private let db = Firestore.firestore()
////
////    @Published var expenses: [ExpenseItem] = []
////    @Published var incomes: [IncomeItem] = []
////
////    func addExpense(category: String, amount: Double, isLoan: Bool, date: Date) {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////
////        let expenseData: [String: Any] = [
////            "category": category,
////            "isLoan": isLoan,
////            "paymentAmount": amount,
////            "history": [["date": formatDate(date), "amount": amount]]
////        ]
////
////        db.collection("users").document(uid).collection("expenses")
////            .addDocument(data: expenseData) { error in
////                if let error = error {
////                    print("Error adding expense: \(error.localizedDescription)")
////                } else {
////                    self.fetchAllExpenses()
////                }
////            }
////    }
////
////    func addIncome(source: String, amount: Double, recurrence: String, date: Date) {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////
////        let incomeData: [String: Any] = [
////            "source": source,
////            "history": [["date": formatDate(date), "amount": amount, "recurrence": recurrence]]
////        ]
////
////        db.collection("users").document(uid).collection("incomes")
////            .addDocument(data: incomeData) { error in
////                if let error = error {
////                    print("Error adding income: \(error.localizedDescription)")
////                } else {
////                    self.fetchAllIncomes()
////                }
////            }
////    }
////
////    func fetchAllIncomes() {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////
////        db.collection("users").document(uid).collection("incomes")
////            .getDocuments { snapshot, error in
////                if let error = error {
////                    print("Error fetching incomes: \(error)")
////                    return
////                }
////
////                self.incomes = snapshot?.documents.compactMap { doc -> IncomeItem? in
////                    let data = doc.data()
////                    let source = data["source"] as? String ?? "Unknown"
////
////                    guard let history = data["history"] as? [[String: Any]],
////                          let firstEntry = history.first else {
////                        return nil
////                    }
////
////                    let amount = firstEntry["amount"] as? Double ?? 0.0
////                    let date = firstEntry["date"] as? String ?? ""
////                    let recurrence = firstEntry["recurrence"] as? String ?? "One-Time"
////
////                    return IncomeItem(source: source, amount: amount, dateString: date, recurrence: recurrence)
////                } ?? []
////            }
////    }
////
////
////
////    func fetchAllExpenses() {
////        guard let uid = Auth.auth().currentUser?.uid else { return }
////
////        db.collection("users").document(uid).collection("expenses")
////            .getDocuments { snapshot, error in
////                if let error = error {
////                    print("Error fetching expenses: \(error)")
////                    return
////                }
////
////                var allExpenses: [ExpenseItem] = []
////
////                for doc in snapshot?.documents ?? [] {
////                    let data = doc.data()
////                    let category = data["category"] as? String ?? "Unknown"
////                    let isLoan = data["isLoan"] as? Bool ?? false
////                    let history = data["history"] as? [[String: Any]] ?? []
////
////                    for entry in history {
////                        let amount = entry["amount"] as? Double ?? 0.0
////                        let date = entry["date"] as? String ?? "Unknown"
////                        allExpenses.append(ExpenseItem(category: category, amount: amount, dateString: date, isLoan: isLoan))
////                    }
////                }
////
////                self.expenses = allExpenses
////            }
////    }
////
////    private func formatDate(_ date: Date) -> String {
////        let formatter = DateFormatter()
////        formatter.dateFormat = "yyyy-MM-dd"
////        return formatter.string(from: date)
////    }
////}
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
//    @Published var goals: [GoalItem] = []
//
//    // MARK: - Expenses
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
//    // MARK: - Incomes
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
//    // MARK: - Goals
//
//    func fetchGoals() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        db.collection("users").document(uid).collection("goals")
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("Error fetching goals: \(error)")
//                    return
//                }
//
//                self.goals = snapshot?.documents.compactMap { doc -> GoalItem? in
//                    let d = doc.data()
//                    guard let category = d["category"] as? String,
//                          let limit = d["limit"] as? Double,
//                          let goalType = d["goalType"] as? String else { return nil }
//                    return GoalItem(id: UUID(), category: category, limit: limit, goalType: goalType)
//                } ?? []
//            }
//    }
//
//    /// Upsert: overwrite if a goal already exists for the same category; otherwise create a new doc.
//    func upsertGoal(category: String, limit: Double, goalType: String) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let ref = db.collection("users").document(uid).collection("goals")
//
//        // Find existing by category
//        ref.whereField("category", isEqualTo: category).getDocuments { snap, err in
//            if let err = err {
//                print("Error checking goal: \(err)")
//                return
//            }
//
//            let data: [String: Any] = [
//                "category": category,
//                "limit": limit,
//                "goalType": goalType
//            ]
//
//            if let doc = snap?.documents.first {
//                ref.document(doc.documentID).setData(data, merge: true) { e in
//                    if let e = e { print("Update goal error: \(e)") }
//                    self.fetchGoals()
//                }
//            } else {
//                ref.addDocument(data: data) { e in
//                    if let e = e { print("Add goal error: \(e)") }
//                    self.fetchGoals()
//                }
//            }
//        }
//    }
//
//    func deleteGoal(category: String) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let ref = db.collection("users").document(uid).collection("goals")
//        ref.whereField("category", isEqualTo: category).getDocuments { snap, err in
//            if let err = err {
//                print("Delete query error: \(err)")
//                return
//            }
//            snap?.documents.forEach { doc in
//                ref.document(doc.documentID).delete { e in
//                    if let e = e { print("Delete goal error: \(e)") }
//                    self.fetchGoals()
//                }
//            }
//        }
//    }
//
//    // MARK: - Util
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

final class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    // MARK: - Published data
    @Published var expenses: [ExpenseItem] = []
    @Published var incomes: [IncomeItem] = []
    @Published var goals: [GoalItem] = []
    @Published var accounts: [PortfolioItem] = []
    @Published var wealthSnapshots: [WealthSnapshot] = []

    // MARK: - Helpers
    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private func formatDate(_ date: Date) -> String {
        dayFormatter.string(from: date)
    }

    private func requireUID() -> String? {
        Auth.auth().currentUser?.uid
    }

    // MARK: - EXPENSES
    func addExpense(category: String, amount: Double, isLoan: Bool, date: Date) {
        guard let uid = requireUID() else { return }
        let data: [String: Any] = [
            "category": category,
            "isLoan": isLoan,
            "paymentAmount": amount,
            "history": [["date": formatDate(date), "amount": amount]]
        ]
        db.collection("users").document(uid).collection("expenses")
            .addDocument(data: data) { [weak self] err in
                if let err = err { print("addExpense error:", err.localizedDescription) }
                self?.fetchAllExpenses()
            }
    }

    func fetchAllExpenses() {
        guard let uid = requireUID() else { return }
        db.collection("users").document(uid).collection("expenses")
            .getDocuments { [weak self] snap, err in
                guard let self else { return }
                if let err = err { print("fetchAllExpenses error:", err); return }

                var list: [ExpenseItem] = []
                for doc in snap?.documents ?? [] {
                    let d = doc.data()
                    let category = d["category"] as? String ?? "Unknown"
                    let isLoan = d["isLoan"] as? Bool ?? false
                    let history = d["history"] as? [[String: Any]] ?? []
                    for h in history {
                        let amount = h["amount"] as? Double ?? 0.0
                        let date = h["date"] as? String ?? ""
                        list.append(ExpenseItem(category: category, amount: amount, dateString: date, isLoan: isLoan))
                    }
                }

                DispatchQueue.main.async { self.expenses = list }
            }
    }

    // MARK: - INCOMES
    func addIncome(source: String, amount: Double, recurrence: String, date: Date) {
        guard let uid = requireUID() else { return }
        let data: [String: Any] = [
            "source": source,
            "history": [["date": formatDate(date), "amount": amount, "recurrence": recurrence]]
        ]
        db.collection("users").document(uid).collection("incomes")
            .addDocument(data: data) { [weak self] err in
                if let err = err { print("addIncome error:", err.localizedDescription) }
                self?.fetchAllIncomes()
            }
    }

    func fetchAllIncomes() {
        guard let uid = requireUID() else { return }
        db.collection("users").document(uid).collection("incomes")
            .getDocuments { [weak self] snap, err in
                guard let self else { return }
                if let err = err { print("fetchAllIncomes error:", err); return }

                let items: [IncomeItem] = (snap?.documents ?? []).compactMap { doc in
                    let d = doc.data()
                    let source = d["source"] as? String ?? "Unknown"
                    guard let history = d["history"] as? [[String: Any]],
                          let first = history.first else { return nil }
                    let amount = first["amount"] as? Double ?? 0.0
                    let date = first["date"] as? String ?? ""
                    let recurrence = first["recurrence"] as? String ?? "One-Time"
                    return IncomeItem(source: source, amount: amount, dateString: date, recurrence: recurrence)
                }

                DispatchQueue.main.async { self.incomes = items }
            }
    }

    // MARK: - GOALS
    func fetchGoals() {
        guard let uid = requireUID() else { return }
        db.collection("users").document(uid).collection("goals")
            .getDocuments { [weak self] snap, err in
                guard let self else { return }
                if let err = err { print("fetchGoals error:", err); return }

                let items: [GoalItem] = (snap?.documents ?? []).compactMap { doc in
                    let d = doc.data()
                    guard let category = d["category"] as? String,
                          let limit = d["limit"] as? Double,
                          let goalType = d["goalType"] as? String else { return nil }
                    return GoalItem(id: UUID(), category: category, limit: limit, goalType: goalType)
                }

                DispatchQueue.main.async { self.goals = items }
            }
    }

    func upsertGoal(category: String, limit: Double, goalType: String) {
        guard let uid = requireUID() else { return }
        let col = db.collection("users").document(uid).collection("goals")
        let data: [String: Any] = ["category": category, "limit": limit, "goalType": goalType]

        col.whereField("category", isEqualTo: category).getDocuments { [weak self] snap, err in
            guard let self else { return }
            if let err = err { print("upsertGoal query error:", err); return }

            if let doc = snap?.documents.first {
                col.document(doc.documentID).setData(data, merge: true) { e in
                    if let e = e { print("upsertGoal update error:", e) }
                    self.fetchGoals()
                }
            } else {
                col.addDocument(data: data) { e in
                    if let e = e { print("upsertGoal add error:", e) }
                    self.fetchGoals()
                }
            }
        }
    }

    func deleteGoal(category: String) {
        guard let uid = requireUID() else { return }
        let col = db.collection("users").document(uid).collection("goals")
        col.whereField("category", isEqualTo: category).getDocuments { [weak self] snap, err in
            guard let self else { return }
            if let err = err { print("deleteGoal query error:", err); return }

            for doc in snap?.documents ?? [] {
                col.document(doc.documentID).delete { e in
                    if let e = e { print("deleteGoal error:", e) }
                    self.fetchGoals()
                }
            }
        }
    }

    // MARK: - ACCOUNTS / PORTFOLIO
    func fetchAccounts() {
        guard let uid = requireUID() else { return }
        db.collection("users").document(uid).collection("accounts")
            .order(by: "createdAt", descending: false)
            .getDocuments { [weak self] snap, err in
                guard let self else { return }
                if let err = err { print("fetchAccounts error:", err); return }

                var items: [PortfolioItem] = []
                for doc in snap?.documents ?? [] {
                    let d = doc.data()
                    let id = doc.documentID
                    let name = d["name"] as? String ?? "Account"
                    let type = d["type"] as? String ?? "other"
                    let balance = d["balance"] as? Double ?? 0.0
                    let createdAtTS = d["createdAt"] as? Timestamp
                    let createdAt = createdAtTS != nil ? self.formatDate(createdAtTS!.dateValue()) : self.formatDate(Date())

                    var hist: [PortfolioItem.HistoryPoint] = []
                    if let arr = d["history"] as? [[String: Any]] {
                        for e in arr {
                            let date = (e["date"] as? String) ?? ""
                            let amount = (e["amount"] as? Double) ?? 0.0
                            hist.append(.init(date: date, amount: amount))
                        }
                    }

                    items.append(PortfolioItem(id: id, name: name, type: type, balance: balance, createdAt: createdAt, history: hist))
                }

                DispatchQueue.main.async { self.accounts = items }
            }
    }

    func addAccount(name: String, type: String, balance: Double, date: Date = Date()) {
        guard let uid = requireUID() else { return }
        let data: [String: Any] = [
            "name": name,
            "type": type,
            "balance": balance,
            "createdAt": Timestamp(date: date),
            "history": [["date": formatDate(date), "amount": balance]]
        ]
        db.collection("users").document(uid).collection("accounts")
            .addDocument(data: data) { [weak self] err in
                if let err = err { print("addAccount error:", err); return }
                self?.fetchAccounts()
            }
    }

    func updateAccountBalance(accountId: String, newBalance: Double, date: Date = Date()) {
        guard let uid = requireUID() else { return }
        let ref = db.collection("users").document(uid).collection("accounts").document(accountId)
        ref.updateData(["balance": newBalance]) { [weak self] err in
            if let err = err { print("updateAccountBalance error:", err); return }
            self?.appendAccountHistory(accountId: accountId, amount: newBalance, date: date)
        }
    }

    func appendAccountHistory(accountId: String, amount: Double, date: Date = Date()) {
        guard let uid = requireUID() else { return }
        let ref = db.collection("users").document(uid).collection("accounts").document(accountId)
        ref.updateData([
            "history": FieldValue.arrayUnion([["date": formatDate(date), "amount": amount]])
        ]) { [weak self] err in
            if let err = err { print("appendAccountHistory error:", err) }
            self?.fetchAccounts()
        }
    }

    // MARK: - WEALTH SNAPSHOTS (optional feature)
    func fetchWealthSnapshots() {
        guard let uid = requireUID() else { return }
        db.collection("users").document(uid).collection("wealthSnapshots")
            .order(by: "dateString", descending: false)
            .getDocuments { [weak self] snap, err in
                guard let self else { return }
                if let err = err { print("fetchWealthSnapshots error:", err); return }

                let items: [WealthSnapshot] = (snap?.documents ?? []).compactMap { doc in
                    let d = doc.data()
                    guard let year = d["year"] as? Int,
                          let month = d["month"] as? Int,
                          let total = d["total"] as? Double,
                          let dateString = d["dateString"] as? String else { return nil }
                    return WealthSnapshot(year: year, month: month, total: total, dateString: dateString)
                }

                DispatchQueue.main.async { self.wealthSnapshots = items }
            }
    }

    func upsertWealthSnapshot(year: Int, month: Int, total: Double) {
        guard let uid = requireUID() else { return }
        // store last day of that month for plotting
        var comps = DateComponents()
        comps.year = year
        comps.month = month + 1
        comps.day = 0 // day 0 of next month = last day of target month
        let date = Calendar.current.date(from: comps) ?? Date()
        let dateString = formatDate(date)

        let col = db.collection("users").document(uid).collection("wealthSnapshots")
        col.whereField("year", isEqualTo: year)
            .whereField("month", isEqualTo: month)
            .getDocuments { [weak self] snap, err in
                guard let self else { return }
                if let err = err { print("upsertWealthSnapshot query error:", err); return }

                let payload: [String: Any] = [
                    "year": year,
                    "month": month,
                    "total": total,
                    "dateString": dateString
                ]

                if let doc = snap?.documents.first {
                    col.document(doc.documentID).setData(payload, merge: true) { e in
                        if let e = e { print("update wealthSnapshot error:", e) }
                        self.fetchWealthSnapshots()
                    }
                } else {
                    col.addDocument(data: payload) { e in
                        if let e = e { print("add wealthSnapshot error:", e) }
                        self.fetchWealthSnapshots()
                    }
                }
            }
    }

    func deleteWealthSnapshot(year: Int, month: Int) {
        guard let uid = requireUID() else { return }
        let col = db.collection("users").document(uid).collection("wealthSnapshots")
        col.whereField("year", isEqualTo: year)
            .whereField("month", isEqualTo: month)
            .getDocuments { [weak self] snap, err in
                guard let self else { return }
                if let err = err { print("deleteWealthSnapshot query error:", err); return }
                for doc in snap?.documents ?? [] {
                    col.document(doc.documentID).delete { e in
                        if let e = e { print("delete wealthSnapshot error:", e) }
                        self.fetchWealthSnapshots()
                    }
                }
            }
    }
}



