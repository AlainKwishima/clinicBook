//
//  AuthenticationViewModel.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 01/09/24.
//

import Foundation
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
                UserDefaults.standard.set(session.user.id.uuidString, forKey: "userID")
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

    func signup() async {
        let sanitizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if password.isEmpty {
            validationMessage = "Please enter your password."
            return
        } else if sanitizedEmail.isEmpty {
            validationMessage = "Please enter your email."
            return
        } else if firstName.isEmpty {
            validationMessage = "Please enter your First Name."
            return
        } else if lastName.isEmpty {
            validationMessage = "Please enter your Last Name."
            return
        }
        isLoading = true
        defer { isLoading = false }
        let user = AppUser(password: password,
                           email: sanitizedEmail,
                           firstName: firstName,
                           lastName: lastName,
                           createdAt: Date(),
                           height: "",
                           weight: "",
                           age: "",
                           bloodGroup: "",
                           phoneNumber: "",
                           imageURL: "",
                           address: ""
        )
        do {
            try await authService.signUp(user: user)
            
            // Save locally so the next screen (AdditionalInfoView) can access it
            UserDefaults.standard.set(encodable: user, forKey: "userDetails")
            
            // Also retrieve and save the UserID
            if let session = try? await SupabaseManager.shared.client.auth.session {
                UserDefaults.standard.set(session.user.id.uuidString, forKey: "userID")
            }
            
            shouldNavigateToAdditionalInfo = true
        } catch {
            validationMessage = "Failed to sign up: \(error.localizedDescription)"
        }
    }

    func signOut() async {
        do {
            try await authService.signOut()
            showSignInView = true
        } catch {
            print("Error signing out from Supabase: \(error.localizedDescription)")
        }
    }
}
