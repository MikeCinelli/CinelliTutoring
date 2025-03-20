//
//  signupview.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/11/25.
//

import Foundation
import SwiftUI

/// A view that allows users to sign up for the CinelliTutoring app.
struct SignupView: View {
    
    @State private var email: String = "" // Holds the user's email input
    @State private var password: String = "" // Holds the user's password input
    @State private var confirmPassword: String = "" // Holds confirmation of the password
    @State private var isLoading: Bool = false // Tracks if a sign-up request is in progress
    @State private var errorMessage: String? // Stores authentication error messages
    
    @EnvironmentObject var authViewModel: UserAuthViewModel // ViewModel for authentication
    
    var body: some View {
        VStack {
            Text("Sign Up")
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
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: {
                guard password == confirmPassword else {
                    errorMessage = "Passwords do not match"
                    return
                }
                Task {
                    isLoading = true
                    await authViewModel.signUp(email: email, password: password)
                    isLoading = false
                    errorMessage = authViewModel.authError
                }
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
            .padding()
            
            NavigationLink("Already have an account? Login", destination: LoginView())
                .padding()
        }
        .padding()
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView().environmentObject(UserAuthViewModel())
    }
}
