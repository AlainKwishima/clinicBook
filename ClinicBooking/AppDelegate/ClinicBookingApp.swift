//
//  ClinicBookingApp.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 01/09/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
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
                NavigationStack {
                    if isDoctor {
                         DoctorHomeDashboard()
                            .navigationBarBackButtonHidden(true)
                    } else {
                        HomeDashboard()
                            .navigationBarBackButtonHidden(true)
                    }
                }
                .id(rootViewId)
            } else {
                NavigationStack {
                    RoleSelectionView()
                }
                .id(rootViewId)
            }
        }
        .onAppear(perform: listenToAuthState)
    }
    
    @State private var authStateHandle: AuthStateDidChangeListenerHandle?

    private func listenToAuthState() {
        self.authStateHandle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                print("Auth State Change: User is signed in with \(user.uid)")
                storedUserID = user.uid
                Task {
                    await fetchUserStatus(uid: user.uid)
                }
            } else {
                print("Auth State Change: No user is signed in.")
                storedUserID = ""
                self.isAuthenticated = false
                self.isPendingVerification = false
                self.isLoading = false
                self.rootViewId = UUID()
            }
        }
    }
    
    private func fetchUserStatus(uid: String) async {
        await FireStoreManager.shared.getUserDetails(userId: uid) { result in
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
