//
//  MediceneTakingOccurence.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 18/04/25.
//

import Foundation

enum MedicineTakingOccurrenceEnum: String, CaseIterable, Identifiable {
    case oneDay = "1 day"
    case threeDays = "3 days"
    case oneWeek = "1 week"
    case twoWeeks = "2 weeks"
    case custom = "Custom"

    var id: String { rawValue }
}
