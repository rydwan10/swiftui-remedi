//
//  ContentView.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 12/04/25.
//
import Inject
import PhosphorSwift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var medicineDataManager: MedicineDataManager
    @ObserveInjection var inject
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                HStack {
                    Text("ReMedi")
                        .style(.displaySm(.extraBold))
                    Ph.pill.fill.resizable().frame(width: 32, height: 32)
                        .foregroundStyle(.brand400)
                }
                Spacer()
                Ph.bell.regular.frame(width: 24, height: 24)
                    .foregroundStyle(.gray600)
            }

            if medicineDataManager.upcomingMedicine != nil {
                UpcomingMedicineCard(
                    medicine: medicineDataManager.upcomingMedicine!
                )
            } else {
                UpcomingMedicineEmptyView()
            }

            TodaysMedicine()
            Spacer()
        }
        .padding(.horizontal, 16)
        .enableInjection()
    }
}

#Preview("ContentView") {
    @Previewable let medicineDataManager = MedicineDataManager()
    ContentView()
        .environmentObject(medicineDataManager)
}
