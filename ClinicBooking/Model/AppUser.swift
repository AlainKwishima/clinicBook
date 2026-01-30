//
//  AppUser.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 03/09/24.
//

import Foundation
// import FirebaseFirestore  // DEPRECATED: Migrated to Supabase

struct AppUser: Codable {
    var id: String? = nil
    var password: String? = nil
    var email: String? = nil
    let firstName: String
    let lastName: String
    let createdAt: Date
    var height: String? = nil
    var weight: String? = nil
    var age: String? = nil
    var bloodGroup: String? = nil
    var phoneNumber: String? = nil
    var imageURL: String? = nil
    var address: String? = nil
    var gender: String? = nil
    var dob: String? = nil
    var role: String? = "patient" // "patient" or "doctor"
    var verificationStatus: String? = "none" // "none", "pending", "verified", "rejected"
    
    // Doctor Specific Fields
    var hospitalName: String? = nil
    var experienceYears: String? = nil
    var country: String? = nil
    var city: String? = nil
    var specialty: String? = nil
    var licenseNumber: String? = nil
    var aboutMe: String? = nil
    var verificationKey: String? = nil

    var insuranceProvider: String? = nil
    var insuranceNumber: String? = nil
    var favoriteDoctorIds: [String]? = []

    // Custom keys to match JSON structure, if needed
    // Custom keys to match JSON structure (Supabase uses snake_case)
    private enum CodingKeys: String, CodingKey {
        case id
        // case password // Removed to prevent PGRST204 error as profiles table has no password column
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case createdAt = "created_at"
        case height
        case weight
        case age
        case bloodGroup = "blood_group"
        case phoneNumber = "phone_number"
        case imageURL = "image_url"
        case address
        case gender
        case dob
        case role
        case verificationStatus = "verification_status"
        
        // Doctor Specific Fields
        case hospitalName = "hospital_name"
        case experienceYears = "experience_years"
        case country
        case city
        case specialty
        case licenseNumber = "license_number"
        case aboutMe = "about"
        case verificationKey = "verification_key"
        case insuranceProvider = "insurance_provider"
        case insuranceNumber = "insurance_number"
        
        case favoriteDoctorIds = "favorite_doctor_ids"
    }
}
