//
//  ScheduleView.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 17/05/25.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject private var medicineDataManager: MedicineDataManager
    @EnvironmentObject private var tabBarVisibility: MainTabBarVisibility
    @State private var selectedDate: Date = .init()
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var navigateToCalendar: Bool = false
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }
    
    private var dates: [Date] {
        let today = calendar.startOfDay(for: Date())
        let pastDates = (0 ... 30).map { days in
            calendar.date(byAdding: .day, value: -days, to: today)!
        }
        let futureDates = (1 ... 30).map { days in
            calendar.date(byAdding: .day, value: days, to: today)!
        }
        let allDates = (pastDates + futureDates).sorted()
        return allDates
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Button to navigate to full calendar view
                HStack {
                    Spacer()
                    Button(action: {
                        navigateToCalendar = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                            Text("Full Calendar")
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.brand600)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
                
                // Date Selector
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(dates, id: \.self) { date in
                                DayView(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate))
                                    .id(date) // Add id for scrolling
                                    .onTapGesture {
                                        withAnimation {
                                            selectedDate = date
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    .onAppear {
                        scrollProxy = proxy
                        // Scroll to today's date with animation
                        withAnimation {
                            proxy.scrollTo(calendar.startOfDay(for: Date()), anchor: .trailing)
                        }
                    }
                }
                
                // Selected Date's Schedule
                VStack(alignment: .leading, spacing: 16) {
                    Text("Schedule for \(selectedDate.formatted(date: .long, time: .omitted))")
                        .style(.textLg(.bold))
                    
                    if let medicines = medicinesForSelectedDate {
                        ForEach(medicines) { medicine in
                            MedicineScheduleItem(medicine: medicine)
                        }
                    } else {
                        Text("No medicines scheduled for this day")
                            .style(.textMd(.regular))
                            .foregroundStyle(.gray600)
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Schedule")
            .navigationDestination(isPresented: $navigateToCalendar) {
                MonthlyCalendarView()
            }
        }
    }
    
    private var medicinesForSelectedDate: [Medicine]? {
        return medicineDataManager.medicines.filter { medicine in
            guard let startDate = medicine.startDate, let endDate = medicine.endDate else {
                return false
            }
            return calendar.isDate(selectedDate, inSameDayAs: medicine.scheduleTime) ||
                (selectedDate >= startDate && selectedDate <= endDate)
        }
    }
}

struct DayView: View {
    let date: Date
    let isSelected: Bool
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayOfMonth)
                .style(.textLg(.bold))
                .foregroundStyle(isSelected ? .white : .gray900)
            
            Text(monthYear)
                .style(.textSm(.regular))
                .foregroundStyle(isSelected ? .white.opacity(0.8) : .gray600)
        }
        .frame(width: 80, height: 80)
        .background(isSelected ? Color.brand600 : Color.gray50)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.brand600 : Color.gray300, lineWidth: 1)
        )
    }
    
    private var dayOfMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var monthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

struct MedicineScheduleItem: View {
    let medicine: Medicine
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(medicine.name)
                    .style(.textMd(.bold))
                
                Text(medicine.scheduleTime.formatted(date: .omitted, time: .shortened))
                    .style(.textSm(.regular))
                    .foregroundStyle(.gray600)
                
                Text(medicine.dosage)
                    .style(.textSm(.regular))
                    .foregroundStyle(.gray600)
            }
            
            Spacer()
            
            MedicineStatusView(medicineTakingStatus: medicine.status, time: medicine.takenTime?.formatted(date: .omitted, time: .shortened))
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray300, lineWidth: 1)
        )
    }
}

#Preview {
    ScheduleView()
        .environmentObject(MedicineDataManager())
}
