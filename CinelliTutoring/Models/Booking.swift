//
//  Booking.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/5/25.
//

import Foundation

struct BookingModel: Identifiable, Codable {
    var id: String // unique id for this particular booking
    var userId: String //userId is fetched from the viewmodel of our MVVM architecture.
    var startTime: Date
    var endTime: Date
    var status: BookingStatus
    var amount: Double
    var isPaid: Bool

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "userId": userId,
            "startTime": startTime,
            "endTime": endTime,
            "status": status.rawValue,
            "amount": amount,
            "isPaid": isPaid
        ]
    }
}

enum BookingStatus: String, Codable {
    case pending
    case confirmed
    case canceled
    case completed
}
