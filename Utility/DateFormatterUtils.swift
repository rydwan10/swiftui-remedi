//
//  DateFormatterUtils.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 13/04/25.
//

import Foundation

func formattedTime(from date: Date, using format: TimeFormat) -> String {
    let formatter = DateFormatter()
    switch format {
    case .twelveHour:
        formatter.dateFormat = "h:mm a" // Contoh: 10:00 AM
    case .twentyFourHour:
        formatter.dateFormat = "HH:mm" // Contoh: 22:00
    }
    return formatter.string(from: date)
}

