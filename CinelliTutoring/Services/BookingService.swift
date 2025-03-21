//
//  BookingService.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/20/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

// BookingService is a helper class that handles everything related to creating, canceling, and getting bookings from the Firebase database.
final class BookingService {
    static let shared = BookingService() // This makes a shared (singleton) instance so we can use BookingService.shared anywhere in the app
    private let db = Firestore.firestore() // This connects us to Firestore, the Firebase database
    private let bookingsCollection = "bookings" // These are the names of the collections in Firestore we’ll be using
    private let timeSlotsCollection = "timeSlots" // These are the names of the collections in Firestore we’ll be using

    private init() {} // The init is private so nobody can make another instance of BookingService
    
    // Create a booking
    func createBooking(booking: BookingModel, completion: @escaping (Result<Void, Error>) -> Void) { 
        let bookingRef = db.collection(bookingsCollection).document(booking.id) // Make a reference to where we want to store the booking
        
        // Step 1: Make sure the time slot is available
        db.collection(timeSlotsCollection)
            .whereField("startTime", isEqualTo: booking.startTime) // Look for a time slot that matches the booking start time
            .whereField("isAvailable", isEqualTo: true) // And that is available
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(error)) // Something went wrong
                    return
                }

                // If there’s no available time slot, return an error           
                guard let document = snapshot?.documents.first else {
                    completion(.failure(NSError(domain: "BookingService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Time slot is unavailable."])))
                    return
                }
                
                let timeSlotRef = document.reference // Reference to the available time slot

                // Step 2: Lock the time slot and save the booking using a transaction (does both at once safely)
                self.db.runTransaction({ (transaction, errorPointer) -> Any? in
                    do {
                        transaction.updateData(["isAvailable": false], forDocument: timeSlotRef) // Mark the slot as no longer available
                        transaction.setData(booking.toDictionary(), forDocument: bookingRef) // Save the booking info
                        return nil
                    } catch let error {
                        errorPointer?.pointee = error as NSError
                        return nil
                    }
                }) { (object, error) in
                    if let error = error {
                        completion(.failure(error)) // Tell whoever called this function whether it worked
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }
    
    // ❌ Cancel an existing booking
    func cancelBooking(bookingId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let bookingRef = db.collection(bookingsCollection).document(bookingId)

        // Step 1: Get the booking information
        bookingRef.getDocument { (document, error) in
            guard let document = document, document.exists, let booking = try? document.data(as: BookingModel.self) else {
                completion(.failure(error ?? NSError(domain: "BookingService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Booking not found."])))
                return
            }
            
            // Step 2: Find the related time slot
            self.db.collection(self.timeSlotsCollection)
                .whereField("startTime", isEqualTo: booking.startTime)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let document = snapshot?.documents.first else {
                        completion(.failure(NSError(domain: "BookingService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Time slot not found."])))
                        return
                    }
                    
                    let timeSlotRef = document.reference
                    
                    // Step 3: Use a transaction to make the time slot available again and remove the booking
                    self.db.runTransaction({ (transaction, errorPointer) -> Any? in
                        do {
                            transaction.updateData(["isAvailable": true], forDocument: timeSlotRef)
                            transaction.deleteDocument(bookingRef)
                            return nil
                        } catch let error {
                            errorPointer?.pointee = error as NSError
                            return nil
                        }
                    }) { (object, error) in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
        }
    }
    
    // 📚 Get all bookings for a user
    func fetchBookings(userId: String, completion: @escaping (Result<[BookingModel], Error>) -> Void) {
        db.collection(bookingsCollection)
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let bookings = snapshot?.documents.compactMap { try? $0.data(as: BookingModel.self) } ?? []
                    completion(.success(bookings))
                }
            }
    }
}

/*
@escaping:
Used when a function’s completion handler might run after the function has returned. Think of it as “this will finish later.”

final class:
A class that can’t be subclassed. It’s final, nobody can inherit from it.

static let shared = ...:
This creates a singleton, meaning only one instance of the class exists for the whole app.

private init() {}:
Makes sure the class can't be created from outside — used with singletons.

Firestore.firestore():
Gives access to the Firebase Firestore database.

runTransaction:
A way to safely make multiple changes (like updating and writing) to Firestore at once. Ensures data stays in sync.

document.data(as: BookingModel.self):
Tells Firestore to convert the data in a document to our Swift struct called BookingModel.

completion: @escaping (...) -> Void:
This is a way to say, “when this function finishes, run this other block of code.”

Result<SuccessType, Error>:
A type that either contains a success (with data) or a failure (with an error). Used to handle success/failure neatly.

compactMap { try? ... }:
This means “try to decode each document, and skip it if it fails.”

.first:
Gets the first element from an array or list.

document.reference:
Gets a reference to the exact location of the document in the Firestore database.
*/
