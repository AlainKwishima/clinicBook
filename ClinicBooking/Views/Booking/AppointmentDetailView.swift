//
//  AppointmentDetailView.swift
//  ClinicBooking
//
//  Created by Assistant on 12/01/26.
//

import SwiftUI

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
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Timing & Location
                VStack(alignment: .leading, spacing: 20) {
                    DetailRow(icon: "calendar", title: "Date", value: appointment.date.formatted(date: .long, time: .omitted))
                    DetailRow(icon: "clock", title: "Time", value: appointment.time)
                    DetailRow(icon: "mappin.circle.fill", title: "Location", value: appointment.location)
                }
                .padding()
                .background(Color.white)
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
                .background(Color.white)
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
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .disabled(isCancelling)
                .padding(.bottom, 20)
            }
            .padding()
        }
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
                try await FireStoreManager.shared.cancelAppointment(appointmentId: id)
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
            }
        }
    }
}
