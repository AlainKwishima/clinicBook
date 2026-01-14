//
//  PatientHistoryView.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI

struct PatientHistoryView: View {
    // Mock Data for UI
    struct PatientRecord: Identifiable {
        let id = UUID()
        let name: String
        let lastVisit: String
        let diagnosis: String
        let image: String
    }
    
    let patients = [
        PatientRecord(name: "John Doe", lastVisit: "Oct 24, 2024", diagnosis: "Flu", image: "user"),
        PatientRecord(name: "Jane Smith", lastVisit: "Oct 20, 2024", diagnosis: "Migraine", image: "user"),
        PatientRecord(name: "Robert Brown", lastVisit: "Sep 15, 2024", diagnosis: "Checkup", image: "user")
    ]
    
    var body: some View {
        NavigationStack {
            List(patients) { patient in
                HStack {
                    Image(patient.image)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(patient.name)
                            .font(.headline)
                        Text("Last Visit: \(patient.lastVisit)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(patient.diagnosis)
                        .font(.subheadline)
                        .foregroundColor(.appBlue)
                        .padding(6)
                        .background(Color.appBlue.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.vertical, 5)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Patient History")
        }
    }
}
