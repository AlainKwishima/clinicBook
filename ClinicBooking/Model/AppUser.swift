//
//  AppUser.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 03/09/24.
//

import Foundation
// import FirebaseFirestore  // DEPRECATED: Migrated to Supabase

struct AppUser: Codable {
    var id: String?  // Changed from @DocumentID for Supabase compatibility
    var password: String?
    var email: String?
    let firstName: String
    let lastName: String
    let createdAt: Date
    var height: String?
    var weight: String?
    var age: String?
    var bloodGroup: String?
    var phoneNumber: String?
    var imageURL: String?
    var address: String?
    var role: String? = "patient" // "patient" or "doctor"
    var verificationStatus: String? = "none" // "none", "pending", "verified", "rejected"
    
    // Doctor Specific Fields
    var hospitalName: String?
    var experienceYears: String?
    var country: String?
    var city: String?
    var specialty: String?
    var licenseNumber: String?
    var aboutMe: String?

    var favoriteDoctorIds: [String]? = []

    // Custom keys to match JSON structure, if needed
    // Custom keys to match JSON structure (Supabase uses snake_case)
    private enum CodingKeys: String, CodingKey {
        case id
        case password
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
        case role
        case verificationStatus = "verification_status"
        
        // Doctor Specific Fields
        case hospitalName = "hospital_name"
        case experienceYears = "experience_years"
        case country
        case city
        case specialty
        case licenseNumber = "license_number"
        case aboutMe = "about_me"
        
        case favoriteDoctorIds = "favorite_doctor_ids"
    }
}
