//
//  ContentView.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 12/04/25.
//

import Inject
import PhosphorSwift
import SwiftUI

enum Tab: Int {
    case home = 1
    case schedule
    case addOccurrence
    case history
    case profile
}

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject private var tabBarVisibility: MainTabBarVisibility

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(Tab.home)
                .toolbar(.hidden, for: .tabBar)

            ScheduleView()
                .tag(Tab.schedule)
                .toolbar(.hidden, for: .tabBar)

            EmptyView()
                .tag(Tab.addOccurrence)
                .toolbar(.hidden, for: .tabBar)

            HistoryView()
                .tag(Tab.history)
                .toolbar(.hidden, for: .tabBar)

            ProfileView()
                .tag(Tab.profile)
                .toolbar(.hidden, for: .tabBar)
        }
        .overlay(alignment: .bottom) {
            if tabBarVisibility.showTabBar {
                CustomTabBar(selectedTab: $selectedTab)
                    .background(Color.gray100.ignoresSafeArea(edges: .bottom))
            }
        }
//        .background(
//            Color.gray25
//                .ignoresSafeArea(edges: .bottom)
//        )
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @State var isSheetPresented: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Divider()
                    .background(Color.gray.opacity(0.5))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)

                HStack {
                    Spacer()
                    TabBarButton(tab: .home, icon: (selectedTab == .home) ? Ph.house.fill : Ph.house.regular, label: "Home", selectedTab: $selectedTab)
                    Spacer()
                    TabBarButton(tab: .schedule, icon: (selectedTab == .schedule) ? Ph.clock.fill : Ph.clock.regular, label: "Schedule", selectedTab: $selectedTab)
                    Spacer()
                    Button(action: {
                        isSheetPresented.toggle()
                    }) {
                        VStack {
                            (Ph.plusCircle.fill)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.brand600)

                            Text("Add")
                                .style(.textSm(.regular))
                                .foregroundStyle(.gray600)
                        }
                        .padding(8)
                    }
                    .sheet(isPresented: $isSheetPresented) {
                        AddMedicineView()
                    }
                    Spacer()
                    TabBarButton(tab: .history, icon: (selectedTab == .history) ? Ph.archive.fill : Ph.archive.regular, label: "History", selectedTab: $selectedTab)
                    Spacer()
                    TabBarButton(tab: .profile, icon: (selectedTab == .profile) ? Ph.user.fill : Ph.user.regular, label: "Profile", selectedTab: $selectedTab)
                    Spacer()
                }
                .padding(.vertical, 10)
            }
            .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
    }
}

struct TabBarButton: View {
    let tab: Tab
    let icon: Image
    let label: String
    @Binding var selectedTab: Tab

    var body: some View {
        VStack {
            icon
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(selectedTab == tab ? .brand400 : .gray600)

            Text(label)
                .style(.textSm(selectedTab == tab ? .bold : .regular))
                .foregroundStyle(selectedTab == tab ? .brand400 : .gray600)
        }
        .padding(8)
        .onTapGesture {
            selectedTab = tab
        }
    }
}

// MARK: - Previews

#Preview("ContentView") {
    @Previewable var medicineDataManager = MedicineDataManager()
    @Previewable var mainTabBarVisibility = MainTabBarVisibility()

    ContentView()

        .environmentObject(medicineDataManager)
        .environmentObject(mainTabBarVisibility)
}
