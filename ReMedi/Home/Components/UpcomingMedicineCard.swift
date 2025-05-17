//
//  UpcomingMedicineCard.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 13/04/25.
//

import PhosphorSwift
import SwiftUI

struct UpcomingMedicineCard: View {
    let medicine: Medicine

    @State private var isShowingSheet = false

    var body: some View {
        let isDarkBackground = medicine.labelColor.isDark()
        let textColor: Color = isDarkBackground ? .white : .black

        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Upcoming Medicine")
                        .style(.textLg(.extraBold))
                        .foregroundStyle(textColor)
                    Text("at \(formattedTime(from: medicine.scheduleTime, using: .twentyFourHour))")
                        .style(.textMd(.semiBold))
                        .padding(.bottom, 24)
                        .foregroundStyle(textColor)
                    Text(medicine.name)
                        .style(.textMd(.bold))
                        .foregroundStyle(textColor)
                }
                Spacer()
                VStack {
                    Ph.pill.fill
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(medicine.labelColor)
                        .padding(16)
                }
                .background(textColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(medicine.labelColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.bottom, 24)
        .overlay {
            if medicine.labelColor.isDark() {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white, lineWidth: 2)
            } else if medicine.labelColor == .white {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.black, lineWidth: 2)
            } else {
                EmptyView()
            }
        }
        .onTapGesture {
            isShowingSheet.toggle()
        }
        .sheet(isPresented: $isShowingSheet) {
            MedicineItemSheetView(medicine: medicine)
        }
    }
}

struct UpcomingMedicineEmptyView: View {
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("No Upcoming Medicine")
                        .style(.textLg(.extraBold))
                        .foregroundStyle(.gray25)

                    Text("You're all set for now!")
                        .style(.textMd(.semiBold))
                        .padding(.bottom, 24)
                        .foregroundStyle(.gray25)
                }
                Spacer()
                VStack {
                    Ph.checkFat.fill
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(.success600)
                        .padding(16)
                }
                .background(.gray25)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(.success600)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview("UpcomingMedicineCard") {
    @Previewable var medicineDataManager = MedicineDataManager()

    UpcomingMedicineCard(
        medicine: medicineDataManager.todaySchedule.last!
    )
}

#Preview("UpcomingMedicineEmptyView") {
    UpcomingMedicineEmptyView()
}
