//
//  PatientSelectionView.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI

struct PatientSelectionView: View {
    @Environment(\.dismiss) var dismiss
    var doctor: Doctor
    var date: Date
    var time: String
    
    @State private var familyMembers: [MemberModel] = []
    @State private var selectedPatientId: String = "myself" // "myself" or member ID
    @State private var isLoading = false
    @State private var isBooking = false
    @State private var navigateToConfirmation = false
    @State private var errorMessage: String?
    
    // User defaults for basic user info
    let currentUser = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Who is this appointment for?")
                .font(.customFont(style: .bold, size: .h20))
                .padding(.top)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView {
                    VStack(spacing: 15) {
                        // Option 1: Myself
                        patientOptionCard(
                            id: "myself",
                            name: "\(currentUser?.firstName ?? "Me") \(currentUser?.lastName ?? "")",
                            relation: "Self",
                            isSelected: selectedPatientId == "myself"
                        )
                        
                        // Option 2: Family Members
                        ForEach(familyMembers, id: \.id) { member in
                            patientOptionCard(
                                id: member.id ?? UUID().uuidString,
                                name: member.name,
                                relation: member.relation,
                                isSelected: selectedPatientId == (member.id ?? "")
                            )
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            
            Spacer()
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button {
                saveAppointment()
            } label: {
                if isBooking {
                    ProgressView().tint(.white)
                        .padding()
                        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                        .background(Color.appBlue)
                        .cornerRadius(15)
                } else {
                    Text("Confirm Appointment")
                        .font(.customFont(style: .bold, size: .h17))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                        .background(Color.appBlue)
                        .cornerRadius(15)
                }
            }
            .disabled(isBooking)
        }
        .padding()
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 600 : .infinity)
        .frame(maxWidth: .infinity)
        .navigationTitle("Select Patient")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchFamilyMembers()
        }
        .navigationDestination(isPresented: $navigateToConfirmation) {
            BookingConfirmationView(
                doctor: doctor,
                date: date,
                time: time
            )
        }
    }

    func getPatientName() -> String {
         if selectedPatientId == "myself" {
             return "\(currentUser?.firstName ?? "Me") \(currentUser?.lastName ?? "")"
         } else {
             return familyMembers.first(where: { $0.id == selectedPatientId })?.name ?? "Family Member"
         }
    }
    
    func getPatientImage() -> String {
        if selectedPatientId == "myself" {
            return currentUser?.imageURL ?? ""
        } else {
            return familyMembers.first(where: { $0.id == selectedPatientId })?.imageURL ?? ""
        }
    }
    
    func saveAppointment() {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            self.errorMessage = "User not logged in."
            return
        }
        
        isBooking = true
        errorMessage = nil
        
        let appointment = Appointment(
            doctorId: doctor.doctorID,
            userId: userId,
            patientName: getPatientName(),
            patientImage: getPatientImage(),
            doctorName: doctor.name,
            doctorImage: doctor.image,
            doctorSpeciality: doctor.specialist,
            date: date,
            time: time,
            status: "upcoming",
            location: doctor.address,
            isPaid: false,
            createdAt: Date()
        )
        
        Task {
            do {
                try await SupabaseDBManager.shared.saveAppointment(appointment: appointment)
                DispatchQueue.main.async {
                    self.isBooking = false
                    self.navigateToConfirmation = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isBooking = false
                    self.errorMessage = "Failed to book: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func patientOptionCard(id: String, name: String, relation: String, isSelected: Bool) -> some View {
        HStack {
            Image(systemName: relation == "Self" ? "person.fill" : "person.2.fill")
                .foregroundColor(isSelected ? .white : .appBlue)
                .padding(10)
                .background(isSelected ? Color.white.opacity(0.3) : Color.appBlue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .black)
                Text(relation)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(isSelected ? Color.appBlue : Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            withAnimation {
                self.selectedPatientId = id
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.appBlue, lineWidth: isSelected ? 0 : 1)
        )
    }
    
    func fetchFamilyMembers() {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else { return }
        self.isLoading = true
        Task {
            await SupabaseDBManager.shared.getFamilyMembers(userId: userId) { success, model in
                self.isLoading = false
                if success {
                    self.familyMembers = model.members
                }
            }
        }
    }
}
