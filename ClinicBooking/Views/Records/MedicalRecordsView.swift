//
//  MedicalRecordsView.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI

struct MedicalRecordsView: View {
    @State private var selectedSegment = 0
    let segments = ["Prescriptions", "Lab Reports", "Vaccinations"]
    
    var body: some View {
        VStack {
            // Segmented Control
            Picker("Records Type", selection: $selectedSegment) {
                ForEach(0..<segments.count, id: \.self) { index in
                    Text(segments[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Spacer()
            
            // Content
            VStack(spacing: 20) {
                Image(systemName: getIconForSegment(selectedSegment))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray.opacity(0.5))
                
                Text("No \(segments[selectedSegment]) Found")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.gray)
                
                Text(getDescriptionForSegment(selectedSegment))
                    .font(.subheadline)
                    .foregroundColor(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    // Upload action
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Upload Document")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.appBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .navigationTitle("Medical Records")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func getIconForSegment(_ index: Int) -> String {
        switch index {
        case 0: return "doc.text"
        case 1: return "flask.fill"
        case 2: return "syringe.fill"
        default: return "doc"
        }
    }
    
    func getDescriptionForSegment(_ index: Int) -> String {
        switch index {
        case 0: return "Your doctor prescriptions will appear here."
        case 1: return "Upload or view your lab test results safely."
        case 2: return "Keep track of your immunization history."
        default: return ""
        }
    }
}

#Preview {
    MedicalRecordsView()
}
