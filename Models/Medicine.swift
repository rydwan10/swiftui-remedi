//
//  Medicine.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 13/04/25.
//

import SwiftUI

struct Medicine: Identifiable, Hashable {
  let id = UUID()
  let name: String
  let dosage: String
  let scheduleTime: Date
  let occurrence: MedicineTakingOccurrenceEnum
  let startDate: Date?
  let endDate: Date?
  let whenToTake: String?
  let expiryDate: String?
  var notes: String
  let labelColor: Color
  var status: MedicineTakingStatus
  var takenTime: Date?
  var missedNotes: String?
}
