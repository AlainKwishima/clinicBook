//
//  DoctorAppointmentsView.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI

struct DoctorAppointmentsView: View {
    @State private var upcomingAppointments: [Appointment] = []
    @State private var pastAppointments: [Appointment] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if upcomingAppointments.isEmpty && pastAppointments.isEmpty {
                    VStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No appointments yet")
                            .font(.headline)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(.vertical) {
                        if !upcomingAppointments.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Upcoming")
                                    .font(.customFont(style: .bold, size: .h16))
                                    .padding(.horizontal, 16)
                                ForEach(upcomingAppointments) { appointment in
                                    // Reusing generic appointment card, but ideally we show Patient Name
                                     UpcomingAppointmentCardView(
                                        address: "",
                                        date: appointment.date.formatted(date: .abbreviated, time: .omitted),
                                        time: appointment.time,
                                        name: "Patient Name", // Placeholder until backend links patient details
                                        speciality: "Consultation",
                                        image: "user"
                                    )
                                    .padding([.leading, .trailing], 16)
                                    .padding(.bottom, 10)
                                }
                            }
                            .padding([.top, .bottom], 10)
                        }
                        
                        if !pastAppointments.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Past")
                                    .font(.customFont(style: .bold, size: .h16))
                                    .padding(.horizontal, 16)
                                ForEach(pastAppointments) { appointment in
                                    PastAppointmetsCard(
                                        image: "user",
                                        name: "Patient Name",
                                        speciality: "Checkup",
                                        date: appointment.date.formatted(date: .abbreviated, time: .omitted),
                                        time: appointment.time
                                    )
                                    .padding([.leading, .trailing], 16)
                                    .padding(.bottom, 5)
                                }
                            }
                        }
                        Spacer()
                    }
                    .background(Color.lightGray.opacity(0.7))
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 850 : .infinity)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("My Appointments")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchAppointments()
            }
        }
    }
    
    func fetchAppointments() {
        // Mock data for now, actual implementation needs backend query for "appointments where doctorID == currentUserID"
        // This confirms the UI structure.
        self.isLoading = false
    }
}
