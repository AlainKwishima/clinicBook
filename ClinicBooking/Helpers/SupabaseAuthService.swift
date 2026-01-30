//
//  SupabaseAuthService.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 17/01/26.
//

import Foundation
import Supabase

class SupabaseAuthService {
    static let shared = SupabaseAuthService()
    private let client = SupabaseManager.shared.client
    
    /// Flag to indicate if a signup flow is in progress to prevent auth state listeners 
    /// from prematurely navigating away from signup views.
    var isSignUpFlowInProgress: Bool = false
    
    /// Sign in with email and password
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }
    
    /// Sign up a new user and create their profile in the database
    func signUp(user: AppUser) async throws -> User? {
        var metadata: [String: AnyJSON] = [
            "first_name": .string(user.firstName),
            "last_name": .string(user.lastName),
            "role": .string(user.role ?? "patient"),
            "gender": .string(user.gender ?? ""),
            "country": .string(user.country ?? ""),
            "dob": .string(user.dob ?? ""),
            "insurance_provider": .string(user.insuranceProvider ?? "None"),
            "insurance_number": .string(user.insuranceNumber ?? ""),
            "phone_number": .string(user.phoneNumber ?? ""),
            "address": .string(user.address ?? "")
        ]
        
        if user.role == "doctor" {
            metadata["license_number"] = .string(user.licenseNumber ?? "")
            metadata["specialty"] = .string(user.specialty ?? "")
            metadata["experience_years"] = .string(user.experienceYears ?? "")
            metadata["hospital_name"] = .string(user.hospitalName ?? "")
            metadata["city"] = .string(user.city ?? "")
            metadata["about"] = .string(user.aboutMe ?? "")
        }
        
        let response = try await client.auth.signUp(
            email: user.email ?? "",
            password: user.password ?? "",
            data: metadata
        )
        
        return response.user
    }
    
    /// Sign out the current user
    func signOut() async throws {
        isSignUpFlowInProgress = false
        try await client.auth.signOut()
    }
    
    /// Reset password for a given email
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
}
