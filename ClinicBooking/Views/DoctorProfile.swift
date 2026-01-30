//
//  DoctorProfile.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI

struct DoctorProfile: View {
    var doctorDetail: Doctor
    @Environment(\.dismiss) var dismiss
    @State private var selectedTimeSegment = "Morning"
    @State private var selectedTimeSlot: String?
    @State private var selectedDate = Date()
    @State private var navigateToPatientSelection = false
    
    let timeSegments = ["Morning", "Afternoon", "Evening", "Night"]
    
    // Mock data for time slots based on segment
    var timeSlots: [String] {
        switch selectedTimeSegment {
        case "Morning": return ["08-09 AM", "09-10 AM", "10-11 AM", "11-12 AM"]
        case "Afternoon": return ["01-02 PM", "02-03 PM", "03-04 PM", "04-05 PM"]
        case "Evening": return ["05-06 PM", "06-07 PM", "07-08 PM"]
        case "Night": return ["08-09 PM", "09-10 PM"]
        default: return []
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // 1. Header: Avatar + Info
                    HStack(alignment: .center, spacing: 20) {
                        // Avatar
                        if doctorDetail.image.isEmpty {
                             Image("user")
                                 .resizable()
                                 .scaledToFill()
                                 .frame(width: 100, height: 100)
                                 .clipShape(Circle())
                                 .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1))
                        } else {
                            AsyncImage(url: URL(string: doctorDetail.image)) { phase in
                                switch phase {
                                case .empty:
                                    Circle().fill(Color.gray.opacity(0.1))
                                        .overlay(ProgressView())
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                case .failure:
                                    Image("user").resizable().scaledToFill()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1))
                        }
                        
                        // Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(doctorDetail.name)
                                .font(.customFont(style: .bold, size: .h20))
                                .foregroundColor(.black)
                            
                            Text(doctorDetail.specialist)
                                .font(.customFont(style: .medium, size: .h16))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 12))
                                Text(doctorDetail.rating)
                                    .font(.customFont(style: .medium, size: .h15))
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                Text("(2530)") // Placeholder count to match design
                                    .font(.customFont(style: .medium, size: .h13))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.top, 10)
                    
                    // 2. Biography
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Doctor Biography")
                            .font(.customFont(style: .bold, size: .h18))
                            .foregroundColor(.black)
                        
                        Text(doctorDetail.about)
                            .font(.customFont(style: .medium, size: .h15))
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                    }
                    
                    // 3. Schedules
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Schedules")
                            .font(.customFont(style: .bold, size: .h18))
                            .foregroundColor(.black)
                        
                        HStack {
                            Text("Date")
                                .font(.customFont(style: .medium, size: .h16))
                                .foregroundColor(.black)
                            Spacer()
                            Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.customFont(style: .medium, size: .h16))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(8)
                        }
                    }
                    
                    // 4. Choose Times
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Choose Times")
                            .font(.customFont(style: .bold, size: .h18))
                            .foregroundColor(.black)
                        
                        // Custom Segment Control
                        HStack(spacing: 0) {
                            ForEach(timeSegments, id: \.self) { segment in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedTimeSegment = segment
                                    }
                                } label: {
                                    Text(segment)
                                        .font(.customFont(style: .medium, size: .h13))
                                        .fontWeight(selectedTimeSegment == segment ? .bold : .regular)
                                        .foregroundColor(selectedTimeSegment == segment ? .black : .gray)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(selectedTimeSegment == segment ? Color.white : Color.clear)
                                        .cornerRadius(selectedTimeSegment == segment ? 8 : 0)
                                        .shadow(color: selectedTimeSegment == segment ? .black.opacity(0.1) : .clear, radius: 2)
                                }
                            }
                        }
                        .padding(4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)

                        // Time Slots Container
                        VStack(alignment: .leading, spacing: 15) {
                            Text("\(selectedTimeSegment) Schedule")
                                .font(.customFont(style: .bold, size: .h16))
                                .foregroundColor(.black)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                                ForEach(timeSlots, id: \.self) { time in
                                    Button {
                                        selectedTimeSlot = time
                                    } label: {
                                        Text(time)
                                            .font(.customFont(style: .medium, size: .h15))
                                            .padding(.vertical, 12)
                                            .frame(maxWidth: .infinity)
                                            .background(selectedTimeSlot == time ? Color.appBlue : Color.white)
                                            .foregroundColor(selectedTimeSlot == time ? .white : .black)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.blue.opacity(0.1)) // Light blue background for schedule
                        .cornerRadius(20)
                    }
                    
                    Spacer(minLength: 80) // Space for bottom button visibility
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            
            // Bottom Booking Button
            VStack {
                Button {
                    if selectedTimeSlot != nil {
                        navigateToPatientSelection = true
                    }
                } label: {
                    Text("Book Appointment")
                        .font(.customFont(style: .bold, size: .h18))
                        .foregroundColor(.white)
                        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 400 : .infinity)
                        .padding()
                        .background(selectedTimeSlot != nil ? Color.appBlue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(selectedTimeSlot == nil)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white)
        }
        .navigationTitle("Doctor Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToPatientSelection) {
            if let timeSlot = selectedTimeSlot {
                PatientSelectionView(
                    doctor: doctorDetail,
                    date: selectedDate,
                    time: timeSlot
                )
            }
        }
    }
}

#Preview {
    NavigationView {
        DoctorProfile(doctorDetail: Doctor(doctorID: "1", name: "Amy Arreaza", specialist: "General Surgery", degree: "MBBS", image: "", position: "Senior", languageSpoken: "English", about: "Amy graduated as a Family Nurse Practitioner from the University of Utah in 2008. As a FNP she worked in wound care and urgent care prior to joining Clinica Sierra Vista in 2014.", contact: "1234567890", address: "123 Medical Center", rating: "4.5", isPopular: true, isSaved: false, fee: 50.99))
    }
}
