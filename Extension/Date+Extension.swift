//
//  Date+Extension.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 13/04/25.
//

import Foundation

extension Date {
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: self)
    }
    
}

extension DateFormatter {
    static let expiryDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy" // Sesuaikan format dengan data Anda
        return formatter
    }()
}
