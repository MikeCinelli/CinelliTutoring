//
//  BookingService.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/20/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

final class BookingService {
    static let shared = BookingService()
    private let db = Firestore.firestore()
    private let bookingsCollection = "bookings"
    private let timeSlotsCollection = "timeSlots"
    
    private init() {}
    
    // Create a booking
    func createBooking(booking: BookingModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let bookingRef = db.collection(bookingsCollection).document(booking.id)
        
        // Fetch the available time slot first
        db.collection(timeSlotsCollection)
            .whereField("startTime", isEqualTo: booking.startTime)
            .whereField("isAvailable", isEqualTo: true)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    completion(.failure(NSError(domain: "BookingService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Time slot is unavailable."])))
                    return
                }
                
                let timeSlotRef = document.reference

                // Perform transaction to lock the slot
                self.db.runTransaction({ (transaction, errorPointer) -> Any? in
                    do {
                        transaction.updateData(["isAvailable": false], forDocument: timeSlotRef)
                        transaction.setData(booking.toDictionary(), forDocument: bookingRef)
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
    
    // Cancel a booking
    func cancelBooking(bookingId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let bookingRef = db.collection(bookingsCollection).document(bookingId)
        
        bookingRef.getDocument { (document, error) in
            guard let document = document, document.exists, let booking = try? document.data(as: BookingModel.self) else {
                completion(.failure(error ?? NSError(domain: "BookingService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Booking not found."])))
                return
            }
            
            // Fetch the associated time slot
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
                    
                    // Perform transaction to unlock the slot and delete booking
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
    
    // Fetch bookings for a user
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
