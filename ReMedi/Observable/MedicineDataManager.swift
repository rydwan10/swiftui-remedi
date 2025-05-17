//
//  MedicineDataManager.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 19/04/25.
//

import Combine
import SwiftUI

class MedicineDataManager: ObservableObject {
  @Published var medicines: [Medicine] = []
  @Published var medicineRecords: [MedicineRecord] = []  // Grup historis berdasarkan tujuan

  init() {
    loadDummyData()
    loadListMedicineRecordDummyData()
  }

  func loadDummyData() {
    let calendar = Calendar.current
    let now = Date()
    let todayStart = calendar.startOfDay(for: now)
    let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart)!
    let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: todayStart)!

    let dummyMedicines: [Medicine] = [
      // Obat Kemarin
      Medicine(
        name: "Vitamin C 500mg",
        dosage: "1 tablet",
        scheduleTime: yesterdayStart.addingTimeInterval(9 * 60 * 60),  // 09:00 AM
        occurrence: .oneDay,
        startDate: yesterdayStart,
        endDate: yesterdayStart,
        whenToTake: "After meals",
        expiryDate: "2025-12-31",
        notes: "Take with water",
        labelColor: .yellow,
        status: .taken,
        takenTime: yesterdayStart.addingTimeInterval(9 * 60 * 60)
      ),
      Medicine(
        name: "Ibuprofen 200mg",
        dosage: "1 tablet",
        scheduleTime: yesterdayStart.addingTimeInterval(13 * 60 * 60),  // 01:00 PM
        occurrence: .oneDay,
        startDate: yesterdayStart,
        endDate: yesterdayStart,
        whenToTake: "With meals",
        expiryDate: "2025-12-31",
        notes: "Avoid caffeine",
        labelColor: .blue,
        status: .missed,
        takenTime: nil
      ),
      // Obat Hari Ini
      Medicine(
        name: "Paracetamol 500mg",
        dosage: "1 tablet",
        scheduleTime: todayStart.addingTimeInterval(8 * 60 * 60),  // 08:00 AM
        occurrence: .oneDay,
        startDate: todayStart,
        endDate: todayStart,
        whenToTake: "After meals",
        expiryDate: "2025-12-31",
        notes: "Take with water",
        labelColor: .green,
        status: .notTaken,
        takenTime: nil
      ),
      Medicine(
        name: "Amoxicillin 500mg",
        dosage: "1 tablet",
        scheduleTime: todayStart.addingTimeInterval(12 * 60 * 60),  // 12:00 PM
        occurrence: .oneDay,
        startDate: todayStart,
        endDate: todayStart,
        whenToTake: "With meals",
        expiryDate: "2025-12-31",
        notes: "Avoid sunlight",
        labelColor: .red,
        status: .notTaken,
        takenTime: nil
      ),
      Medicine(
        name: "Vitamin D3 1000 IU",
        dosage: "1 tablet",
        scheduleTime: todayStart.addingTimeInterval(18 * 60 * 60),  // 06:00 PM
        occurrence: .oneDay,
        startDate: todayStart,
        endDate: todayStart,
        whenToTake: "After meals",
        expiryDate: "2025-12-31",
        notes: "Take with warm water",
        labelColor: .orange,
        status: .notTaken,
        takenTime: nil
      ),
      // Obat Besok
      Medicine(
        name: "Aspirin 81mg",
        dosage: "1 tablet",
        scheduleTime: tomorrowStart.addingTimeInterval(7 * 60 * 60),  // 07:00 AM
        occurrence: .oneDay,
        startDate: tomorrowStart,
        endDate: tomorrowStart,
        whenToTake: "After meals",
        expiryDate: "2025-12-31",
        notes: "Take with water",
        labelColor: .purple,
        status: .notTaken,
        takenTime: nil
      ),
      Medicine(
        name: "Metformin 500mg",
        dosage: "1 tablet",
        scheduleTime: tomorrowStart.addingTimeInterval(19 * 60 * 60),  // 07:00 PM
        occurrence: .oneDay,
        startDate: tomorrowStart,
        endDate: tomorrowStart,
        whenToTake: "With meals",
        expiryDate: "2025-12-31",
        notes: "Avoid alcohol",
        labelColor: .cyan,
        status: .notTaken,
        takenTime: nil
      ),
    ]
    medicines = dummyMedicines
  }

  func medicines(for record: MedicineRecord) -> [Medicine] {
    record.medicines.compactMap { id in
      medicines.first(where: { $0.id == id })
    }
  }

  // Dummy data untuk medicineRecords
  func loadListMedicineRecordDummyData() {
    guard !medicines.isEmpty else { return }

    let record1 = MedicineRecord(
      purpose: "For headache",
      medicines: [medicines[0].id, medicines[2].id, medicines[1].id, medicines[3].id],  // Contoh referensi ke Vitamin C & Paracetamol
      timestamp: Date().addingTimeInterval(-86400)  // Kemarin
    )

    let record2 = MedicineRecord(
      purpose: "For immunity boost",
      medicines: [medicines[4].id, medicines[5].id],  // Contoh referensi ke Vitamin D3 & Aspirin
      timestamp: Date()  // Hari ini
    )

    medicineRecords = [record1, record2]
  }

  // Properti untuk jadwal hari ini
  var todaySchedule: [Medicine] {
    let calendar = Calendar.current
    let now = Date()
    let todayStart = calendar.startOfDay(for: now)
    let todayEnd = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: todayStart)!

    return medicines.filter { medicine in
      // Filter hanya obat yang dijadwalkan untuk hari ini
      guard let startDate = medicine.startDate, let endDate = medicine.endDate else {
        return false
      }
      return startDate <= todayEnd && endDate >= todayStart
    }
  }

  var upcomingMedicine: Medicine? {
    let now = Date()
    return
      todaySchedule
      .filter { $0.scheduleTime >= now }  // Obat setelah waktu sekarang
      .sorted { $0.scheduleTime < $1.scheduleTime }  // Urutkan berdasarkan waktu terdekat
      .first  // Ambil obat pertama
  }

  var pastSchedule: [Medicine] {
    let calendar = Calendar.current
    let now = Date()
    let todayStart = calendar.startOfDay(for: now)

    return medicines.filter { medicine in
      guard let endDate = medicine.endDate else { return false }
      return endDate < todayStart  // Obat yang kadaluwarsa sebelum hari ini
    }
  }

  // Menambahkan jadwal baru ke daftar
  func addMedicineSchedule(_ medicine: Medicine) {
    medicines.append(medicine)
  }

  // Memperbarui status obat dan menambahkan ke riwayat
  func updateMedicineStatus(
    for medicine: Medicine, status: MedicineTakingStatus, missedNotes: String? = nil
  ) {
    if let index = medicines.firstIndex(where: { $0.id == medicine.id }) {
      var updatedMedicine = medicine
      updatedMedicine.status = status
      if status == .taken {
        updatedMedicine.takenTime = Date()
      }
      updatedMedicine.missedNotes = missedNotes ?? medicine.missedNotes
      medicines[index] = updatedMedicine
    }
  }
}
