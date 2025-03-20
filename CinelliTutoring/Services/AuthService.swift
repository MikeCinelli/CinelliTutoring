//
//  AuthService.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/6/25.
//

import Foundation // Apple foundational library
import FirebaseAuth // User authentication library
import FirebaseFirestore // Firebase database

final class AuthService { // Creating a class called AuthService. Final means it cannot be subclassed.
    static let shared = AuthService() // Creates a single, shared instance of AuthService that everyone in the app can use.
    
    private init() {} // Init - the Initializer / constructor. Private prevents anyone else from using the class.
    
    private let db = Firestore.firestore() // let db - creates a constant named db. Firestore.firestore() a function that gives access to Firebase
    
    // MARK: - User Registration with Firestore User Creation
    // Registers a new user with Firebase Authentication and creates a corresponding Firestore document.
    func registerUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Create a new Firebase authentication user with the provided email and password.
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async { // Ensure UI-related updates happen on the main thread.
                if let error = error {
                    completion(.failure(self.mapFirebaseError(error))) // Map and return any Firebase authentication errors.
                } else if let user = authResult?.user {
                    // If authentication is successful, create a Firestore document for the user.
                    self.createUserDocument(user: user) { result in
                        switch result {
                        case .success:
                            completion(.success(user)) // User successfully registered and stored in Firestore.
                        case .failure(let error):
                            completion(.failure(error)) // Firestore document creation failed, return the error.
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - Store User in Firestore
    
    // This function saves a user's information in Firestore.
    private func createUserDocument(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        
        // Create a dictionary to store user details
        let userData: [String: Any] = [
            "uid": user.uid,             // Store the user's unique ID
            "email": user.email ?? "",   // Store the user's email, if available; otherwise, store an empty string
            "createdAt": Timestamp(date: Date()) // Store the current date and time as the account creation timestamp
        ]
        
        // Save the user data to Firestore in the "users" collection.
        // The document is identified by the user's unique ID (uid).
        db.collection("users").document(user.uid).setData(userData) { error in
            
            // Ensure that the completion handler runs on the main thread.
            DispatchQueue.main.async {
                
                // If there's an error while saving data, return the error.
                if let error = error {
                    completion(.failure(error)) // Notify the caller that something went wrong
                } else {
                    completion(.success(())) // Notify the caller that the operation was successful
                }
            }
        }
    }
    
    
    // MARK: - User Login
    // This function is used to log in a user with their email and password.
    func loginUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        
        // Calling Firebase's authentication method to sign in with an email and password.
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            
            // Switching back to the main thread to update the UI or handle the result.
            DispatchQueue.main.async {
                
                // If there is an error during login, map it to a readable error and return it.
                if let error = error {
                    completion(.failure(self.mapFirebaseError(error)))
                    
                    // If login is successful and we get a valid user, return the user.
                } else if let user = authResult?.user {
                    completion(.success(user))
                }
            }
        }
    }
    
    
    // MARK: - User Logout
    func logoutUser(completion: @escaping (Result<Void, Error>) -> Void) {
        
        // Using 'do-catch' to handle possible errors when signing out
        do {
            // Attempt to sign the user out using Firebase Authentication
            try Auth.auth().signOut()
            
            // Since signing out was successful, we switch back to the main thread
            DispatchQueue.main.async {
                // Call the completion handler with success (empty result since there's nothing to return)
                completion(.success(()))
            }
        } catch {
            // If there was an error while signing out, we switch back to the main thread
            DispatchQueue.main.async {
                // Call the completion handler with the error, mapping it to a Firebase-specific error format
                completion(.failure(self.mapFirebaseError(error)))
            }
        }
    }
    
    
    // MARK: - Password Reset
    // This function allows users to reset their password by sending a reset email.
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        // Use Firebase Authentication to send a password reset email.
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            
            // Ensure the code runs on the main thread to update the UI or notify the user.
            DispatchQueue.main.async {
                
                // If there is an error, process it and return a failure result.
                if let error = error {
                    completion(.failure(self.mapFirebaseError(error))) // Convert Firebase error to a readable format.
                } else {
                    // If there is no error, the email was sent successfully.
                    completion(.success(()))
                }
            }
        }
    }
    
    
    // MARK: - Get Current User
    // This function retrieves the currently logged-in user.
    func getCurrentUser() -> User? {
        // "Auth.auth().currentUser" gets the current user from Firebase Authentication.
        // If a user is logged in, it returns their information.
        // If no user is logged in, it returns nil.
        return Auth.auth().currentUser
    }
    
    // MARK: - Listen to Auth State Changes
    // This function listens for changes in the authentication state (e.g., user logs in or out).
    func addAuthStateListener(_ listener: @escaping (User?) -> Void) {
        
        // Auth.auth() is Firebase's authentication system.
        // .addStateDidChangeListener observes when the user's authentication state changes.
        Auth.auth().addStateDidChangeListener { _, user in
            
            // DispatchQueue.main.async makes sure that any updates happen on the main thread,
            // which is important for updating the user interface.
            DispatchQueue.main.async {
                
                // Calls the listener function and passes the current user (or nil if logged out).
                listener(user)
            }
        }
    }
    
    
    // MARK: - Firebase Error Handling
    
    // This function takes an error from Firebase and translates it into a more user-friendly message.
    private func mapFirebaseError(_ error: Error) -> Error {
        
        // Convert the generic error into an NSError object so we can access its error code.
        let nsError = error as NSError
        
        // Check the error code and return a new error with a clear message.
        switch nsError.code {
            
            // If there is a network problem, tell the user to try again.
        case AuthErrorCode.networkError.rawValue:
            return NSError(domain: "AuthService", code: nsError.code,
                           userInfo: [NSLocalizedDescriptionKey: "Network error. Please try again."])
            
            // If the user's email is not found in the system, tell them no account exists with that email.
        case AuthErrorCode.userNotFound.rawValue:
            return NSError(domain: "AuthService", code: nsError.code,
                           userInfo: [NSLocalizedDescriptionKey: "No user found with this email."])
            
            // If the user enters the wrong password, let them know it's incorrect.
        case AuthErrorCode.wrongPassword.rawValue:
            return NSError(domain: "AuthService", code: nsError.code,
                           userInfo: [NSLocalizedDescriptionKey: "Incorrect password. Please try again."])
            
            // If the email is already being used by another account, notify the user.
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return NSError(domain: "AuthService", code: nsError.code,
                           userInfo: [NSLocalizedDescriptionKey: "Email is already in use."])
            
            // If the user chooses a weak password, tell them to pick a stronger one.
        case AuthErrorCode.weakPassword.rawValue:
            return NSError(domain: "AuthService", code: nsError.code,
                           userInfo: [NSLocalizedDescriptionKey: "Password is too weak. Please choose a stronger one."])
            
            // If the error is not recognized, return it as is.
        default:
            return error
        }
    }
}



// Singleton instance is like a coffee machine in an office. There is only one and everybody gets to use it.
