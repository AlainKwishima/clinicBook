//
//  AuthenticationViewModel.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 01/09/24.
//

import Foundation
import FirebaseAuth

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
    private let firebaseService = FirebaseService()

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
        let errorMessage = await firebaseService.signIn(email: sanitizedEmail, password: password)
        validationMessage = errorMessage?.localizedDescription
        return errorMessage == nil
    }

    func getUserDetails() async {
        if let user = Auth.auth().currentUser {
            await FireStoreManager.shared.getUserDetails(userId: user.uid) { message in
                debugPrint(message)
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
        
        // 1. Firebase Auth Sign In
        let errorMessage = await firebaseService.signIn(email: sanitizedEmail, password: password)
        if let error = errorMessage {
            validationMessage = error.localizedDescription
            return false
        }
        
        // 2. Fetch Details & Verify Role
        if let user = Auth.auth().currentUser {
            var success = false
            await FireStoreManager.shared.getUserDetails(userId: user.uid) { msg in
                success = msg
            }
            
            if success, let details = UserDefaults.standard.value(AppUser.self, forKey: "userDetails") {
                if details.role != "doctor" {
                    validationMessage = "This account is not registered as a doctor."
                    signOut()
                    return false
                }
                
                if details.licenseNumber != licenseNumber {
                    validationMessage = "Invalid Medical License Number for this account."
                    signOut()
                    return false
                }
                
                return true
            } else {
                validationMessage = "Failed to fetch user profile."
                signOut()
                return false
            }
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
        let errorMessage = await firebaseService.resetPassword(email: sanitizedEmail)
        validationMessage = errorMessage?.localizedDescription
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
        let result = await firebaseService.signup(user: user)
        switch result {
        case .success:
            // validationMessage = "Sign Up Successful!" // Removed to allow smooth transition
            shouldNavigateToAdditionalInfo = true
        case .failure(let error):
            validationMessage = "Failed to sign up: \(error.localizedDescription)"
        }
    }

    func signOut() {
        do {
            try firebaseService.signout()
            showSignInView = true
        } catch let error as NSError {
            // Update your alert to reflect error if used here
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
