//
//  BookingView.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/20/25.
//


import SwiftUI

struct BookingView: View {
    @StateObject private var viewModel = BookingViewModel()
    @EnvironmentObject var authViewModel: UserAuthViewModel
    @State private var selectedTimeSlot: TimeSlotModel?
    @State private var showingConfirmationAlert = false
    @State private var showingErrorAlert = false
    
    var body: some View {
        VStack {
            Text("Book a Tutoring Session")
                .font(.largeTitle)
                .padding()
            
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(viewModel.bookings) { booking in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Start: \(formattedDate(booking.startTime))")
                            Text("End: \(formattedDate(booking.endTime))")
                        }
                        Spacer()
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
            
            Button(action: {
                showingConfirmationAlert = true
            }) {
                Text("Book Selected Time")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .disabled(selectedTimeSlot == nil)
            
        }
        .onAppear {
            if let userId = authViewModel.user?.uid {
                viewModel.fetchUserBookings(userId: userId)
            }
        }
        .alert(isPresented: $showingConfirmationAlert) {
            Alert(
                title: Text("Confirm Booking"),
                message: Text("Are you sure you want to book this session?"),
                primaryButton: .default(Text("Confirm")) {
                    if let userId = authViewModel.user?.uid, let timeSlot = selectedTimeSlot {
                        let newBooking = BookingModel(
                            id: UUID().uuidString,
                            userId: userId,
                            startTime: timeSlot.startTime,
                            endTime: timeSlot.endTime,
                            status: .pending,
                            amount: calculateAmount(for: timeSlot),
                            isPaid: false
                        )
                        viewModel.createBooking(booking: newBooking)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func calculateAmount(for timeSlot: TimeSlotModel) -> Double {
        let duration = timeSlot.endTime.timeIntervalSince(timeSlot.startTime) / 3600
        return authViewModel.userModel?.role == .clientChild ? duration * 100 : duration * 50
    }
}

struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        BookingView()
            .environmentObject(UserAuthViewModel())
    }
}
