//
//  TimeSlot.swift
//  CinelliTutoring
//
//  Created by Michael Cinelli on 3/5/25.
//

import Foundation

struct TimeSlotModel: Identifiable, Codable {
    var id: String
    var startTime: Date
    var endTime: Date
    var isAvailable: Bool
}
