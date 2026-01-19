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
    
    /// Sign in with email and password
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }
    
    /// Sign up a new user and create their profile in the database
    func signUp(user: AppUser) async throws {
        // 1. Create Auth Entry
        _ = try await client.auth.signUp(
            email: user.email ?? "",
            password: user.password ?? ""
        )
        
        // Note: Supabase can automatically create profiles via Postgres triggers,
        // but for manual parity with the Firebase implementation:
        guard let session = try? await client.auth.session else { return }
        let userId = session.user.id
        
        struct ProfileData: Encodable {
            let id, firstName, lastName, email, role, verificationStatus: String
            let phoneNumber, imageURL, address, hospitalName, specialty: String
            
            enum CodingKeys: String, CodingKey {
                case id
                case firstName = "first_name"
                case lastName = "last_name"
                case email, role
                case verificationStatus = "verification_status"
                case phoneNumber = "phone_number"
                case imageURL = "image_url"
                case address
                case hospitalName = "hospital_name"
                case specialty
            }
        }
        
        let profileData = ProfileData(
            id: userId.uuidString,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email ?? "",
            role: user.role ?? "patient",
            verificationStatus: (user.role == "doctor") ? "pending" : (user.verificationStatus ?? "none"),
            phoneNumber: user.phoneNumber ?? "",
            imageURL: user.imageURL ?? "",
            address: user.address ?? "",
            hospitalName: user.hospitalName ?? "",
            specialty: user.specialty ?? ""
        )
        
        try await client.from("profiles")
            .insert(profileData)
            .execute()
            
        // 2. Mirror doctor data if applicable
        if user.role == "doctor" {
            struct DoctorData: Encodable {
                let id, specialist: String
                let isPopular: Bool
                let rating: String
                
                enum CodingKeys: String, CodingKey {
                    case id, specialist
                    case isPopular = "is_popular"
                    case rating
                }
            }
            
            let doctorData = DoctorData(
                id: userId.uuidString,
                specialist: user.specialty ?? "General Physician",
                isPopular: true,
                rating: "5.0"
            )
            try await client.from("doctors")
                .insert(doctorData)
                .execute()
        }
    }
    
    /// Sign out the current user
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    /// Reset password for a given email
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
}
