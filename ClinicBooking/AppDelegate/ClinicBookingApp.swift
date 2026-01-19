//
//  ClinicBookingApp.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 01/09/24.
//

import SwiftUI
// import FirebaseCore  // DEPRECATED: Migrated to Supabase
// import FirebaseAuth  // DEPRECATED: Migrated to Supabase
import Supabase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // FirebaseApp.configure()  // DEPRECATED: Now using Supabase
    return true
  }
}

@main
struct ClinicBookingApp: App {
    // register app delegate for Firebase setup
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            SplashViewCoordinator()
        }
    }
}

struct AppRootView: View {
    @State var isAuthenticated: Bool = false
    @State var isPendingVerification: Bool = false
    @State var isDoctor: Bool = false
    @State var isLoading: Bool = true
    @State private var rootViewId = UUID()
    @AppStorage("userID") var storedUserID: String = ""

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView("Authenticating...")
                }
            } else if isAuthenticated {
                if isDoctor {
                     DoctorHomeDashboard()
                } else {
                    HomeDashboard()
                }
            } else {
                NavigationStack {
                    RoleSelectionView()
                }
                .id(rootViewId)
            }
        }
        .onAppear(perform: listenToAuthState)
    }
    
    // Listens for Supabase auth state changes to handle login/logout reactively
    private func listenToAuthState() {
        Task {
            for await state in SupabaseManager.shared.client.auth.authStateChanges {
                if let session = state.session {
                    print("Auth state changed: Active session for user: \(session.user.id)")
                    storedUserID = session.user.id.uuidString
                    await fetchUserStatus(uid: session.user.id.uuidString)
                } else {
                    print("Auth state changed: No active session.")
                    storedUserID = ""
                    DispatchQueue.main.async {
                        self.isAuthenticated = false
                        self.isPendingVerification = false
                        self.isLoading = false
                        self.rootViewId = UUID()
                    }
                }
            }
        }
    }
    
    private func fetchUserStatus(uid: String) async {
        await SupabaseDBManager.shared.getUserDetails(userId: uid) { result in
             DispatchQueue.main.async {
                 if let user = UserDefaults.standard.value(AppUser.self, forKey: "userDetails") {
                     self.isAuthenticated = true
                     if user.role == "doctor" {
                         self.isDoctor = true
                         self.isPendingVerification = (user.verificationStatus == "pending")
                     } else {
                         self.isDoctor = false
                         self.isPendingVerification = false
                     }
                 } else {
                     // Check if we can fallback to basic auth if firestore fails temporarily
                     self.isAuthenticated = true 
                 }
                 self.isLoading = false
                 self.rootViewId = UUID() // Force refresh
             }
        }
    }
}
