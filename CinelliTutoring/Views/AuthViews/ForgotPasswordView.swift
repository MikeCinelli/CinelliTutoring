//
//  forgotpasswordview.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/11/25.
//

import Foundation
import SwiftUI

/// A view that allows users to reset their password in the CinelliTutoring app.
struct ForgotPasswordView: View {
    
    @State private var email: String = "" // Holds the user's email input
    @State private var isLoading: Bool = false // Tracks if a password reset request is in progress
    @State private var successMessage: String? // Stores success message
    @State private var errorMessage: String? // Stores error messages
    
    @EnvironmentObject var authViewModel: UserAuthViewModel // ViewModel for authentication
    
    var body: some View {
        VStack {
            Text("Forgot Password")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Text("Enter your email and we'll send you a link to reset your password.")
                .multilineTextAlignment(.center)
                .padding()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding()
            }
            
            Button(action: {
                Task {
                    isLoading = true
                    do {
                        try await withCheckedThrowingContinuation { continuation in
                            AuthService.shared.resetPassword(email: email) { result in
                                continuation.resume(with: result)
                            }
                        }
                        successMessage = "Password reset email sent. Check your inbox."
                        errorMessage = nil
                    } catch {
                        errorMessage = error.localizedDescription
                        successMessage = nil
                    }
                    isLoading = false
                }
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Send Reset Link")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
            }
            .padding()
            
            NavigationLink("Back to Login", destination: LoginView())
                .padding()
        }
        .padding()
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView().environmentObject(UserAuthViewModel())
    }
}
