//
//  DoctorsList.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 03/09/24.
//

import Foundation
// import FirebaseFirestore  // DEPRECATED: Migrated to Supabase

// MARK: - Clinic
struct Clinic: Codable, Identifiable {
    var id: String?  // Changed from @DocumentID for Supabase compatibility
    var name: String
    var type: String // "Clinic" or "Hospital"
    var image: String
    var address: String
    var rating: String
    var services: [String]
    var about: String
    var doctorIds: [String] // UIDs of doctors associated with this facility
    var contact: String?
    
    var clinicID: String { id ?? UUID().uuidString }
}

// MARK: - DoctorsList
struct DoctorsList: Codable {
    var doctors: [Doctor]
}

// MARK: - Doctor
struct Doctor: Codable, Identifiable {
    var firestoreID: String?  // Changed from @DocumentID for Supabase compatibility
    var id: String { firestoreID ?? doctorID }
    var doctorID: String
    var name, specialist, degree: String
    var image, position, languageSpoken, about: String
    var contact: String
    var address: String
    var rating: String
    var isPopular: Bool
    var isSaved: Bool
    var fee: Double?

    enum CodingKeys: String, CodingKey {
        case doctorID = "doctor_id"
        case name, specialist, degree, image, position
        case languageSpoken = "language_spoken"
        case about, contact, address, rating
        case isPopular = "is_popular"
        case isSaved = "is_saved"
        case fee
    }
}

extension Doctor {
    init(from appUser: AppUser, id: String) {
        self.firestoreID = id
        self.doctorID = id
        self.name = "Dr. \(appUser.firstName) \(appUser.lastName)"
        self.specialist = appUser.specialty ?? "General Physician"
        self.degree = "MD" // Default or could be added to AppUser
        self.image = (appUser.imageURL ?? "").isEmpty ? "user" : (appUser.imageURL ?? "user")
        self.position = "Specialist"
        self.languageSpoken = "English"
        self.about = appUser.aboutMe ?? "No bio available."
        self.contact = appUser.phoneNumber ?? "N/A"
        self.address = appUser.address ?? "Clinic Address"
        self.rating = "5.0"
        self.isPopular = true
        self.isSaved = false
        self.fee = 100.0 // Default fee
    }
}
//
//  Appointment.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//


import Foundation
// import FirebaseFirestore  // DEPRECATED: Migrated to Supabase

struct Appointment: Codable, Identifiable {
    var id: String?  // Changed from @DocumentID for Supabase compatibility
    var doctorId: String
    var userId: String
    var patientName: String
    var patientImage: String?
    var doctorName: String
    var doctorImage: String
    var doctorSpeciality: String
    var date: Date
    var time: String
    var status: String // "upcoming", "completed", "cancelled"
    var location: String
    var isPaid: Bool = false
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case doctorId = "doctor_id"
        case userId = "user_id"
        case patientName = "patient_name"
        case patientImage = "patient_image"
        case doctorName = "doctor_name"
        case doctorImage = "doctor_image"
        case doctorSpeciality = "doctor_speciality"
        case date
        case time
        case status
        case location
        case isPaid = "is_paid"
        case createdAt = "created_at"
    }
}
