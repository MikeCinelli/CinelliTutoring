//
//  UserAuthViewModel.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/11/25.
//

import Foundation
import FirebaseAuth

/// ViewModel for handling user authentication logic
/// Interacts with `AuthService` to perform sign-up, login, logout, and session management.
final class UserAuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var user: User? // Holds the currently logged-in user
    @Published var userModel: UserModel?  // Add this property
    @Published var authError: String? // Stores authentication-related error messages
    @Published var isLoading: Bool = false // Tracks if an authentication request is in progress
    
    private let authService = AuthService.shared // Singleton instance of AuthService
    
    // MARK: - Initialization
    init() {
        self.user = authService.getCurrentUser() // Load the current user if already authenticated
        listenToAuthChanges() // Start listening for authentication state changes
    }
    
    // MARK: - Sign Up User
    /// Registers a new user with Firebase Authentication
    /// - Parameters:
    ///   - email: User email address
    ///   - password: User password
    @MainActor
    func signUp(email: String, password: String) async {
        isLoading = true
        do {
            let newUser = try await withCheckedThrowingContinuation { continuation in
                authService.registerUser(email: email, password: password) { result in
                    continuation.resume(with: result)
                }
            }
            self.user = newUser // Update UI with new user
            self.authError = nil // Clear any previous errors
        } catch {
            self.authError = error.localizedDescription // Display error message
        }
        isLoading = false
    }
    
    // MARK: - Login User
    /// Logs in an existing user using Firebase Authentication
    /// - Parameters:
    ///   - email: User email address
    ///   - password: User password
    @MainActor
    func login(email: String, password: String) async {
        isLoading = true
        do {
            let loggedInUser = try await withCheckedThrowingContinuation { continuation in
                authService.loginUser(email: email, password: password) { result in
                    continuation.resume(with: result)
                }
            }
            self.user = loggedInUser // Update UI with logged-in user
            self.authError = nil
        } catch {
            self.authError = error.localizedDescription // Display error message
        }
        isLoading = false
    }
    
    // MARK: - Logout User
    /// Logs out the current user
    @MainActor
    func logout() async {
        isLoading = true
        do {
            try await withCheckedThrowingContinuation { continuation in
                authService.logoutUser { result in
                    continuation.resume(with: result)
                }
            }
            self.user = nil // Clear user data
            self.authError = nil
        } catch {
            self.authError = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Listen to Auth Changes
    /// Observes authentication state changes
    private func listenToAuthChanges() {
        authService.addAuthStateListener { [weak self] newUser in
            DispatchQueue.main.async {
                self?.user = newUser
            }
        }
    }
}
