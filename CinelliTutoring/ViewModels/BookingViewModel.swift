//
//  BookingViewModel.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/20/25.
//

import Foundation // This is a github comment
import Combine

class BookingViewModel: ObservableObject {
    @Published var bookings: [BookingModel] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private let bookingService = BookingService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func fetchUserBookings(userId: String) {
        isLoading = true
        bookingService.fetchBookings(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let bookings):
                    self?.bookings = bookings
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch bookings: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func createBooking(booking: BookingModel) {
        isLoading = true
        bookingService.createBooking(booking: booking) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.fetchUserBookings(userId: booking.userId) // Refresh bookings after creation
                case .failure(let error):
                    self?.errorMessage = "Failed to create booking: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func cancelBooking(bookingId: String) {
        isLoading = true
        bookingService.cancelBooking(bookingId: bookingId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.bookings.removeAll { $0.id == bookingId } // Remove canceled booking from local state
                case .failure(let error):
                    self?.errorMessage = "Failed to cancel booking: \(error.localizedDescription)"
                }
            }
        }
    }
}
