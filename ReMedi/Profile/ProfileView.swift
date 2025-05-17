import PhosphorSwift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var medicineDataManager: MedicineDataManager
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Image
                        ZStack {
                            Circle()
                                .fill(Color.brand100)
                                .frame(width: 120, height: 120)
                            
                            Ph.user.fill
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundStyle(.brand600)
                        }
                        
                        // User Info
                        VStack(spacing: 8) {
                            Text("John Doe")
                                .style(.textXl(.bold))
                            
                            Text("john.doe@example.com")
                                .style(.textMd(.regular))
                                .foregroundStyle(.gray600)
                        }
                    }
                    .padding(.vertical, 24)
                    
                    // Stats Section
                    HStack(spacing: 16) {
                        StatCard(
                            icon: Ph.pill.fill,
                            title: "Medicines",
                            value: "\(medicineDataManager.medicines.count)",
                            color: .brand600
                        )
                        
                        StatCard(
                            icon: Ph.checkCircle.fill,
                            title: "Taken",
                            value: "\(medicineDataManager.medicines.filter { $0.status == .taken }.count)",
                            color: .success600
                        )
                        
                        StatCard(
                            icon: Ph.xCircle.fill,
                            title: "Missed",
                            value: "\(medicineDataManager.medicines.filter { $0.status == .missed }.count)",
                            color: .error600
                        )
                    }
                    .padding(.horizontal)
                    
                    // Settings Section
                    VStack(spacing: 16) {
                        SettingsSection(title: "Account") {
                            SettingsRow(icon: Ph.user.fill, title: "Personal Information", color: .brand600)
                            SettingsRow(icon: Ph.bell.fill, title: "Notifications", color: .warning600)
                            SettingsRow(icon: Ph.lock.fill, title: "Privacy & Security", color: .gray600)
                        }
                        
                        SettingsSection(title: "Preferences") {
                            SettingsRow(icon: Ph.globe.fill, title: "Language", color: .brand600)
                            SettingsRow(icon: Ph.moon.fill, title: "Dark Mode", color: .gray600)
                            SettingsRow(icon: Ph.clock.fill, title: "Time Format", color: .brand600)
                        }
                        
                        SettingsSection(title: "Support") {
                            SettingsRow(icon: Ph.question.fill, title: "Help Center", color: .brand600)
                            SettingsRow(icon: Ph.info.fill, title: "About", color: .gray600)
                            SettingsRow(icon: Ph.signOut.fill, title: "Sign Out", color: .error600)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 49) // Tab bar height
            }
            .navigationTitle("Profile")
            .background(Color.gray25)
        }
    }
}

struct StatCard: View {
    let icon: Image
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            icon
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(color)
            
            Text(value)
                .style(.textXl(.bold))
            
            Text(title)
                .style(.textSm(.regular))
                .foregroundStyle(.gray600)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray200, lineWidth: 1)
        )
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .style(.textLg(.bold))
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray200, lineWidth: 1)
            )
        }
    }
}

struct SettingsRow: View {
    let icon: Image
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            icon
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(color)
            
            Text(title)
                .style(.textMd(.regular))
            
            Spacer()
            
            Ph.caretRight.regular
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(.gray400)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle tap
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(MedicineDataManager())
}
