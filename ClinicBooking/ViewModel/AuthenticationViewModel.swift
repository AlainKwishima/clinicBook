//
//  AuthenticationViewModel.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 01/09/24.
//

import Foundation
import SwiftUI
import Supabase

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var showingResetPasswordSheet = false
    @Published var isShowingSignUpScreen = false
    @Published var isShowingHomeView = false
    @Published var showSignInView = false
    @Published var validationMessage: String?
    @Published var shouldNavigateToSignIn = false
    @Published var isLoading = false
    private let authService = SupabaseAuthService.shared
    private let dbManager = SupabaseDBManager.shared
    @AppStorage("userID") var storedUserID: String = ""

    func signIn() async -> Bool {
        let sanitizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if sanitizedEmail.isEmpty {
            validationMessage = "Please enter your email."
            return false
        } else if password.isEmpty {
            validationMessage = "Please enter your password."
            return false
        }
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.signIn(email: sanitizedEmail, password: password)
            validationMessage = nil
            return true
        } catch {
            validationMessage = error.localizedDescription
            return false
        }
    }

    func getUserDetails() async {
        if let session = try? await SupabaseManager.shared.client.auth.session {
            do {
                let details = try await dbManager.getUserDetails(userId: session.user.id.uuidString)
                UserDefaults.standard.set(encodable: details, forKey: "userDetails")
                let userIdString = session.user.id.uuidString
                UserDefaults.standard.set(userIdString, forKey: "userID")
                storedUserID = userIdString
            } catch {
                debugPrint("Error fetching user details from Supabase: \(error)")
            }
        }
    }

    func signInDoctor(licenseNumber: String) async -> Bool {
        let sanitizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if sanitizedEmail.isEmpty {
            validationMessage = "Please enter your email."
            return false
        } else if password.isEmpty {
            validationMessage = "Please enter your password."
            return false
        } else if licenseNumber.isEmpty {
            validationMessage = "Please enter your license number."
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // 1. Supabase Auth Sign In
        do {
            try await authService.signIn(email: sanitizedEmail, password: password)
            
            // 2. Fetch Details & Verify Role
            if let session = try? await SupabaseManager.shared.client.auth.session {
                let details = try await dbManager.getUserDetails(userId: session.user.id.uuidString)
                UserDefaults.standard.set(encodable: details, forKey: "userDetails")
                
                if details.role != "doctor" {
                    validationMessage = "This account is not registered as a doctor."
                    await signOut()
                    return false
                }
                
                if details.licenseNumber != licenseNumber {
                    validationMessage = "Invalid Medical License Number for this account."
                    await signOut()
                    return false
                }
                
                return true
            }
        } catch {
            validationMessage = error.localizedDescription
            return false
        }
        
        return false
    }

    func clearValidationMessage() {
        validationMessage = nil
    }

    func resetPassword() async {
        let sanitizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if sanitizedEmail.isEmpty {
            validationMessage = "Please enter your email."
            return
        }
        do {
            try await authService.resetPassword(email: sanitizedEmail)
            validationMessage = "Password reset email sent."
        } catch {
            validationMessage = error.localizedDescription
        }
    }

    @Published var shouldNavigateToAdditionalInfo = false
    @Published var role: String = "patient"
    @Published var licenseNumber: String = ""
    @Published var specialty: String = ""
    @Published var experienceYears: String = ""
    @Published var aboutMe: String = ""
    @Published var hospitalName: String = ""
    
    func signup() -> Bool {
        let sanitizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if firstName.isEmpty {
            validationMessage = "Please enter your First Name."
            return false
        } else if lastName.isEmpty {
            validationMessage = "Please enter your Last Name."
            return false
        } else if sanitizedEmail.isEmpty {
            validationMessage = "Please enter your email."
            return false
        } else if password.isEmpty {
            validationMessage = "Please enter your password."
            return false
        }
        
        // Ensure role is set (defaults to patient for regular signup)
        if role.isEmpty {
            role = "patient"
        }
        
        // Set flag BEFORE navigation to prevent auth listener interference
        SupabaseAuthService.shared.isSignUpFlowInProgress = true
        NotificationCenter.default.post(name: NSNotification.Name("SignupFlowStarted"), object: nil)
        
        validationMessage = nil
        shouldNavigateToAdditionalInfo = true
        return true
    }

    func signOut() async {
        do {
            try await authService.signOut()
            showSignInView = true
            // Post notification for force logout to ensure all views react
            NotificationCenter.default.post(name: NSNotification.Name("AppLogout"), object: nil)
        } catch {
            print("Error signing out from Supabase: \(error.localizedDescription)")
            // Still force local logout if remote fails
            NotificationCenter.default.post(name: NSNotification.Name("AppLogout"), object: nil)
        }
    }
}
