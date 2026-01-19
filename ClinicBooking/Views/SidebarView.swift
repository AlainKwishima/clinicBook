
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
        VStack(alignment: .leading, spacing: 0) {
            // Custom Brand Header (Centered)
            VStack(alignment: .center, spacing: 6) {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 45, height: 45) // Slightly larger branding
                    .cornerRadius(10)
                
                Text("Clinic Booking")
                    .font(.customFont(style: .bold, size: .h14))
                    .foregroundColor(.text)
            }
            .frame(maxWidth: .infinity) // Ensure full width for centering
            .padding(.top, 25)
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
            .background(Color.bg)
            
            // Navigation List
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
            .scrollContentBackground(.hidden) 
        }
        .background(Color.bg.ignoresSafeArea())
        .navigationTitle("") 
        .navigationBarTitleDisplayMode(.inline) // Shrink title area
        .navigationBarHidden(true) // Explicitly hide nav bar (older modifier sometimes works better in split view columns)
        .toolbar(.hidden, for: .navigationBar) // Newer modifier
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
