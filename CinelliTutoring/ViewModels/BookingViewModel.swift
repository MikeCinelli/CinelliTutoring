//
//  BookingViewModel.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/20/25.
//

import Foundation 
import Combine // Helps with handling updates to the UI when data changes help 

// This class manages booking-related data and makes it available to the UI
class BookingViewModel: ObservableObject {
    @Published var bookings: [BookingModel] = [] // This holds the list of all bookings for a user
    @Published var errorMessage: String? // If something goes wrong (like a network error), we show the error message here
    @Published var isLoading: Bool = false // Used to show a loading spinner in the UI while we're fetching or changing data
    
    private let bookingService = BookingService.shared // This connects us to the BookingService class that talks to the Firebase database
    private var cancellables = Set<AnyCancellable>() // A container to hold Combine’s cancellable tasks (not used here, but prepared for future use)

    // This function gets all bookings for a specific user
    func fetchUserBookings(userId: String) {
        isLoading = true // Show loading indicator
        bookingService.fetchBookings(userId: userId) { [weak self] result in
            DispatchQueue.main.async { // Make sure UI updates happen on the main thread
                self?.isLoading = false // Stop loading indicator
                switch result {
                case .success(let bookings): // If we got bookings successfully
                    self?.bookings = bookings // Store them in our list
                case .failure(let error): // If there was an error
                    self?.errorMessage = "Failed to fetch bookings: \(error.localizedDescription)"
                }
            }
        }
    }
    // This function creates a new booking in the system
    func createBooking(booking: BookingModel) {
        isLoading = true // Start loading indicator
        bookingService.createBooking(booking: booking) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false // Stop loading indicator
                switch result {
                case .success: // Refresh the bookings list so we see the new booking right away
                    self?.fetchUserBookings(userId: booking.userId) // Refresh bookings after creation
                case .failure(let error):
                    self?.errorMessage = "Failed to create booking: \(error.localizedDescription)"
                }
            }
        }
    }

    // This function creates a new booking in the system
    func cancelBooking(bookingId: String) {
        isLoading = true // Start loading indicator
        bookingService.cancelBooking(bookingId: bookingId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false // Stop loading indicator
                switch result {
                case .success: // Refresh the bookings list so we see the new booking right away
                    self?.bookings.removeAll { $0.id == bookingId } // Remove canceled booking from local state
                case .failure(let error): // If something went wrong
                    self?.errorMessage = "Failed to cancel booking: \(error.localizedDescription)"
                }
            }
        }
    }
}

/*
ViewModel: A class that holds and manages data for the screen (or "view") and updates it when needed.

ObservableObject: Lets the view know when something has changed so it can update the screen.

@Published: A way to say “watch this variable—if it changes, update the UI.”

BookingModel: A custom data type that holds booking info like start time, end time, etc.

isLoading: A variable that tracks if the app is busy (for example, getting data).

errorMessage: A string that shows what went wrong when there’s an error.

bookingService: This is the class that actually talks to Firebase to create, get, or cancel bookings.

DispatchQueue.main.async: Makes sure that things that affect the screen (like updating the list or showing a message) happen on the main thread.

completion handler: A block of code that runs when something (like saving a booking) finishes.

[weak self]: Prevents memory issues by not strongly holding onto the view model inside the closure.

closure: A block of code you can pass around and run later (like a mini function).
*/
