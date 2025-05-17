//
//  MedicineDummy.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 13/04/25.
//

import Foundation

let medicinesDummyData = makeMedicinesDummyData()

func makeMedicinesDummyData() -> [Medicine] {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a" // Format waktu 12 jam
    formatter.locale = Locale(identifier: "en_US_POSIX") // Hindari masalah locale

    return [
        Medicine(
            name: "Vitamin C 500mg",
            dosage: "1 tablet",
            scheduleTime: formatter.date(from: "08:00 AM")!,
            occurrence: .oneDay, // Misalnya 1 day
            startDate: nil,
            endDate: nil,
            whenToTake: "After meals",
            expiryDate: "12/12/2025",
            notes: "Take with a glass of water",
            labelColor: .yellow,
            status: .notTaken,
            takenTime: nil
        ),
        Medicine(
            name: "Ibuprofen 200mg",
            dosage: "1 tablet",
            scheduleTime: formatter.date(from: "12:00 PM")!,
            occurrence: .threeDays, // Misalnya 3 days
            startDate: nil,
            endDate: nil,
            whenToTake: "With meals",
            expiryDate: "15/01/2026",
            notes: "Avoid caffeine",
            labelColor: .blue,
            status: .taken,
            takenTime: formatter.date(from: "12:05 PM")!
        ),
        Medicine(
            name: "Vitamin D3 1000 IU",
            dosage: "1 tablet",
            scheduleTime: formatter.date(from: "07:00 PM")!,
            occurrence: .oneWeek, // Misalnya 1 week
            startDate: nil,
            endDate: nil,
            whenToTake: "After meals",
            expiryDate: "10/10/2025",
            notes: "Take before bed",
            labelColor: .red,
            status: .missed,
            takenTime: nil
        )
    ]
}
