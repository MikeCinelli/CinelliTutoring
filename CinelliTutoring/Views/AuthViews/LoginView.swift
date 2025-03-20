//
//  LoginView.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/11/25.
//

import SwiftUI
import Foundation

/// A view that allows users to log in to the CinelliTutoring app.
struct LoginView: View {
    
    @State private var email: String = "" // Holds the user's email input
    @State private var password: String = "" // Holds the user's password input
    @State private var isLoading: Bool = false // Tracks if a login request is in progress
    @State private var errorMessage: String? // Stores authentication error messages
    
    @EnvironmentObject var authViewModel: UserAuthViewModel // ViewModel for authentication
    
    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
                .bold()
                .padding()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: {
                Task {
                    isLoading = true
                    await authViewModel.login(email: email, password: password)
                    isLoading = false
                    errorMessage = authViewModel.authError
                }
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            
            NavigationLink("Forgot Password?", destination: ForgotPasswordView())
                .padding()
            
            NavigationLink("Don't have an account? Sign Up", destination: SignupView())
                .padding()
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(UserAuthViewModel())
    }
}
