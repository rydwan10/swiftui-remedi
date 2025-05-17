import SwiftUI
import PhosphorSwift

struct NotificationView: View {
    @EnvironmentObject var mainTabBarVisibility: MainTabBarVisibility
    let notifications: [NotificationItem] = [
        NotificationItem(icon: Ph.bell.fill, title: "Medicine Reminder", subtitle: "Take Paracetamol 500mg", time: "08:00 AM", color: .brand600),
        NotificationItem(icon: Ph.pill.fill, title: "New Medicine Added", subtitle: "Ibuprofen 200mg added to your schedule", time: "Yesterday", color: .success600),
        NotificationItem(icon: Ph.checkCircle.fill, title: "Medicine Taken", subtitle: "You took Vitamin C 500mg", time: "2 days ago", color: .success600),
        NotificationItem(icon: Ph.xCircle.fill, title: "Missed Dose", subtitle: "You missed Amoxicillin 500mg", time: "3 days ago", color: .error600),
        NotificationItem(icon: Ph.info.fill, title: "App Update", subtitle: "ReMedi v1.1 is now available!", time: "Last week", color: .brand600)
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(notifications) { notification in
                    NotificationRow(item: notification)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .background(Color.gray25)
            .navigationTitle("Notifications")
        
        }
        .onAppear() {
            withAnimation {
                mainTabBarVisibility.showTabBar = false
            }
        }
        .onDisappear() {
            withAnimation {
                mainTabBarVisibility.showTabBar = true
            }
        }
    }
}

struct NotificationItem: Identifiable {
    let id = UUID()
    let icon: Image
    let title: String
    let subtitle: String
    let time: String
    let color: Color
}

struct NotificationRow: View {
    let item: NotificationItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            item.icon
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(item.color)
                .padding(8)
                .background(item.color.opacity(0.1))
                .clipShape(Circle())
           
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .style(.textMd(.bold))
                Text(item.subtitle)
                    .style(.textSm(.regular))
                    .foregroundStyle(.gray600)
                Text(item.time)
                    .style(.textXs(.regular))
                    .foregroundStyle(.gray400)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        
    }
}

#Preview {
    NotificationView()
        .environmentObject(MainTabBarVisibility())
}
