//
//  MainTabView.swift
//  financefriend
//
//  Created by Nidesh Sri on 22/07/25.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }

            TrackerView()
                .tabItem {
                    Label("Tracker", systemImage: "list.bullet.rectangle")
                }

            AccountView()  // Use AccountsView, not AccountView
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
        }
    }
}

