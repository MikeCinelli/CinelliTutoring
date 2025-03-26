//
//  BookingView.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/20/25.
//


import SwiftUI

// This is the screen where users can view and create tutoring bookings.
struct BookingView: View {
    @StateObject private var viewModel = BookingViewModel() // This connects the view to the booking logic (ViewModel)
    @EnvironmentObject var authViewModel: UserAuthViewModel // This gives us the current logged-in user's info
    @State private var selectedTimeSlot: TimeSlotModel? // Holds the time the user selects for booking
    @State private var showingConfirmationAlert = false // Controls if the booking confirmation popup is shown
    @State private var showingErrorAlert = false // Controls if an error popup is shownc
    
    var body: some View {
        VStack {
            // Main title at the top
            Text("Book a Tutoring Session")
                .font(.largeTitle)
                .padding()

            // Show a loading spinner if the app is still getting data
            if viewModel.isLoading {
                ProgressView()
            // If there's an error message, show it in red
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            // If bookings are available, show them in a list
            } else {
                List(viewModel.bookings) { booking in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Start: \(formattedDate(booking.startTime))")
                            Text("End: \(formattedDate(booking.endTime))")
                        }
                        Spacer()
                         // If this booking is already confirmed, allow the user to cancel it
                        if booking.status == .confirmed {
                            Button(action: {
                                viewModel.cancelBooking(bookingId: booking.id)
                            }) {
                                Text("Cancel")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            // Button to book the time the user selected
            Button(action: {
                showingConfirmationAlert = true // When tapped, show confirmation popup
            }) {
                Text("Book Selected Time")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .disabled(selectedTimeSlot == nil) // Disable button if no time is selected
            
        }
        .onAppear {
            // When the screen appears, load this user's bookings from the database
            if let userId = authViewModel.user?.uid {
                viewModel.fetchUserBookings(userId: userId)
            }
        }
        .alert(isPresented: $showingConfirmationAlert) {
            // This is the popup asking the user to confirm their booking
            Alert(
                title: Text("Confirm Booking"),
                message: Text("Are you sure you want to book this session?"),
                primaryButton: .default(Text("Confirm")) {
                    // If user confirms, create a new booking
                    if let userId = authViewModel.user?.uid, let timeSlot = selectedTimeSlot {
                        let newBooking = BookingModel(
                            id: UUID().uuidString,
                            userId: userId,
                            startTime: timeSlot.startTime,
                            endTime: timeSlot.endTime,
                            status: .pending,
                            amount: calculateAmount(for: timeSlot), // Price based on time and client type
                            isPaid: false
                        )
                        viewModel.createBooking(booking: newBooking)
                    }
                },
                secondaryButton: .cancel() // If user cancels, do nothing
            )
        }
    }

    // This turns a Date (like 3/26/25 at 5:00 PM) into a readable string
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    // This calculates how much to charge based on who the user is and how long the session is
    private func calculateAmount(for timeSlot: TimeSlotModel) -> Double {
        let duration = timeSlot.endTime.timeIntervalSince(timeSlot.startTime) / 3600
        return authViewModel.userModel?.role == .clientChild ? duration * 100 : duration * 50
    }
}
// This lets us see a preview of the screen when designing the app
struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        BookingView()
            .environmentObject(UserAuthViewModel())
    }
}
