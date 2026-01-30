//
//  SupabaseDBManager.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 17/01/26.
//

import Foundation
import Supabase

class SupabaseDBManager {
    static let shared = SupabaseDBManager()
    private let client = SupabaseManager.shared.client
    
    // MARK: - User Profiles & Auth
    
    /// Fetches user profile and caches it to UserDefaults (Legacy behavior support)
    func getUserDetails(userId: String) async throws -> AppUser {
        guard !userId.isEmpty else {
            throw NSError(domain: "SupabaseDBManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "User ID cannot be empty."])
        }
        
        // Use a retry mechanism as the background trigger might take a moment to create the profile
        var attempts = 0
        let maxAttempts = 3
        
        while attempts < maxAttempts {
            do {
                let response: [AppUser] = try await client.from("profiles")
                    .select()
                    .eq("id", value: userId)
                    .execute()
                    .value
                    
                if let user = response.first {
                    // Cache locally to match legacy FireStoreManager behavior
                    UserDefaults.standard.set(encodable: user, forKey: "userDetails")
                    UserDefaults.standard.set(userId, forKey: "userID")
                    return user
                }
            } catch {
                print("Retry attempt \(attempts + 1) failed: \(error.localizedDescription)")
            }
            
            attempts += 1
            if attempts < maxAttempts {
                try await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second before retry
            }
        }
        
        throw NSError(domain: "SupabaseDBManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User profile not found after retries."])
    }
    
    /// Fetches user profile for the logged in user (includes local caching)
    func fetchUserProfile(userId: String) async throws -> AppUser {
        return try await getUserDetails(userId: userId)
    }
    
    /// Fetches a user's profile WITHOUT side effects (no UserDefaults caching)
    func fetchPublicProfile(userId: String) async throws -> AppUser {
        guard !userId.isEmpty else {
            throw NSError(domain: "SupabaseDBManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "User ID cannot be empty."])
        }
        
        let response: [AppUser] = try await client.from("profiles")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
            
        if let user = response.first {
            return user
        }
        
        throw NSError(domain: "SupabaseDBManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User profile not found."])
    }
    
    /// Legacy wrapper for completion handlers
    func getUserDetails(userId: String, completion: @escaping(Bool) -> Void) async {
        do {
            _ = try await getUserDetails(userId: userId)
            completion(true)
        } catch {
            print("Error fetching user details from Supabase: \(error)")
            completion(false)
        }
    }
    
    func updateUserDetails(userId: String, user: AppUser) async throws {
        guard !userId.isEmpty else {
             throw NSError(domain: "SupabaseDBManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "User ID cannot be empty."])
        }
        
        try await client.from("profiles")
            .update(user)
            .eq("id", value: userId)
            .execute()
            
        // If user is a doctor, sync the doctors table as well
        if user.role == "doctor" {
            let doctorData: [String: AnyJSON] = [
                "name": .string("Dr. \(user.firstName) \(user.lastName)"),
                "image": .string(user.imageURL ?? ""),
                "specialist": .string(user.specialty ?? "Medical Specialist"),
                "about": .string(user.aboutMe ?? "No bio available."),
                "hospital_name": .string(user.hospitalName ?? ""),
                "experience_years": .string(user.experienceYears ?? "0")
            ]
            
            try? await client.from("doctors")
                .update(doctorData)
                .eq("id", value: userId)
                .execute()
        }
            
        // Refresh cache
        _ = try? await getUserDetails(userId: userId)
    }
    
    // Legacy wrapper
    func updateUserDetails(_ userID: String, dataModel: AppUser, completion: @escaping(Bool) -> Void) async {
        do {
            try await updateUserDetails(userId: userID, user: dataModel)
            completion(true)
        } catch {
             print("Error updating user details: \(error)")
             completion(false)
        }
    }
    
    func deleteUserAccount(userId: String) async throws {
         try await client.from("profiles")
             .delete()
             .eq("id", value: userId)
             .execute()
     }
    
    // MARK: - Family Members
    
    func updateFamilyMembers(_ userID: String, dataModel: FamilyMemberModel, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                for var member in dataModel.members {
                    struct FamilyMemberInsert: Encodable {
                        let userId: String, firstName: String, lastName: String
                        let relation: String, height: String, weight: String
                        let age: String, bloodGroup: String, phoneNumber: String, imageURL: String
                        
                        enum CodingKeys: String, CodingKey {
                            case userId = "user_id"
                            case firstName = "first_name", lastName = "last_name"
                            case relation, height, weight, age
                            case bloodGroup = "blood_group", phoneNumber = "phone_number", imageURL = "image_url"
                        }
                    }
                    
                    let data = FamilyMemberInsert(
                        userId: userID, firstName: member.firstName, lastName: member.lastName,
                        relation: member.relation, height: member.height, weight: member.weight,
                        age: member.age, bloodGroup: member.bloodGroup, phoneNumber: member.phoneNumber,
                        imageURL: member.imageURL
                    )
                    
                    try await client.from("family_members").upsert(data).execute()
                }
                completion(true)
            } catch {
                print("Error updating family members: \(error)")
                completion(false)
            }
        }
    }

    func getFamilyMembers(userId: String, completion: @escaping(Bool, FamilyMemberModel) -> Void) async {
        do {
            let model = try await getFamilyMembersAsync(userId: userId)
            completion(true, FamilyMemberModel(members: model))
        } catch {
            print("Error fetching family members: \(error)")
            completion(false, FamilyMemberModel(members: []))
        }
    }
    
    func getFamilyMembersAsync(userId: String) async throws -> [MemberModel] {
        let members: [MemberModel] = try await client.from("family_members")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        return members
    }
    
    // MARK: - Doctors & Clinics
    
    func fetchClinics() async throws -> [Clinic] {
        let response: [Clinic] = try await client.from("clinics")
            .select()
            .execute()
            .value
        return response
    }
    
    /// Fetches ACTIVE doctors from the `doctors` table (Source of Truth for Bookings)
    func fetchRegisteredDoctors() async throws -> [Doctor] {
        let response: [Doctor] = try await client.from("doctors")
            .select()
            .eq("is_active", value: true)
            .execute()
            .value
        return response
    }
    
    /// Fetches all profiles with role='doctor' (Source of Truth for Auth/Admin)
    func fetchAllDoctorProfiles() async throws -> [AppUser] {
        let response: [AppUser] = try await client.from("profiles")
            .select()
            .eq("role", value: "doctor")
            .execute()
            .value
        return response
    }
    
    func fetchPendingDoctors() async throws -> [AppUser] {
        let response: [AppUser] = try await client.from("profiles")
            .select()
            .eq("role", value: "doctor")
            .eq("verification_status", value: "pending")
            .execute()
            .value
        return response
    }
    
    func updateVerificationStatus(userId: String, status: String) async throws {
        // Update PROFILES table
        try await client.from("profiles")
            .update(["verification_status": status])
            .eq("id", value: userId)
            .execute()
            
        // Update DOCTORS table (Sync)
        try await client.from("doctors")
            .update(["verification_status": status])
            .eq("id", value: userId)
            .execute()
    }
    
    func toggleFavoriteDoctor(doctorId: String, userId: String) async throws -> Bool {
        var profile: AppUser = try await getUserDetails(userId: userId)
        var favorites = profile.favoriteDoctorIds ?? []
        let isFavorited: Bool
        
        if let index = favorites.firstIndex(of: doctorId) {
            favorites.remove(at: index)
            isFavorited = false
        } else {
            favorites.append(doctorId)
            isFavorited = true
        }
        
        try await client.from("profiles")
            .update(["favorite_doctor_ids": favorites])
            .eq("id", value: userId)
            .execute()
            
        // Update local cache manually since we modified a sub-field
        profile.favoriteDoctorIds = favorites
        UserDefaults.standard.set(encodable: profile, forKey: "userDetails")
        
        return isFavorited
    }
    
    // MARK: - Appointments
    
    func saveAppointment(appointment: Appointment) async throws {
        try await client.from("appointments")
            .insert(appointment)
            .execute()
    }
    
    func fetchUserAppointments(userId: String) async throws -> [Appointment] {
        let response: [Appointment] = try await client.from("appointments")
            .select()
            .eq("user_id", value: userId)
            .order("date", ascending: true)
            .execute()
            .value
        return response
    }
    
    func cancelAppointment(appointmentId: String) async throws {
        try await client.from("appointments")
            .delete()
            .eq("id", value: appointmentId)
            .execute()
    }
    
    func markAppointmentAsPaid(appointmentId: String) async throws {
        try await client.from("appointments")
            .update(["is_paid": true])
            .eq("id", value: appointmentId)
            .execute()
    }
    
    func fetchDoctorAppointments(doctorId: String) async throws -> [Appointment] {
        let response: [Appointment] = try await client.from("appointments")
            .select()
            .eq("doctor_id", value: doctorId)
            .order("date", ascending: true)
            .execute()
            .value
        return response
    }
}
