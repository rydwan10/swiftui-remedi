//
//  HistoryView.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 20/04/25.
//

import PhosphorSwift
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var medicineDataManager: MedicineDataManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(medicineDataManager.medicineRecords) { medicineRecord in
                        NavigationLink(value: medicineRecord) {
                            HistoryRecordCardView(medicineRecord: medicineRecord)
                        }
                    }
                    .navigationDestination(for: MedicineRecord.self) { record in
                        HistoryDetailView(medicineRecord: record)
                    }
                }
                .padding()
            }

            .navigationTitle("History")
        }
    }
}

struct HistoryRecordCardView: View {
    @EnvironmentObject var medicineDataManager: MedicineDataManager
    let medicineRecord: MedicineRecord
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Ph.pill.fill.resizable().frame(width: 24, height: 24)
                    .foregroundStyle(.gray25)
                Text("\(medicineRecord.purpose)")
                    .style(.textMd(.bold))
                    .foregroundStyle(.gray25)
                Spacer()
                Text(medicineRecord.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .style(.textMd(.bold))
                    .foregroundStyle(.gray25)
            }
            .padding(12)
            .background(.brand600)

            // Daftar Obat
            VStack(alignment: .leading) {
                let medicinesForRecord = medicineDataManager.medicines(for: medicineRecord)
                let displayedMedicines = isExpanded || medicinesForRecord.count <= 3
                    ? medicinesForRecord
                    : Array(medicinesForRecord.prefix(3))

                ForEach(displayedMedicines, id: \.id) { medicine in
                    MedicineHistoryItemView(medicine: medicine)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            if !isExpanded && medicineRecord.medicines.count < 3 {
                Spacer()
            }

            // Tombol Expand/Collapse (jika lebih dari 3 obat)
            if medicineRecord.medicines.count > 3 {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isExpanded.toggle()
                        }

                    }) {
                        HStack {
                            Text(isExpanded ? "Collapse" : "Expand")
                                .style(.textSm(.bold))

                            if isExpanded {
                                Ph.caretUp.fill.renderingMode(.template).resizable().frame(width: 16, height: 16)
                            }

                            if !isExpanded {
                                Ph.caretDown.fill.renderingMode(.template).resizable().frame(width: 16, height: 16)
                            }
                        }
                    }
                    .foregroundStyle(.gray500)
                    Spacer()
                }
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(style: StrokeStyle(lineWidth: 2))
                .foregroundColor(.brand600)
        )
        .cornerRadius(8)
    }
}

struct MedicineHistoryItemView: View {
    var medicine: Medicine

    var body: some View {
        VStack {
            HStack {
                Text(medicine.name)
                    .style(.textSm(.bold))
                    .foregroundStyle(.gray900)
                Spacer()
                Text(medicine.dosage)
                    .style(.textSm(.bold))
                    .foregroundStyle(.gray600)
            }
        }
        .padding(8)
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(style: StrokeStyle(lineWidth: 1))
                .foregroundColor(.gray400)
        }
    }
}

struct HistoryDetailView: View {
    var medicineRecord: MedicineRecord
    @EnvironmentObject var medicineDataManager: MedicineDataManager
    @State private var showSheet: Bool = false
    @State private var selectedMedicine: Medicine? = nil

    var body: some View {
        let medicinesForRecord = medicineDataManager.medicines(for: medicineRecord)

        VStack(alignment: .leading) {
            // Purpose and Timestamp
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(medicineRecord.purpose)
                        .style(.displaySm(.bold))
                        .foregroundStyle(.gray25)
                    Text(medicineRecord.timestamp.formatted(date: .abbreviated, time: .omitted))
                        .style(.textMd(.semiBold))
                        .foregroundStyle(.gray25)
                }
                .padding(.bottom, 16)

                // Stats
                HStack {
                    let takenMedicines = medicinesForRecord.filter { $0.status == .taken }
                    let missedMedicines = medicinesForRecord.filter { $0.status == .missed }

                    Spacer()
                    StatView(title: "Taken", value: takenMedicines.count, titleColor: .success600)
                    Spacer()
                    Divider()
                        .frame(width: 1, height: 32)
                        .foregroundColor(.secondary)
                    Spacer()
                    StatView(title: "Missed", value: missedMedicines.count, titleColor: .error600)
                    Spacer()
                    Divider()
                        .frame(width: 1, height: 32)
                        .foregroundColor(.secondary)
                    Spacer()
                    StatView(title: "Total", value: medicinesForRecord.count, titleColor: .gray600)
                    Spacer()
                }
                .padding(8)
                .background(.gray25)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding()
            .background(.brand600)
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
            .padding(.bottom, 16)

            // Medicine List Header
            Text("Medicine List")
                .style(.textXl(.bold))
                .padding(.bottom, 8)

            // Medicine Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(medicinesForRecord, id: \.id) { medicine in
                    MedicineGridItem(medicine: medicine)
                        .onTapGesture {
                            selectedMedicine = medicine // Simpan obat yang dipilih
                            showSheet.toggle() // Tampilkan sheet
                        }
                }
            }
            .sheet(isPresented: Binding<Bool>(
                get: { showSheet && selectedMedicine != nil },
                set: { newValue in
                    if !newValue { // Ketika sheet ditutup
                        showSheet = false
                        selectedMedicine = nil // Reset state
                    }
                }
            )) {
                if let selectedMedicine {
                    MedicineGridItemSheetView(medicine: selectedMedicine)
                        .presentationDragIndicator(.visible)
                }
            }

            Spacer()
        }

        .padding(16)
    }
}

struct StatView: View {
    let title: String
    let value: Int
    let titleColor: Color

    var body: some View {
        VStack {
            Text(title)
                .style(.textMd(.semiBold))
                .foregroundStyle(titleColor)

            Text("\(value)")
                .style(.textMd(.semiBold))
        }
    }
}

struct MedicineGridItem: View {
    let medicine: Medicine

    var body: some View {
        let isDarkBackground = medicine.labelColor.isDark()
        let textColor: Color = isDarkBackground ? .white : .black

        VStack(spacing: 8) {
            Text(medicine.name)
                .style(.textMd(.bold))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
                .lineLimit(2) // Membatasi jumlah baris
                .frame(maxWidth: .infinity)

            Text(medicine.dosage)
                .style(.textSm(.regular))
                .foregroundColor(textColor)
        }

        .padding()
        .frame(maxWidth: .infinity, minHeight: 120) // Tetapkan tinggi minimum yang konsisten
        .background(medicine.labelColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    medicine.labelColor == .white ? .black : .clear,
                    lineWidth: 1
                )
        )
    }
}

struct MedicineGridItemSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let medicine: Medicine

    var body: some View {
        NavigationStack {
            Text(medicine.name)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Back", role: .cancel) {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview("HistoryView") {
    @Previewable var medicineDataManager = MedicineDataManager()
    HistoryView()
        .environmentObject(medicineDataManager)
}

#Preview("MedicineHistoryItemView") {
    MedicineHistoryItemView(medicine: medicinesDummyData[0])
}

#Preview("HistoryDetailView") {
    @Previewable var medicineDataManager = MedicineDataManager()

    HistoryDetailView(
        medicineRecord: medicineDataManager.medicineRecords.first!
    )

    .environmentObject(medicineDataManager)
}
