//
//  financefriendApp.swift
//  financefriend
//
//  Created by Nidesh Sri on 15/07/25.
//

import SwiftUI
import Firebase

@main
struct FinanceFriendApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}

