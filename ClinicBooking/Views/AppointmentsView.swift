//
//  AppointmentsView.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 26/09/24.
//

import SwiftUI

struct AppointmentsView: View {
    @State private var upcomingAppointments: [Appointment] = []
    @State private var pastAppointments: [Appointment] = []
    @State private var isLoading = false
    @State private var showSearch = false
    @State private var showNotifications = false
    @State private var defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {

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
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 0) {
                                        ForEach(upcomingAppointments) { appointment in
                                            NavigationLink(destination: AppointmentDetailView(appointment: appointment)) {
                                                UpcomingAppointmentCardView(
                                                    address: appointment.location,
                                                    date: appointment.date.formatted(date: .abbreviated, time: .omitted),
                                                    time: appointment.time,
                                                    name: appointment.doctorName,
                                                    speciality: appointment.doctorSpeciality,
                                                    image: appointment.doctorImage
                                                )
                                                .frame(width: min(UIScreen.main.bounds.width - 30, 400))
                                                .padding([.leading, .trailing], 16)
                                            }
                                        }
                                    }
                                }
                                .scrollTargetBehavior(.paging)
                            }
                            .padding([.top, .bottom], 10)
                        }
                        
                        if !pastAppointments.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Past")
                                    .font(.customFont(style: .bold, size: .h16))
                                    .padding(.horizontal, 16)
                                
                                let columns = [GridItem(.adaptive(minimum: 320), spacing: 15)]
                                
                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(pastAppointments) { appointment in
                                        NavigationLink(destination: AppointmentDetailView(appointment: appointment)) {
                                            PastAppointmetsCard(
                                                image: appointment.doctorImage,
                                                name: appointment.doctorName,
                                                speciality: appointment.doctorSpeciality,
                                                date: appointment.date.formatted(date: .abbreviated, time: .omitted),
                                                time: appointment.time
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        Spacer()
                    }
                    .background(Color.lightGray.opacity(0.7))
                }
            }
            .navigationTitle("Appointments")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showSearch) {
                SearchFilterView()
            }
            .navigationDestination(isPresented: $showNotifications) {
                NotificationCenterView()
            }
            .onAppear {
                fetchAppointments()
            }
        }
    }
    
    func fetchAppointments() {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            // If no user ID, just load mock data for demo
            loadMockData()
            return
        }
        self.isLoading = true
        Task {
            do {
                var appointments = try await SupabaseDBManager.shared.fetchUserAppointments(userId: userId)
                
                if appointments.isEmpty {
                    appointments = getMockAppointments()
                }
                
                let now = Date()
                self.upcomingAppointments = appointments.filter { $0.date >= now }
                self.pastAppointments = appointments.filter { $0.date < now }
                
                self.isLoading = false
            } catch {
                print("Error loading appointments: \(error)")
                // Fallback to mock data on error
                loadMockData()
                self.isLoading = false
            }
        }
    }
    
    func loadMockData() {
        let appointments = getMockAppointments()
        let now = Date()
        self.upcomingAppointments = appointments.filter { $0.date >= now }
        self.pastAppointments = appointments.filter { $0.date < now }
    }

    func getMockAppointments() -> [Appointment] {
        return [
            Appointment(doctorId: "mock1", userId: "user1", patientName: "Myself", doctorName: "Dr. Smith", doctorImage: "doctor_1", doctorSpeciality: "Cardiologist", date: Date().addingTimeInterval(86400), time: "10:00 AM", status: "upcoming", location: "City Heart Center", createdAt: Date()),
            Appointment(doctorId: "mock2", userId: "user1", patientName: "Myself", doctorName: "Dr. Emily", doctorImage: "doctor_2", doctorSpeciality: "Dermatologist", date: Date().addingTimeInterval(172800), time: "02:30 PM", status: "upcoming", location: "Skin Clinic", createdAt: Date()),
             Appointment(doctorId: "mock3", userId: "user1", patientName: "Myself", doctorName: "Dr. Brown", doctorImage: "doctor_3", doctorSpeciality: "General", date: Date().addingTimeInterval(-86400), time: "09:00 AM", status: "completed", location: "General Hospital", createdAt: Date())
        ]
    }
}

#Preview {
    AppointmentsView()
}

struct AppointmentDetailView: View {
    let appointment: Appointment
    @Environment(\.dismiss) var dismiss
    @State private var showCancelAlert = false
    @State private var isCancelling = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Doctor Info Card
                HStack(spacing: 15) {
                    Image(appointment.doctorImage) // Ensure asset exists or fallback
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(appointment.doctorName)
                            .font(.customFont(style: .bold, size: .h20))
                        Text(appointment.doctorSpeciality)
                            .font(.customFont(style: .medium, size: .h16))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.card)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Timing & Location
                VStack(alignment: .leading, spacing: 20) {
                    DetailRow(icon: "calendar", title: "Date", value: appointment.date.formatted(date: .long, time: .omitted))
                    DetailRow(icon: "clock", title: "Time", value: appointment.time)
                    DetailRow(icon: "mappin.circle.fill", title: "Location", value: appointment.location)
                }
                .padding()
                .background(Color.card)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Additional Info
                VStack(alignment: .leading, spacing: 10) {
                    Text("Patient Details")
                        .font(.headline)
                    Text("Patient: \(appointment.patientName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Status: \(appointment.status.capitalized)")
                        .font(.subheadline)
                        .foregroundColor(appointment.status == "cancelled" ? .red : .appBlue)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.card)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                Spacer()
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }

                // Privacy / Notes
                Text("Please arrive 15 minutes before your scheduled appointment time.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding()
                
                // Cancel Button
                VStack(spacing: 15) {
                    if appointment.status == "completed" && !appointment.isPaid {
                        NavigationLink(destination: PaymentMethodView(
                            doctor: Doctor(doctorID: appointment.doctorId, name: appointment.doctorName, specialist: appointment.doctorSpeciality, degree: "", image: appointment.doctorImage, position: "", languageSpoken: "", about: "", contact: "", address: appointment.location, rating: "5.0", isPopular: false, isSaved: false, fee: 50.00), // Reconstruct doctor for payment
                            date: appointment.date,
                            time: appointment.time,
                            patientName: appointment.patientName,
                            patientId: appointment.userId,
                            appointmentId: appointment.id
                        )) {
                            Text("Pay Consultation Fee")
                                .font(.customFont(style: .bold, size: .h17))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                                .background(Color.appBlue)
                                .cornerRadius(12)
                        }
                    }

                    Button(action: {
                        showCancelAlert = true
                    }) {
                        if isCancelling {
                            ProgressView()
                                .tint(.red)
                        } else {
                            Text("Cancel Appointment")
                                .font(.customFont(style: .bold, size: .h17))
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .disabled(isCancelling)
                }
                .padding(.bottom, 20)
            }
            .padding()
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .background(Color.bg)
        .navigationTitle("Appointment Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Cancel Appointment", isPresented: $showCancelAlert) {
            Button("Cancel Appointment", role: .destructive) {
                cancelAppointment()
            }
            Button("Keep", role: .cancel) { }
        } message: {
            Text("Are you sure you want to cancel this appointment? This action cannot be undone.")
        }
    }
    
    func cancelAppointment() {
        guard let id = appointment.id else { return } // Assuming Appointment has an optional ID from Firestore
        isCancelling = true
        
        Task {
            do {
                try await SupabaseDBManager.shared.cancelAppointment(appointmentId: id)
                DispatchQueue.main.async {
                    self.isCancelling = false
                    self.dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isCancelling = false
                    self.errorMessage = "Failed to cancel: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.appBlue)
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.customFont(style: .medium, size: .h16))
                    .foregroundColor(.text)
            }
        }
    }
}


