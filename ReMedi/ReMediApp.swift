//
//  ReMediApp.swift
//  ReMedi
//
//  Created by Muhammad Rydwan on 12/04/25.
//


import SwiftUI

@main
struct ReMediApp: App {
    @StateObject private var medicineDataManager = MedicineDataManager()
    @StateObject private var tabBarVisibility = MainTabBarVisibility()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(medicineDataManager)
                .environmentObject(tabBarVisibility)
        }
    }
}
