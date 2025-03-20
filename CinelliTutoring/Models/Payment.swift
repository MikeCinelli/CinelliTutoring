//
//  Payment.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/5/25.
//

import Foundation

struct PaymentModel: Identifiable, Codable {
    var id: String
    var userId: String
    var bookingId: String
    var amount: Double
    var status: PaymentStatus
    var transactionId: String? // Optional because payments might fail. //
}

enum PaymentStatus: String, Codable {
    case authorized
    case captured
    case refunded
    case failed
}
