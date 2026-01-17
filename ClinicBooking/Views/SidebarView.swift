
import SwiftUI

enum SidebarItem: Int, CaseIterable, Identifiable {
    case home = 0
    case appointments = 1
    case recordsOrHistory = 2
    case saved = 3
    case profile = 4
    
    var id: Int { self.rawValue }
    
    func title(for role: String) -> String {
        switch self {
        case .home: return "Home"
        case .appointments: return "Appointments"
        case .recordsOrHistory: return role == "doctor" ? "History" : "Medical Records"
        case .saved: return "Saved"
        case .profile: return "Profile"
        }
    }
    
    func icon(for role: String) -> String {
        switch self {
        case .home: return "house.fill"
        case .appointments: return "calendar"
        case .recordsOrHistory: return role == "doctor" ? "clock.arrow.circlepath" : "text.book.closed.fill"
        case .saved: return "heart"
        case .profile: return "person.fill"
        }
    }
}

struct SidebarView: View {
    let role: String
    @Binding var selectedIndex: Int
    
    var body: some View {
        List(filteredItems, selection: $selectedIndex) { item in
            NavigationLink(value: item.rawValue) {
                Label(item.title(for: role), systemImage: item.icon(for: role))
                    .font(.customFont(style: .medium, size: .h16))
                    .foregroundColor(selectedIndex == item.rawValue ? .white : .text)
            }
            .listRowBackground(
                selectedIndex == item.rawValue ? Color.appBlue : Color.clear
            )
            .cornerRadius(8)
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Menu")
        .background(Color.bg.ignoresSafeArea())
    }
    
    private var filteredItems: [SidebarItem] {
        if role == "doctor" {
            // Doctor only has 4 tabs: Home, Appts, History, Profile
            return [.home, .appointments, .recordsOrHistory, .profile]
        } else {
            // Patient has 5 tabs
            return SidebarItem.allCases
        }
    }
}
