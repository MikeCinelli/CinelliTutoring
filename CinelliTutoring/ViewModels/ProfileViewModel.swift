//
//  ProfileViewModel.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/20/25.
//

import Foundation
import FirebaseFirestore

// This class manages the user's profile data
class ProfileViewModel: ObservableObject {
// These two lines store the user's data and any error messages to show in the UI
    @Published var user: UserModel?  // The current user's information
    @Published var errorMessage: String? // Any errors we want to show to the user
    
    private let db = Firestore.firestore() // Create a reference to the Firestore database
    private let usersCollection = "users" // Name of the collection in Firebase where we store user profiles

    // When we create this class, we immediately try to fetch the user's profile using their user ID
    init(userId: String) {
        fetchUserProfile(userId: userId)
    }

    // This function tries to get a user's profile from the Firestore database
    func fetchUserProfile(userId: String) {
        // Go to the "users" collection and find the document with the matching user ID
        db.collection(usersCollection).document(userId).getDocument { [weak self] snapshot, error in
            // Make sure self still exists in memory
            guard let self = self else { return }

            // If there's an error, save the error message
            if let error = error {
                self.errorMessage = "Failed to fetch user profile: \(error.localizedDescription)"
                return
            }

            // If we found the user and the document exists                                                         
            if let snapshot = snapshot, snapshot.exists {
                do {
                    // Try to turn the data from Firebase into a UserModel
                    self.user = try snapshot.data(as: UserModel.self)
                } catch {
                    // If the data couldn't be converted, show an error
                    self.errorMessage = "Failed to decode user data: \(error.localizedDescription)"
                }
            } else {
                // If no user was found, show a message
                self.errorMessage = "User profile not found."
            }
        }
    }
    
    // This function updates the user profile with new info
    func updateUserProfile(updatedUser: UserModel, completion: @escaping (Bool, String?) -> Void) {
        let userId = updatedUser.id // Get the ID from the updated user model
        
        do {
            try db.collection(usersCollection).document(userId).setData(from: updatedUser, merge: true) { error in
                if let error = error { // If saving failed, tell the caller and show the error
                    completion(false, "Failed to update profile: \(error.localizedDescription)")
                } else {
                    // If it worked, update the local user variable and say it succeeded
                    self.user = updatedUser
                    completion(true, nil)
                }
            }
        } catch {
            // If we couldn't even start saving, show an error
            completion(false, "Failed to encode user data: \(error.localizedDescription)")
        }
    }
}

/*
class	A blueprint for creating objects (like a recipe)
ObservableObject	A special class that lets SwiftUI watch it for changes
@Published	Tells SwiftUI to update the screen when this value changes
UserModel	A custom data type that stores a user's info
Firestore	Firebase's online database for saving and reading data
collection	A group of documents (like a folder with files) in Firestore
document	A single file in Firestore that stores data
snapshot	A copy of the data from the database at one moment in time
try/catch	Used to run code that might fail and handle errors if they happen
do {}	A block of code where you're trying something that could fail
completion	A function passed as an argument that runs later, usually after a task finishes
escaping	A way to say this function might be used later, not right away
merge: true	Tells Firestore to keep existing data and only update what you give it
localizedDescription	A readable message explaining an error
weak self	Helps prevent memory leaks when calling back inside the class
init	A special function that runs when you create a new instance of the class
*/
