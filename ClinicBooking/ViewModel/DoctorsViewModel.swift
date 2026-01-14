//
//  DoctorsViewModel.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 03/09/24.
//

import Foundation

@MainActor
class DoctorsViewModel: ObservableObject {
    @Published var doctors: [Doctor] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetchDoctors() async {
        self.isLoading = true
        defer { self.isLoading = false }
        
        var allDoctors: [Doctor] = []
        
        // 1. Load from JSON (Legacy)
        if let loadedList = loadJson(fileName: "doctors") {
            allDoctors = loadedList.doctors
            print("Successfully loaded \(allDoctors.count) doctors from JSON.")
        }
        
        // 2. Load from Firestore (Dynamic)
        do {
            let registeredUsers = try await FireStoreManager.shared.fetchRegisteredDoctors()
            print("Fetched \(registeredUsers.count) registered doctors from Firestore.")
            
            let registeredDoctors = registeredUsers.compactMap { user -> Doctor in
                // Find a unique ID (email or UID should be stable)
                let stableId = user.email
                return Doctor(from: user, id: stableId)
            }
            
            // Merge lists, avoiding duplicates by id
            var mergedCount = 0
            for doc in registeredDoctors {
                if !allDoctors.contains(where: { $0.id == doc.id || $0.doctorID == doc.doctorID }) {
                    allDoctors.append(doc)
                    mergedCount += 1
                }
            }
            print("Merged \(mergedCount) new doctors into the list. Total count: \(allDoctors.count)")
            
        } catch {
            print("Failed to fetch doctors from Firestore: \(error)")
            self.errorMessage = "Dynamic doctor list could not be refreshed."
        }
        
        self.doctors = allDoctors
        
        if self.doctors.isEmpty {
            print("Using hardcoded fallback.")
            self.doctors = [
                Doctor(firestoreID: nil, doctorID: "999", name: "Dr. Fallback", specialist: "General Physician", degree: "MD", image: "user", position: "Specialist", languageSpoken: "English", about: "Fallback Data", contact: "000", address: "Local", rating: "5.0", isPopular: true, isSaved: false, fee: 100.0)
            ]
        }
    }

    func loadJson(fileName: String) -> DoctorsList? {
        let decoder = JSONDecoder()
        var url = Bundle.main.url(forResource: fileName, withExtension: "json")
        
        if url == nil {
            // Fallback to absolute path for debugging
            let absolutePath = "/Users/Alain/Documents/ClinicBooking/ClinicBooking/Resources/doctors.json"
            print("Bundle load failed. Trying absolute path: \(absolutePath)")
            url = URL(fileURLWithPath: absolutePath)
        }
        
        guard let finalUrl = url else {
            self.errorMessage = "Could not locate doctors.json"
            return nil
        }
        
        do {
            let data = try Data(contentsOf: finalUrl)
            let person = try decoder.decode(DoctorsList.self, from: data)
            return person
        } catch {
            self.errorMessage = "Decoding error: \(error)"
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
}

@MainActor
class ClinicsViewModel: ObservableObject {
    @Published var clinics: [Clinic] = [
        Clinic(name: "City General Hospital", 
               type: "Hospital", 
               image: "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&q=80&w=800", 
               address: "123 Main St, Downtown", 
               rating: "4.8", 
               services: ["Emergency", "Cardiology", "Neurology", "General Surgery"], 
               about: "City General Hospital is a state-of-the-art medical facility providing comprehensive care for our community. Our emergency department is open 24/7.", 
               doctorIds: ["1", "4", "5"]),
        
        Clinic(name: "Sunrise Family Clinic", 
               type: "Clinic", 
               image: "https://images.unsplash.com/photo-1512678080530-7760d81faba6?auto=format&fit=crop&q=80&w=800", 
               address: "456 Oak Rd, Uptown", 
               rating: "4.6", 
               services: ["Pediatrics", "Family Medicine", "Dermatology"], 
               about: "A friendly neighborhood clinic focused on family wellness and preventative care.", 
               doctorIds: ["2", "7"]),
        
        Clinic(name: "Elite Orthopedics Center", 
               type: "Clinic", 
               image: "https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&q=80&w=800", 
               address: "789 Pine St, Medical District", 
               rating: "4.9", 
               services: ["Orthopedics", "Physical Therapy", "Sports Medicine"], 
               about: "Specialized care for bones, joints, and muscles. We help athletes and seniors stay active.", 
               doctorIds: ["3", "10"]),
        
        Clinic(name: "Westside Cardiology", 
               type: "Clinic", 
               image: "https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&q=80&w=800", 
               address: "321 West Ave, Bayside", 
               rating: "4.7", 
               services: ["Cardiology", "Heart Surgery", "Stress Testing"], 
               about: "Leading heart specialists dedicated to advanced cardiovascular treatments.", 
               doctorIds: ["8"]),
        
        Clinic(name: "Neurology Specialists", 
               type: "Clinic", 
               image: "https://images.unsplash.com/photo-1513224502586-d1e602410265?auto=format&fit=crop&q=80&w=800", 
               address: "555 Neuro Pl, Research Hill", 
               rating: "4.5", 
               services: ["Neurology", "MRI", "EEG", "Sleep Studies"], 
               about: "Focusing on brain and nervous system health with the latest diagnostic technology.", 
               doctorIds: ["6"])
    ]
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    init() {
        Task {
            await fetchClinics()
        }
    }
    
    func fetchClinics() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedClinics = try await FireStoreManager.shared.fetchClinics()
            if !fetchedClinics.isEmpty {
                self.clinics = fetchedClinics
            }
        } catch {
            print("Error fetching clinics: \(error)")
            // Keep existing fallbacks if fetch fails
        }
        
        isLoading = false
    }
}
