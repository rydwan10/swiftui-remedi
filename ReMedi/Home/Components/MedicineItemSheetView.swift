//
//  MedicineItemSheetView.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 19/04/25.
//

import SwiftUI

struct MedicineItemSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var medicineDataManager: MedicineDataManager
    @State private var isShowingActionSheet = false
    @State private var isShowingNotesDialog = false
    @State private var isShowingAlert = false
    @State private var tempNotes: String = ""
    @State private var showTakenAnimation: Bool = false
    let medicine: Medicine

    @State private var missedNotes: String = ""

    /// Simulate notes input (replace with real logic if needed)
    private func presentNotesInput() {
        missedNotes = "User-added note (example)"
        print("Medicine marked as missed with notes: \(missedNotes)")
    }

    var body: some View {
        NavigationView {
            ScrollView {
                Spacer()
                    .frame(height: 32)
                Image("il_medicine")
                    .resizable()
                    .frame(width: 256, height: 256)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(medicine.name)
                    .style(.textLg(.bold))
                    .padding(.top, 16)

                VStack(alignment: .leading, spacing: 16) {
                    MedicineInfoRow(title: "Dose", value: medicine.dosage + " at a time")
                    MedicineInfoRow(title: "When to Take", value: medicine.whenToTake ?? "")
                    MedicineInfoRow(title: "Expiry Date", value: medicine.expiryDate ?? "")
                    MedicineInfoRow(title: "Notes", value: medicine.notes)
                    MedicineTakingStatusRow(status: medicine.status)
                    if medicine.missedNotes != nil {
                        MedicineInfoRow(title: "Missed Notes", value: medicine.missedNotes!)
                    }
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 1)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

                ReButton(
                    title: "Update Medicine",
                    onPressed: {
                        isShowingActionSheet.toggle()
                    },
                    isFullWidth: true
                )
                .padding(.horizontal, 16)
            }
            .navigationTitle("Medicine Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back", role: .cancel) {
                        dismiss()
                    }
                }
            }.confirmationDialog(
                "Update Medicine Status",
                isPresented: $isShowingActionSheet,
                titleVisibility: .visible
            ) {
                Button("Mark as Taken") {
                    // Handle Mark as Taken logic
//                    print("Medicine marked as taken")
//                    showTakenAnimation.toggle()

                    medicineDataManager.updateMedicineStatus(for: medicine, status: .taken)
                    dismiss()
                }
                Button("Mark as Missed", role: .destructive) {
                    isShowingNotesDialog.toggle()
                    isShowingAlert.toggle()
                }

                Button("Cancel", role: .cancel) {}
            }
            .alert("Mark as Missed", isPresented: $isShowingAlert, actions: {
                TextField("Optional notes...", text: $tempNotes)
                Button("Save") {
                    medicineDataManager.updateMedicineStatus(
                        for: medicine,
                        status: .missed,
                        missedNotes: tempNotes
                    )
                    dismiss()
                }
                Button("Cancel", role: .cancel) {
                    medicineDataManager.updateMedicineStatus(
                        for: medicine,
                        status: .missed
                    )
                    dismiss()
                }
            }, message: {
                Text("You can optionally add notes for this action.")
            })
        }
    }
}

struct MedicineInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .style(.textMd())
            Spacer()
            Text(value)
                .style(.textMd(.semiBold))
                .multilineTextAlignment(.trailing)
        }
    }
}

struct MedicineTakingStatusRow: View {
    let status: MedicineTakingStatus

    var body: some View {
        HStack {
            Text("Taking Status")
                .style(.textMd())
            Spacer()
            
            
            Text(status.rawValue)
                .style(.textMd(.semiBold))
                .multilineTextAlignment(.trailing)
                .foregroundStyle(
                    status == .missed ? .error600 : status == .taken ? .success600 : .gray600
                )
        }
    }
}

#Preview {
    @Previewable var medicineDataManager = MedicineDataManager()

    MedicineItemSheetView(
        medicine: medicineDataManager.todaySchedule[0]
    )
    .environmentObject(medicineDataManager)
}
