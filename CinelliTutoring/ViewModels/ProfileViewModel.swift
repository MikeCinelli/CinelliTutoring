//
//  ProfileViewModel.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/20/25.
//

import Foundation
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    
    init(userId: String) {
        fetchUserProfile(userId: userId)
    }
    
    func fetchUserProfile(userId: String) {
        db.collection(usersCollection).document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Failed to fetch user profile: \(error.localizedDescription)"
                return
            }
            
            if let snapshot = snapshot, snapshot.exists {
                do {
                    self.user = try snapshot.data(as: UserModel.self)
                } catch {
                    self.errorMessage = "Failed to decode user data: \(error.localizedDescription)"
                }
            } else {
                self.errorMessage = "User profile not found."
            }
        }
    }
    
    func updateUserProfile(updatedUser: UserModel, completion: @escaping (Bool, String?) -> Void) {
        let userId = updatedUser.id
        
        do {
            try db.collection(usersCollection).document(userId).setData(from: updatedUser, merge: true) { error in
                if let error = error {
                    completion(false, "Failed to update profile: \(error.localizedDescription)")
                } else {
                    self.user = updatedUser
                    completion(true, nil)
                }
            }
        } catch {
            completion(false, "Failed to encode user data: \(error.localizedDescription)")
        }
    }
}
