import SwiftUI

struct MonthlyCalendarView: View {
    @EnvironmentObject private var medicineDataManager: MedicineDataManager
    @EnvironmentObject private var mainTabBarVisibility: MainTabBarVisibility
    @State private var showSheet: Bool = false
    @State private var sheetDate: Date = .init()
    @State private var showFilterSheet: Bool = false
    @State private var filterFrom: Date = Calendar.current.date(byAdding: .month, value: -6, to: Calendar.current.startOfDay(for: Date())) ?? Date()
    @State private var filterTo: Date = Calendar.current.date(byAdding: .month, value: 6, to: Calendar.current.startOfDay(for: Date())) ?? Date()
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }
    
    private var months: [Date] {
        let from = calendar.startOfDay(for: filterFrom)
        let to = calendar.startOfDay(for: filterTo)
        guard from <= to else { return [] }
        var months: [Date] = []
        var current = from
        while current <= to {
            months.append(current)
            current = calendar.date(byAdding: .month, value: 1, to: current)!
        }
        return months
    }
    
    private func daysInMonth(for date: Date) -> [Date] {
        let components = calendar.dateComponents([.year, .month], from: date)
        let startOfMonth = calendar.date(from: components)!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    private func firstWeekdayOfMonth(for date: Date) -> Int {
        let components = calendar.dateComponents([.year, .month], from: date)
        let startOfMonth = calendar.date(from: components)!
        return calendar.component(.weekday, from: startOfMonth)
    }
    
    private func medicines(for date: Date) -> [Medicine] {
        medicineDataManager.medicines.filter { medicine in
            guard let startDate = medicine.startDate, let endDate = medicine.endDate else { return false }
            return calendar.isDate(date, inSameDayAs: medicine.scheduleTime) ||
                (date >= startDate && date <= endDate)
        }
    }
    
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(months, id: \.self) { monthDate in
                        VStack(spacing: 8) {
                            Text(monthDate.formatted(.dateTime.month().year()))
                                .font(.title2).bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            // Days of week header
                            HStack {
                                ForEach(daysOfWeek, id: \.self) { day in
                                    Text(day)
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                            // Calendar grid
                            let days = daysInMonth(for: monthDate)
                            let leadingEmptyDays = (firstWeekdayOfMonth(for: monthDate) - calendar.firstWeekday + 7) % 7
                            let totalDays = days.count + leadingEmptyDays
                            let rows = Int(ceil(Double(totalDays) / 7.0))
                            ForEach(0..<rows, id: \.self) { row in
                                HStack(spacing: 0) {
                                    ForEach(0..<7, id: \.self) { col in
                                        let index = row * 7 + col
                                        if index < leadingEmptyDays || index - leadingEmptyDays >= days.count {
                                            Spacer().frame(maxWidth: .infinity, minHeight: 48)
                                        } else {
                                            let date = days[index - leadingEmptyDays]
                                            let isToday = calendar.isDateInToday(date)
                                            let hasMedicine = !medicines(for: date).isEmpty
                                            Button(action: {
                                                sheetDate = date
                                                showSheet = true
                                            }) {
                                                ZStack {
                                                    if isToday {
                                                        Circle()
                                                            .fill(Color.brand600)
                                                            .frame(width: 36, height: 36)
                                                    } else if hasMedicine {
                                                        Circle()
                                                            .stroke(Color.brand600, lineWidth: 2)
                                                            .frame(width: 36, height: 36)
                                                    }
                                                    Text("\(calendar.component(.day, from: date))")
                                                        .foregroundColor(isToday ? .white : .primary)
                                                }
                                                .frame(maxWidth: .infinity, minHeight: 48)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .id(monthDate.formatted(.dateTime.year().month())) // Assign id for scroll
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Monthly Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .onAppear {
                withAnimation {
                    mainTabBarVisibility.showTabBar = false
                }

                let today = calendar.startOfDay(for: Date())
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        scrollProxy.scrollTo(today.formatted(.dateTime.year().month()), anchor: .center)
                    }
                }
            }
            .onDisappear {
                withAnimation {
                    mainTabBarVisibility.showTabBar = true
                }
            }
            .sheet(isPresented: $showSheet) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(sheetDate.formatted(date: .long, time: .omitted))
                            .font(.title2).bold()
                        Spacer()
                        Button(action: { showSheet = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, 4)
                    Divider()
                        .padding(.bottom, 8)
                    if medicines(for: sheetDate).isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal")
                                .foregroundColor(.green)
                            Text("No medicines scheduled for this day")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 32)
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(medicines(for: sheetDate)) { medicine in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "pills.fill")
                                        .font(.title2)
                                        .foregroundColor(.brand600)
                                        .padding(.top, 2)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(medicine.name)
                                            .font(.headline)
                                        HStack(spacing: 8) {
                                            Image(systemName: "clock")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            Text(medicine.scheduleTime.formatted(date: .omitted, time: .shortened))
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        if !medicine.dosage.isEmpty {
                                            HStack(spacing: 8) {
                                                Image(systemName: "drop.fill")
                                                    .font(.subheadline)
                                                    .foregroundColor(.blue)
                                                Text(medicine.dosage)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    Spacer()
                }
                .padding()
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showFilterSheet) {
                NavigationView {
                    Form {
                        Section(header: Text("From")) {
                            DatePicker(
                                "From",
                                selection: Binding(
                                    get: { filterFrom },
                                    set: { newFrom in
                                        filterFrom = newFrom
                                        // If TO is before FROM, adjust TO
                                        if filterTo < filterFrom {
                                            filterTo = filterFrom
                                        }
                                        // If TO is more than 1 year after FROM, adjust TO
                                        let maxTo = calendar.date(byAdding: .year, value: 1, to: filterFrom)!
                                        if filterTo > maxTo {
                                            filterTo = maxTo
                                        }
                                    }
                                ),
                                displayedComponents: [.date]
                            )
                        }
                        Section(header: Text("To")) {
                            DatePicker(
                                "To",
                                selection: $filterTo,
                                in: filterFrom ... calendar.date(byAdding: .year, value: 1, to: filterFrom)!,
                                displayedComponents: [.date]
                            )
                        }
                    }
                    .navigationTitle("Filter Range")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showFilterSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Apply") { showFilterSheet = false }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MonthlyCalendarView()
        .environmentObject(MedicineDataManager())
        .environmentObject(MainTabBarVisibility())
}
