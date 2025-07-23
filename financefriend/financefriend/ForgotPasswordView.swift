//
//  ForgotPasswordView.swift
//  financefriend
//
//  Created by Nidesh Sri on 22/07/25.
//

import Foundation
import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var message = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Password").font(.title2)

            TextField("Enter your email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Send Reset Link") {
                FirebaseManager.shared.resetPassword(email: email) { result in
                    switch result {
                    case .success:
                        message = "Password reset email sent."
                    case .failure(let error):
                        message = error.localizedDescription
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            if !message.isEmpty {
                Text(message).foregroundColor(.blue)
            }

            Button("Back to Login") {
                dismiss()
            }
        }
        .padding()
    }
}
