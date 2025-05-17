//
//  TodaysMedicine.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 14/04/25.
//

import SwiftUI

struct TodaysMedicine: View {
    @EnvironmentObject var medicineDataManager: MedicineDataManager

    var body: some View {
        VStack(alignment: .leading) {
            Text("Today's Medicine")
                .style(.textLg(.extraBold))
            Text("\(medicineDataManager.todaySchedule.count) Medicines")
                .style(.textMd(.regular))
                .padding(.bottom, 16)

            ForEach(medicineDataManager.todaySchedule) { medicine in
                TodayMedicineItem(
                    medicine: medicine
                ).padding(.bottom, 16)
            }
        }
    }
}

struct TodayMedicineItem: View {
    let medicine: Medicine

    @State private var isShowingSheet = false

    var body: some View {
        HStack {
            MedicineIcon()

            VStack(alignment: .leading) {
                Text(medicine.name)
                    .style(.textMd(.bold))

                Text("Reminder at \(formattedTime(from: medicine.scheduleTime, using: .twentyFourHour))")
                    .style(.textSm(.regular))
                    .foregroundStyle(.gray600)

                if medicine.missedNotes == nil {
                    Text("\(medicine.dosage) - \(medicine.whenToTake ?? "")")
                        .style(.textSm(.regular))
                        .foregroundStyle(.gray600)
                }

                if medicine.missedNotes != nil {
                    Text("Missed Notes: " + medicine.missedNotes!)
                        .style(.textSm(.regular))
                        .foregroundStyle(.error600)
                }
            }
            Spacer()
            // TODO: update this condition
            MedicineStatusView(medicineTakingStatus: medicine.status, time: formattedTime(from: medicine.takenTime == nil ? Date() : medicine.takenTime!, using: .twelveHour))
        }
        .onTapGesture {
            isShowingSheet.toggle()
        }
        .sheet(isPresented: $isShowingSheet) {
            MedicineItemSheetView(medicine: medicine)
        }
    }
}

struct MedicineIcon: View {
    var body: some View {
        VStack {
            Image("il_medicine")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundStyle(.brand400)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray300, lineWidth: 1)
        }
        .padding(.trailing, 4)
    }
}

struct MedicineStatusView: View {
    let medicineTakingStatus: MedicineTakingStatus
    let time: String?

    var body: some View {
        VStack(alignment: .trailing) {
            // Menentukan status berdasarkan enum medicineTakingStatus
            Text(statusText)
                .style(.textSm(.semiBold))
                .foregroundStyle(statusColor)

            if medicineTakingStatus != .notTaken {
                if let time = time {
                    Text(time)
                        .style(.textSm(.semiBold))
                        .foregroundStyle(statusColor)
                }
            }
        }
    }

    // Menentukan teks status berdasarkan kondisi medicineTakingStatus
    private var statusText: String {
        switch medicineTakingStatus {
        case .taken:
            return "Taken at"
        case .missed:
            return "Missed"
        case .notTaken:
            return "Not taken yet"
        }
    }

    // Menentukan warna status berdasarkan kondisi medicineTakingStatus
    private var statusColor: Color {
        switch medicineTakingStatus {
        case .taken:
            return .success500
        case .missed:
            return .error500
        case .notTaken:
            return .gray600
        }
    }
}

#Preview("TodaysMedicine") {
    @Previewable @StateObject var medicineDataManager = MedicineDataManager()

    TodaysMedicine()
        .padding()
        .environmentObject(medicineDataManager)
}

#Preview("MedicineItemSheetView") {
    MedicineItemSheetView(
        medicine: medicinesDummyData[0]
    )
}

#Preview("DetailRow") {
    MedicineInfoRow(title: "Title", value: "Value")
}
