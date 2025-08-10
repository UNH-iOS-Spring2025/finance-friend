//
//  SignupView.swift
//  financefriend
//
//  Created by Nidesh Sri on 22/07/25.
//

import Foundation
import SwiftUI

struct SignupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isSignedUp = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up").font(.largeTitle).bold()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            }

            Button("Create Account") {
                FirebaseManager.shared.signUp(email: email, password: password) { result in
                    switch result {
                    case .success:
                        isSignedUp = true
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Already have an account? Login") {
                dismiss()
            }

            NavigationLink("", destination: TrackerView(), isActive: $isSignedUp)
        }
        .padding()
    }
}
