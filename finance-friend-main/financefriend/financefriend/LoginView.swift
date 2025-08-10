import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggedIn = false
    @State private var showingForgotPassword = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Login").font(.largeTitle).bold()

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundColor(.red)
                }

                Button("Login") {
                    FirebaseManager.shared.login(email: email, password: password) { result in
                        switch result {
                        case .success:
                            isLoggedIn = true
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Forgot Password?") {
                    showingForgotPassword = true
                }
                .sheet(isPresented: $showingForgotPassword) {
                    ForgotPasswordView()
                }

                NavigationLink("Don't have an account? Sign Up", destination: SignupView())
            }
            .padding()
            .fullScreenCover(isPresented: $isLoggedIn) {
                MainTabView()  // <-- show the tab view containing dashboard, tracker, accounts
            }

            }
        }
    }

