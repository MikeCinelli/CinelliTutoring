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
        VStack { // A vertical stack layout that arranges everything top to bottom
            Text("Login") // Displays the "Login" title
                .font(.largeTitle) // Makes the text large
                .bold() // Makes the text bold
                .padding() // Adds space around the text
            
            TextField("Email", text: $email) // Input field for the user's email
                .textFieldStyle(RoundedBorderTextFieldStyle()) // Gives the field rounded corners
                .keyboardType(.emailAddress) // Makes the keyboard show email-related keys
                .autocapitalization(.none) // Prevents automatic capitalization (like for emails)
                .padding() // Adds space around the field
            
            SecureField("Password", text: $password) // Password input (hides characters)
                .textFieldStyle(RoundedBorderTextFieldStyle()) // Rounded appearance
                .padding() 
            
            if let errorMessage = errorMessage { // If there's an error message, show it
                Text(errorMessage) // Display the error message
                    .foregroundColor(.red) // Make the error text red
                    .padding()
            }
            
            Button(action: { // When the login button is pressed
                Task {
                    isLoading = true // Start loading spinner
                    await authViewModel.login(email: email, password: password)  // Try to log in
                    isLoading = false // Stop loading spinner
                    errorMessage = authViewModel.authError // Show any error that occurred
                }
            }) {
                if isLoading {
                    ProgressView() // Show a spinner while loading
                } else {
                    Text("Login") // Show login text when not loading
                        .foregroundColor(.white) // Make text white
                        .padding() // Add internal space to the button
                        .frame(maxWidth: .infinity)  // Make button stretch to full width
                        .background(Color.blue) // Set background color
                        .cornerRadius(10) // Round the corners
                }
            }
            .padding() // Add space around the button
            
            NavigationLink("Forgot Password?", destination: ForgotPasswordView()) // A tappable link to reset password
                .padding()
            
            NavigationLink("Don't have an account? Sign Up", destination: SignupView()) // A link to sign-up screen
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

/*
@State	A property wrapper that lets the view track changes to a value (like text fields).
@EnvironmentObject	Used to access shared data (like user login state) throughout many views.
TextField	A box where the user can type input (like their email).
SecureField	Like TextField, but it hides the text (used for passwords).
Button	Something the user can tap to trigger an action.
Task { }	Runs code asynchronously — useful for things like logging in, which may take time.
ProgressView()	A spinning loading icon shown while something is happening.
NavigationLink	Lets the user tap and go to another screen/view.
.padding()	Adds extra space around a view so things don’t look cramped.
.cornerRadius(10)	Rounds the corners of the button to make it look nicer.
ViewModel	An object that handles the logic and data for the view — helps separate design from logic.
LoginView_Previews	Lets developers see what the view will look like without running the whole app.
UserAuthViewModel	The ViewModel that contains login/logout logic and user session tracking.
*/
