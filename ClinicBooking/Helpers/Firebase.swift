//
//  Firebase.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 12/09/24.
//

import Foundation
import FirebaseFirestore

class FireStoreManager {
    static let shared = FireStoreManager()
    private let db = Firestore.firestore()

    func getUserDetails(userId: String, completion: @escaping(Bool) -> Void) async {
        let docRef = db.collection(FireStoreCollections.users.rawValue).document(userId)
        do {
            let performance = try await docRef.getDocument(as: AppUser.self)
            UserDefaults.standard.set(encodable: performance, forKey: "userDetails")
            UserDefaults.standard.set(userId, forKey: "userID") // Explicitly save UserID string
            debugPrint("User Details == \(performance)")
            completion(true)
        } catch {
            print("Error decoding user details: \(error)")
            completion(false)
        }
    }

    func updateFamilyMembers(_ userID: String, dataModel: FamilyMemberModel, completion: @escaping (Bool) -> Void) {
        let id = "\(userID)" // Composite Id with user id
        let path = db.collection(FireStoreCollections.familyMembers.rawValue).document(id)

        do {
          try path.setData(from: dataModel, merge: true)
        } catch let error {
          print("Error writing family members data to Firestore: \(error)")
        }
    }

    func updateUserDetails(_ userID: String, dataModel: AppUser, completion: @escaping(Bool) -> Void) async {
        let id = "\(userID)"
        let path = db.collection(FireStoreCollections.users.rawValue).document(id)

        do {
            try path.setData(from: dataModel, merge: true)
            await getUserDetails(userId: id) { message in
                debugPrint("Getting user details: \(message)")
                completion(message) // Pass the result of getUserDetails
            }
        } catch let error {
            print("Error writing user details to firestore: \(error)")
            completion(false)
        }
    }

    func getFamilyMembers(userId: String, completion: @escaping(Bool, FamilyMemberModel) -> Void) async {
        let docRef = db.collection(FireStoreCollections.familyMembers.rawValue).document(userId)
        do {
            let members = try await docRef.getDocument(as: FamilyMemberModel.self)
            completion(true, members)
        } catch {
            print("Error decoding family members: \(error)")
            completion(false, FamilyMemberModel(members: [MemberModel]()))
        }
    }

    func getAllDoctors() async throws -> [Doctor] {
        let snapshot = try await db.collection(FireStoreCollections.doctors.rawValue).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Doctor.self) }
    }

    func fetchRegisteredDoctors() async throws -> [AppUser] {
        let snapshot = try await db.collection(FireStoreCollections.users.rawValue)
            .whereField("role", isEqualTo: "doctor")
            .whereField("verificationStatus", isEqualTo: "verified")
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: AppUser.self) }
    }

    func fetchPendingDoctors() async throws -> [AppUser] {
        let snapshot = try await db.collection(FireStoreCollections.users.rawValue)
            .whereField("role", isEqualTo: "doctor")
            .whereField("verificationStatus", isEqualTo: "pending")
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: AppUser.self) }
    }

    func updateVerificationStatus(userId: String, status: String) async throws {
        try await db.collection(FireStoreCollections.users.rawValue).document(userId).updateData([
            "verificationStatus": status
        ])
    }

    func fetchClinics() async throws -> [Clinic] {
        let snapshot = try await db.collection(FireStoreCollections.clinics.rawValue).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Clinic.self) }
    }

    // MARK: - Appointments
    func saveAppointment(appointment: Appointment) async throws {
        let _ = try db.collection(FireStoreCollections.appointments.rawValue).addDocument(from: appointment)
    }

    func fetchUserAppointments(userId: String) async throws -> [Appointment] {
        let snapshot = try await db.collection(FireStoreCollections.appointments.rawValue)
            .whereField("user_id", isEqualTo: userId)
            .order(by: "date", descending: false)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Appointment.self) }
    }
    func toggleFavoriteDoctor(doctorId: String, userId: String) async throws -> Bool {
        let userRef = db.collection(FireStoreCollections.users.rawValue).document(userId)
        
        var user = try await userRef.getDocument(as: AppUser.self)
        
        var favorites = user.favoriteDoctorIds ?? []
        
        var isFavorited = false
        if let index = favorites.firstIndex(of: doctorId) {
            favorites.remove(at: index)
            isFavorited = false
        } else {
            favorites.append(doctorId)
            isFavorited = true
        }
        
        user.favoriteDoctorIds = favorites
        try userRef.setData(from: user, merge: true)
        
        // Update local cache
        UserDefaults.standard.set(encodable: user, forKey: "userDetails")
        
        return isFavorited
    }
    func cancelAppointment(appointmentId: String) async throws {
        try await db.collection(FireStoreCollections.appointments.rawValue).document(appointmentId).delete()
    }

    func deleteUserAccount(userId: String) async throws {
        // 1. Delete User Document
        try await db.collection(FireStoreCollections.users.rawValue).document(userId).delete()
        
        // 2. Delete Family Member Documents
        try await db.collection(FireStoreCollections.familyMembers.rawValue).document(userId).delete()
        
        // 3. Delete Appointments
        let appointments = try await fetchUserAppointments(userId: userId)
        for appointment in appointments {
            if let id = appointment.id {
                try await db.collection(FireStoreCollections.appointments.rawValue).document(id).delete()
            }
        }
    }
}

enum FireStoreCollections: String {
    case users = "users"
    case familyMembers = "family_members"
    case doctors = "doctors"
    case appointments = "appointments"
    case clinics = "clinics"
}
