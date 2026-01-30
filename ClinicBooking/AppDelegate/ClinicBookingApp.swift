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
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if granted {
            print("Notification permission granted.")
        } else if let error = error {
            print("Notification permission error: \(error.localizedDescription)")
        }
    }
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
    @StateObject private var authViewModel = AuthenticationViewModel()
    @State var isAuthenticated: Bool = false
    @State var isPendingVerification: Bool = false
    @State var isProfileIncomplete: Bool = false
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
                if isProfileIncomplete {
                    NavigationStack {
                        AdditionalInfoView(viewModel: authViewModel, isRegistrationFlow: false)
                    }
                } else if isDoctor {
                    if isPendingVerification {
                        DoctorVerificationView()
                    } else {
                        DoctorHomeDashboard()
                    }
                } else {
                    HomeDashboard()
                }
            } else {
                NavigationStack {
                    RoleSelectionView()
                }
            }
        }
        .onAppear(perform: listenToAuthState)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AppLogout"))) { _ in
            print("🔴 AppLogout notification received - forcing navigation back to login")
            DispatchQueue.main.async {
                // Clear all local auth state
                self.storedUserID = ""
                UserDefaults.standard.removeObject(forKey: "userID")
                UserDefaults.standard.removeObject(forKey: "userDetails")
                
                self.isAuthenticated = false
                self.isPendingVerification = false
                self.isProfileIncomplete = false
                self.isDoctor = false
                self.isLoading = false
                self.rootViewId = UUID()
                print("✅ AppLogout: Local state cleared and view reset")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AuthStatusChanged"))) { _ in
            print("🔵 AuthStatusChanged notification received - refreshing user status")
            
            // If we are logged out, ignore this.
            if storedUserID.isEmpty {
                print("⚠️ DEBUG: AuthStatusChanged ignored - storedUserID is empty")
                return
            }
            
            // Wait a very short moment for any pending database writes to complete
            Task {
                try? await Task.sleep(nanoseconds: 200_000_000) // 200ms delay
                if !storedUserID.isEmpty {
                    await fetchUserStatus(uid: storedUserID)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SignupFlowStarted"))) { _ in
            print("🔵 DEBUG: SignupFlowStarted - disabling auth listener navigation")
            SupabaseAuthService.shared.isSignUpFlowInProgress = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SignupFlowCompleted"))) { _ in
            print("🔵 DEBUG: SignupFlowCompleted - re-enabling auth listener navigation")
            SupabaseAuthService.shared.isSignUpFlowInProgress = false
        }
    }
    
    // Listens for Supabase auth state changes to handle login/logout reactively
    private func listenToAuthState() {
        Task {
            for await state in SupabaseManager.shared.client.auth.authStateChanges {
                // Skip auth state processing if user is actively in signup flow
                if SupabaseAuthService.shared.isSignUpFlowInProgress {
                    print("⚠️ DEBUG: Auth state change detected but ignoring - signup flow in progress")
                    continue
                }
                
                if let session = state.session {
                    print("🔵 [AUTH_TRACE] Active session detected: \(session.user.id)")
                    let userIdString = session.user.id.uuidString
                    storedUserID = userIdString
                    UserDefaults.standard.set(userIdString, forKey: "userID")
                    await fetchUserStatus(uid: userIdString)
                } else {
                    print("⚠️ [AUTH_TRACE] No active session received.")
                    
                    // STICKY AUTH LOGIC:
                    // If we have a storedUserID (session might be refreshing or transiently lost),
                    // we don't immediately drop to the login screen.
                    if !storedUserID.isEmpty {
                        print("ℹ️ [AUTH_TRACE] storedUserID exists (\(storedUserID)). Waiting 1s for session recovery...")
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        
                        // Re-check after delay
                        if let currentSession = try? await SupabaseManager.shared.client.auth.session {
                            print("✅ [AUTH_TRACE] Session recovered after delay.")
                            continue 
                        }
                    }
                    
                    print("🔴 [AUTH_TRACE] Navigating to login (No session & no recovery)")
                    storedUserID = ""
                    DispatchQueue.main.async {
                        self.isAuthenticated = false
                        self.isPendingVerification = false
                        self.isDoctor = false
                        self.isLoading = false
                        print("🔴 [AUTH_TRACE] AppRootView: Logged out state finalized")
                    }
                }
            }
        }
    }
    
    private func fetchUserStatus(uid: String) async {
        // Skip if signup flow is in progress to prevent interference
        if SupabaseAuthService.shared.isSignUpFlowInProgress {
            print("⚠️ DEBUG: fetchUserStatus skipped - signup flow in progress")
            return
        }
        
        // Critical: If uid is empty, we must be logged out
        if uid.isEmpty {
            print("🔴 fetchUserStatus - uid is empty, ensuring logout state")
            await MainActor.run {
                self.isAuthenticated = false
                self.isLoading = false
                // Removed rootViewId = UUID()
            }
            return
        }
        
        do {
            print("🔵 [AUTH_TRACE] fetchUserStatus checking DB for UID: \(uid)")
            let user = try await SupabaseDBManager.shared.getUserDetails(userId: uid)
            await MainActor.run {
                print("✅ [AUTH_TRACE] User details fetched. Status: \(user.verificationStatus ?? "nil")")
                self.isAuthenticated = true
                self.isProfileIncomplete = (user.verificationStatus == "incomplete")
                
                if user.role == "doctor" {
                    self.isDoctor = true
                    self.isPendingVerification = (user.verificationStatus == "pending")
                } else {
                    self.isDoctor = false
                    self.isPendingVerification = false
                }
                
                self.isLoading = false
            }
        } catch {
            print("❌ [AUTH_TRACE] Error fetching DB profile: \(error.localizedDescription)")
            
            // If profile fetch fails, check UserDefaults as fallback
            if let localUser = UserDefaults.standard.value(AppUser.self, forKey: "userDetails") {
                print("ℹ️ [AUTH_TRACE] Using local userDetails fallback")
                await MainActor.run {
                    self.isAuthenticated = true
                    self.isProfileIncomplete = (localUser.verificationStatus == "incomplete")
                    self.isDoctor = (localUser.role == "doctor")
                    self.isPendingVerification = (localUser.verificationStatus == "pending")
                    self.isLoading = false
                }
            } else {
                print("⚠️ [AUTH_TRACE] No profile found and no local fallback. Ensuring logout.")
                await MainActor.run {
                    self.isAuthenticated = false
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Doctor Verification
struct DoctorVerificationView: View {
    @State private var verificationKey = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isVerified = false
    @AppStorage("userID") var storedUserID: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "shield.checkered")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.appBlue)
            
            VStack(spacing: 15) {
                Text("Verify Your Account")
                    .font(.customFont(style: .bold, size: .h24))
                
                Text("Please enter the 6-digit verification key sent to your medical email address.")
                    .font(.customFont(style: .medium, size: .h15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 20) {
                CustomTextField(placeholder: "Enter 6-digit Key", text: $verificationKey)
                    .textInputAutocapitalization(.characters)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .frame(maxWidth: 300)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button {
                    verifyKey()
                } label: {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Verify & Activate")
                            .font(.customFont(style: .bold, size: .h17))
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(BlueButtonStyle(height: 55, color: .appBlue))
                .disabled(isLoading || verificationKey.count < 6)
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            Button {
                Task {
                    try? await SupabaseAuthService.shared.signOut()
                }
            } label: {
                Text("Back to Login")
                    .font(.customFont(style: .bold, size: .h15))
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 20)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $isVerified) {
            SuccessStateView()
        }
    }
    
    func verifyKey() {
        guard !storedUserID.isEmpty else { 
            self.errorMessage = "User session expired. Please log in again."
            return 
        }
        let userId = storedUserID
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 1. Fetch current profile to check key
                let profile = try await SupabaseDBManager.shared.fetchUserProfile(userId: userId)
                
                print("🔵 Comparing keys: Input '\(verificationKey)' vs DB '\(profile.verificationKey ?? "NULL")'")
                
                if let dbKey = profile.verificationKey, dbKey.lowercased() == verificationKey.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
                    // 2. Update status to verified
                    var updatedProfile = profile
                    updatedProfile.verificationStatus = "verified"
                    
                    // Force update in Database
                    try await SupabaseDBManager.shared.updateUserDetails(userId: userId, user: updatedProfile)
                    
                    await MainActor.run {
                        self.isVerified = true
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Invalid verification key. Tip: Keys are 6 characters long."
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
