//
//  DoctorHomeTab.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI

struct DoctorHomeTab: View {
    @State var defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
    @State var todayAppointments: [Appointment] = []
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 25) {
                if UIDevice.current.userInterfaceIdiom != .pad {
                    headerView
                        .padding(.top, 10)
                }
            
            // Stats Overview
            HStack(spacing: 15) {
                StatCard(title: "Pending", count: "3", color: .orange)
                StatCard(title: "Confirmed", count: "8", color: .appBlue)
                StatCard(title: "Completed", count: "12", color: .green)
            }
            .padding(.horizontal)
            .padding(.vertical)
            
            // Today's Schedule
            VStack(alignment: .leading) {
                Text("Today's Schedule")
                    .font(.customFont(style: .bold, size: .h18))
                    .padding(.horizontal)
                
                if todayAppointments.isEmpty {
                    Text("No appointments for today.")
                        .font(.customFont(style: .medium, size: .h15))
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    let columns = [GridItem(.adaptive(minimum: 350), spacing: 15)]
                    
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(todayAppointments) { appointment in
                            UpcomingAppointmentCardView(
                                address: "", 
                                date: appointment.time, 
                                time: appointment.time,
                                name: appointment.doctorName, 
                                speciality: "General Checkup", 
                                image: "user" 
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 16)
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 1100 : .infinity)
            .frame(maxWidth: .infinity)
        }
    }
    
    var headerView: some View {
        HStack {
            Button(action: {
                
            }, label: {
                AsyncImage(
                    url: URL(string: defaults?.imageURL ?? ""),
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 35, maxHeight: 35)
                            .clipShape(Circle())
                    },
                    placeholder: {
                        if defaults?.imageURL == "" {
                            Image("user").resizable()
                                .frame(width: 35, height: 35)
                        } else {
                            ProgressView()
                        }
                    })
            })
            VStack(alignment: .leading) {
                Text("Hello Dr. \(defaults?.lastName ?? "")")
                    .font(.customFont(style: .bold, size: .h15))
                Text("Have a great day at work!")
                    .font(.customFont(style: .medium, size: .h13))
                    .foregroundColor(.gray)
            }
            Spacer()
            
            Button(action: {
                // Notification action
            }, label: {
                Image(systemName: "bell.circle")
                    .font(.customFont(style: .medium, size: .h24))
                    .foregroundColor(Color.appBlue)
            })
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
    }
}

struct StatCard: View {
    let title: String
    let count: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(count)
                .font(.title)
                .bold()
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(color)
        .cornerRadius(12)
    }
}
