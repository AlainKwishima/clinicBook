//
//  FirebaseService.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 03/09/24.
//

import Foundation
import Firebase
import FirebaseAuth

struct FirebaseService {

    var currentUser: User? {
        return Auth.auth().currentUser
    }

    func signIn(email: String, password: String) async -> Error? {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("Firebase user: \(result.user)")
            return nil
        } catch {
            print("Firebase signin error: \(error)")
            return error
        }
    }

    func signup(user: AppUser) async -> Result<User, Error> {
        do {
            let result = try await Auth.auth().createUser(withEmail: user.email ?? "", password: user.password ?? "")
            print("Firebase user : \(result.user)")
            updateUserDetails(firebaseUser: result.user, appuser: user)
            return .success(result.user)
        } catch {
            print("Firebase Signup error: \(error)")
            return .failure(error)
        }
    }

    private func updateUserDetails(firebaseUser: User, appuser: AppUser) {
        let userData: [String: Any] = [
            "firstName": appuser.firstName,
            "lastName": appuser.lastName,
            "email": appuser.email ?? "",
            "password": appuser.password ?? "",
            "height": appuser.height ?? "",
            "weight": appuser.weight ?? "",
            "age": "",
            "bloodGroup": "",
            "phoneNumber": appuser.phoneNumber ?? "",
            "imageURL": appuser.imageURL ?? "",
            "address": appuser.address ?? "",
            "role": appuser.role ?? "patient",
            "verificationStatus": (appuser.role == "doctor") ? "pending" : (appuser.verificationStatus ?? "none"),
            "hospitalName": appuser.hospitalName ?? "",
            "experienceYears": appuser.experienceYears ?? "",
            "country": appuser.country ?? "",
            "city": appuser.city ?? "",
            "specialty": appuser.specialty ?? "",
            "licenseNumber": appuser.licenseNumber ?? "",
            "aboutMe": appuser.aboutMe ?? "",
            "createdAt": FieldValue.serverTimestamp()
        ]
        Firestore.firestore().collection("users").document(firebaseUser.uid).setData(userData) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User Data saved successfully in FireStore")
                
                // Mirror public data to 'doctors' collection if role is doctor
                if (userData["role"] as? String) == "doctor" {
                    let publicData: [String: Any] = [
                        "firstName": userData["firstName"] ?? "",
                        "lastName": userData["lastName"] ?? "",
                        "specialty": userData["specialty"] ?? "",
                        "hospitalName": userData["hospitalName"] ?? "",
                        "imageURL": userData["imageURL"] ?? "",
                        "role": "doctor",
                        "verificationStatus": userData["verificationStatus"] ?? "pending",
                        // Include any other non-sensitive fields needed for search cards
                        "rating": "5.0",
                        "createdAt": userData["createdAt"] ?? FieldValue.serverTimestamp()
                    ]
                    
                    Firestore.firestore().collection("doctors").document(firebaseUser.uid).setData(publicData) { error in
                        if let error = error {
                            print("Error mirroring doctor data: \(error.localizedDescription)")
                        } else {
                            print("Doctor Public Info mirrored successfully")
                        }
                    }
                }
            }
        }
    }

    func resetPassword(email: String) async -> Error? {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            return nil
        } catch {
            print("FirebaseService SignIn Error: \(error)")
            return error
        }
    }

    func signout() throws {
        try Auth.auth().signOut()
    }
}
