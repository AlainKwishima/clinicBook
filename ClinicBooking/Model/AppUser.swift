//
//  AppUser.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 03/09/24.
//

import Foundation
import FirebaseFirestore

struct AppUser: Codable {
    @DocumentID var id: String?
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
    private enum CodingKeys: String, CodingKey {
        case password, email, firstName, lastName, createdAt, height, weight, age, bloodGroup, phoneNumber, imageURL, address, role, verificationStatus
        case hospitalName, experienceYears, country, city, specialty, licenseNumber, aboutMe
        case favoriteDoctorIds = "favorite_doctor_ids"
    }
}
