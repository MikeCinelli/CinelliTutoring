//
//  StripeTransaction.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/5/25.
//

import Foundation

struct StripeTransactionModel: Identifiable, Codable {
    var id: String
    var userId: String
    var bookingId: String
    var stripePaymentId: String
    var amount: Double
    var currency: String
    var status: StripePaymentStatus
    var timestamp: Date
}

enum StripePaymentStatus: String, Codable {
    case succeeded
    case failed
    case refunded
}

