//
//  MedicineRecord.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 20/04/25.
//

import SwiftUI

struct MedicineRecord: Identifiable, Hashable {
  let id = UUID()
  var purpose: String  // Tujuan penggunaan, misalnya "Untuk sakit kepala"
  var medicines: [UUID]  // Referensi ID obat
  var timestamp: Date  // Waktu pencatatan
}
