////
////  AccountView.swift
////  financefriend
////
////  Created by Nidesh Sri on 22/07/25.
////
//
//import SwiftUI
//import FirebaseAuth
//
//struct AccountView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Text("Account Settings")
//                    .font(.title)
//                    .bold()
//
//                // Add other account info here if needed
//
//                Spacer()
//
//                Button(action: {
//                    logout()
//                }) {
//                    Text("Logout")
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.red)
//                        .cornerRadius(10)
//                }
//                .padding(.horizontal)
//            }
//            .padding()
//            .navigationTitle("Account")
//        }
//    }
//
//    func logout() {
//        do {
//            try Auth.auth().signOut()
//            isLoggedIn = false
//        } catch {
//            print("Error signing out: \(error.localizedDescription)")
//        }
//    }
//}
