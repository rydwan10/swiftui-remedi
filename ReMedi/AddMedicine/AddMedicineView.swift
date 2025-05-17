//
//  AddMedicineView.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 18/04/25.
//

import PhosphorSwift
import SwiftUI

struct AddMedicineView: View {
    @State private var medicineName: String = ""
    @State private var dosage: String = ""
    @State private var scheduleTime: Date = .init()
    @State private var notes: String = ""
    @State private var startDate: Date = .init()
    @State private var endDate: Date = Date().addingTimeInterval(24 * 60 * 60) // Default to one day ahead
    @State private var selectedOccurrence: MedicineTakingOccurrenceEnum = .oneDay
    @State private var whenToTake: String = "After meals" // Default value
    @State private var customWhenToTake: String = ""
    @State private var expiryDate: Date = Date().addingTimeInterval(365 * 24 * 60 * 60) // 1 year ahead
    @State private var labelColor: Color = .blue
    @State private var status: MedicineTakingStatus = .notTaken
    @State private var takenTime: Date? = nil

    @State private var medicines: [Medicine] = [] // Temporary list of medicines
    @State private var selectedMedicineList: [Medicine]? = nil
    @State private var showConfirmSaveView = false // Navigate to ConfirmSaveMedicineView
    @State private var showValidationError = false // Show validation error
    @State private var editingMedicineIndex: Int? = nil // Index of the medicine being edited
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Medicine Name
                    Text("Medicine Name")
                        .font(.headline)
                    TextField("Enter medicine name", text: $medicineName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    // Dosage
                    Text("Dosage")
                        .font(.headline)
                    TextField("Enter dosage (e.g., 500mg, 1 tablet)", text: $dosage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .withKeyboardCloseButton()

                    // Occurrence
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Occurrence")
                                .font(.headline)
                            Picker("Occurrence", selection: $selectedOccurrence) {
                                ForEach(MedicineTakingOccurrenceEnum.allCases, id: \.self) { occurrence in
                                    Text(occurrence.rawValue).tag(occurrence)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }

                        Spacer()

                        // Schedule Time
                        VStack(alignment: .leading) {
                            Text("Schedule Time")
                                .font(.headline)
                            DatePicker("Select time", selection: $scheduleTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }

                    // Custom Date Range for Occurrence
                    if selectedOccurrence == .custom {
                        Text("Custom Date Range")
                            .font(.headline)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Start Date")
                                DatePicker("", selection: $startDate, in: Date()..., displayedComponents: .date)
                                    .labelsHidden()
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("End Date")
                                DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                                    .labelsHidden()
                            }
                        }
                    }

                    // When to Take
                    Text("When to Take")
                        .font(.headline)
                    Picker("When to Take", selection: $whenToTake) {
                        Text("Before meals").tag("Before meals")
                        Text("After meals").tag("After meals")
                        Text("Anytime").tag("Anytime")
                        Text("Custom").tag("Custom")
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    if whenToTake == "Custom" {
                        TextField("e.g., 5 minutes after Paracetamol", text: $customWhenToTake)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    HStack {
                        // Expiry Date
                        VStack(alignment: .leading) {
                            Text("Expiry Date")
                                .font(.headline)
                            DatePicker("Select expiry date", selection: $expiryDate, displayedComponents: .date)
                                .labelsHidden()
                        }

                        Spacer()

                        // Label Color
                        VStack(alignment: .trailing) {
                            Text("Label Color")
                                .font(.headline)

                            ColorPicker("", selection: $labelColor)
                        }
                    }

                    // Status
//                    Text("Status")
//                        .font(.headline)
//                    Picker("Status", selection: $status) {
//                        Text("Not Taken").tag(MedicineTakingStatus.notTaken)
//                        Text("Taken").tag(MedicineTakingStatus.taken)
//                        Text("Missed").tag(MedicineTakingStatus.missed)
//                    }
//                    .pickerStyle(SegmentedPickerStyle())

                    // Taken Time (conditional)
                    if status == .taken {
                        Text("Taken Time")
                            .font(.headline)
                        DatePicker("Select time", selection: Binding(
                            get: { takenTime ?? Date() },
                            set: { takenTime = $0 }
                        ), displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }

                    // Notes
                    Text("Notes (Optional)")
                        .font(.headline)
                    TextField("Enter any additional notes", text: $notes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    // Show List of Medicines
                    if !medicines.isEmpty {
                        Text("Medicines to be Saved (\(medicines.count))")
                            .font(.headline)
                        ForEach(Array(medicines.enumerated()), id: \.offset) { index, medicine in
                            MedicineListItemToBeSavedView(medicine: medicine, onEdit: { startEditingMedicine(at: index) })
                        }
                    }
                }
                .padding()
            }
            .withKeyboardCloseButton()
            .navigationTitle("Add Medicine")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: Binding(
                get: { selectedMedicineList != nil },
                set: { if !$0 { selectedMedicineList = nil } }
            )) {
                if let medicines = selectedMedicineList {
                    ConfirmSaveMedicineView(medicines: medicines)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if medicines.isEmpty {
                            showValidationError = true
                        } else {
                            selectedMedicineList = medicines
                        }
                    }
                }

            }.safeAreaInset(edge: .bottom) {
                ReButton(title: editingMedicineIndex == nil ? "Add Medicine" : "Update Medicine",
                         type: editingMedicineIndex == nil ? .base : .warning,
                         onPressed: {
                             addOrUpdateMedicine()
                         }, isFullWidth: true)
                    .padding()
                    .background(.gray25)
                    .overlay(
                        Divider()
                            .background(Color.gray.opacity(0.5))
                            .frame(height: 1)
                            .frame(maxWidth: .infinity),
                        alignment: .top
                    )
            }
            .alert("Error", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please add at least one medicine before saving.")
            }
        }
    }

    private func addOrUpdateMedicine() {
        guard !medicineName.isEmpty, !dosage.isEmpty else {
            showValidationError = true
            return
        }

        let whenToTakeValue = whenToTake == "Custom" ? customWhenToTake : whenToTake

        let newMedicine = Medicine(
            name: medicineName,
            dosage: dosage,
            scheduleTime: scheduleTime,
            occurrence: selectedOccurrence,
            startDate: selectedOccurrence == .custom ? startDate : nil,
            endDate: selectedOccurrence == .custom ? endDate : nil,
            whenToTake: whenToTakeValue,
            expiryDate: expiryDate.formatted(date: .numeric, time: .omitted),
            notes: notes,
            labelColor: labelColor,
            status: status,
            takenTime: takenTime
        )

        if let index = editingMedicineIndex {
            medicines[index] = newMedicine // Update existing medicine
            editingMedicineIndex = nil // Reset editing state
        } else {
            medicines.append(newMedicine) // Add new medicine
        }
        resetForm()
    }

    private func startEditingMedicine(at index: Int) {
        let medicine = medicines[index]
        editingMedicineIndex = index

        // Set data untuk form
        medicineName = medicine.name
        dosage = medicine.dosage
        scheduleTime = medicine.scheduleTime
        selectedOccurrence = medicine.occurrence
        startDate = medicine.startDate ?? Date()
        endDate = medicine.endDate ?? Date().addingTimeInterval(24 * 60 * 60)
        notes = medicine.notes

        // Konversi expiryDate (String) menjadi Date
        if let expiryDateString = medicine.expiryDate,
           let expiryDateValue = DateFormatter.expiryDateFormatter.date(from: expiryDateString)
        {
            expiryDate = expiryDateValue
        } else {
            expiryDate = Date().addingTimeInterval(365 * 24 * 60 * 60) // Default 1 tahun ke depan
        }

        labelColor = medicine.labelColor
        status = medicine.status
        takenTime = medicine.takenTime

        // Set untuk custom when to take
        if let customWhen = medicine.whenToTake, customWhen != "Before meals" && customWhen != "After meals" && customWhen != "Anytime" {
            whenToTake = "Custom"
            customWhenToTake = customWhen
        } else {
            whenToTake = medicine.whenToTake ?? "After meals"
            customWhenToTake = ""
        }
    }

    private func resetForm() {
        medicineName = ""
        dosage = ""
        scheduleTime = Date()
        notes = ""
        startDate = Date()
        endDate = Date().addingTimeInterval(24 * 60 * 60)
        selectedOccurrence = .oneDay
        whenToTake = "After meals"
        customWhenToTake = ""
        expiryDate = Date().addingTimeInterval(365 * 24 * 60 * 60)
        labelColor = .blue
        status = .notTaken
        takenTime = nil
    }
}

struct ConfirmMedicineListItemView: View {
    let medicine: Medicine

    var body: some View {
        let isDarkBackground = medicine.labelColor.isDark()
        let textColor: Color = isDarkBackground ? .white : .black

        VStack(alignment: .leading) {
            HStack {
                Text(medicine.name)
                    .style(.textLg(.bold))
                    .foregroundStyle(textColor)
                Spacer()
            }
            .padding()
            .background(medicine.labelColor)

            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Dosage: ")
                            .style(.textMd(.semiBold))
                        Text(medicine.dosage)
                            .style(.textMd(.regular))
                            .foregroundStyle(.gray800)
                    }
                    HStack {
                        Text("Time: ")
                            .style(.textMd(.semiBold))
                        Text(medicine.scheduleTime.formatted(date: .omitted, time: .shortened))
                            .style(.textMd(.regular))
                            .foregroundStyle(.gray800)
                    }
                    if medicine.occurrence == .custom {
                        Text("From: \(medicine.startDate?.formatted(date: .abbreviated, time: .omitted) ?? "-") to \(medicine.endDate?.formatted(date: .abbreviated, time: .omitted) ?? "-")")
                            .style(.textMd(.semiBold))
                    } else {
                        HStack {
                            Text("Occurrence: ")
                                .style(.textMd(.semiBold))
                            Text(medicine.occurrence.rawValue)
                                .style(.textMd(.regular))
                                .foregroundStyle(.gray800)
                        }
                    }
                    if !medicine.notes.isEmpty {
                        HStack {
                            Text("Notes: ")
                                .style(.textMd(.semiBold))
                            Text(medicine.notes)
                                .style(.textMd(.regular))
                                .foregroundStyle(.gray800)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(style: StrokeStyle(lineWidth: 2))
                .foregroundColor(medicine.labelColor)
        )
        .cornerRadius(8)
    }
}

struct ConfirmSaveMedicineView: View {
    let medicines: [Medicine]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(medicines) { medicine in
                        ConfirmMedicineListItemView(medicine: medicine)
                    }
                }
                .padding()
            }
            //        .background(Color.gray.opacity(0.05))
            .navigationTitle("Confirm Save")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // TODO: save
                    }
                }
            }
        }
    }
}

struct MedicineListItemToBeSavedView: View {
    let medicine: Medicine
    let onEdit: () -> Void // Closure untuk menangani tombol edit

    var body: some View {
        let isDarkBackground = medicine.labelColor.isDark()
        let textColor: Color = isDarkBackground ? .white : .black

        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(medicine.name)
                    .style(.textLg(.bold))
                    .foregroundStyle(textColor)

                Spacer()
                Button(action: onEdit) {
                    Ph.notePencil.fill.resizable().frame(width: 24, height: 24)
                        .foregroundStyle(textColor)
                }
            }
            .padding()
            .background(medicine.labelColor)

            VStack(alignment: .leading) {
                HStack {
                    Text("Dosage: ")
                        .style(.textMd(.semiBold))
                    Text(medicine.dosage)
                        .style(.textMd(.regular))
                        .foregroundStyle(.gray800)
                }
                HStack {
                    Text("Time: ")
                        .style(.textMd(.semiBold))
                    Text(medicine.scheduleTime.formatted(date: .omitted, time: .shortened))
                        .style(.textMd(.regular))
                        .foregroundStyle(.gray800)
                }
                if medicine.occurrence == .custom {
                    Text("From: \(medicine.startDate?.formatted(date: .abbreviated, time: .omitted) ?? "-") to \(medicine.endDate?.formatted(date: .abbreviated, time: .omitted) ?? "-")")
                        .style(.textMd(.semiBold))
                } else {
                    HStack {
                        Text("Occurrence: ")
                            .style(.textMd(.semiBold))
                        Text(medicine.occurrence.rawValue)
                            .style(.textMd(.regular))
                            .foregroundStyle(.gray800)
                    }
                }
                if !medicine.notes.isEmpty {
                    HStack {
                        Text("Notes: ")
                            .style(.textMd(.semiBold))
                        Text(medicine.notes)
                            .style(.textMd(.regular))
                            .foregroundStyle(.gray800)
                    }
                }
            }
            .padding(16)
        
        }
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(medicine.labelColor, lineWidth: 2)
        )
        .cornerRadius(8)
    }
}

#Preview("AddMedicineView") {
    AddMedicineView()
}

#Preview("MedicineListItem") {
    MedicineListItemToBeSavedView(
        medicine: Medicine(
            name: "Vitamin C 500mg",
            dosage: "1 tablet",
            scheduleTime: Date(),
            occurrence: .oneDay,
            startDate: nil,
            endDate: nil,
            whenToTake: "After meals",
            expiryDate: "12/12/2025",
            notes: "Take with a glass of water",
            labelColor: .yellow,
            status: .notTaken,
            takenTime: nil
        ),
        onEdit: {}
    )
}

#Preview("ConfirmSaveMedicineView") {
    ConfirmSaveMedicineView(
        medicines: medicinesDummyData
    )
}
