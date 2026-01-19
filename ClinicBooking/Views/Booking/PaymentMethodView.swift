//
//  PaymentMethodView.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI

struct PaymentMethodView: View {
    var doctor: Doctor
    var date: Date
    var time: String
    var patientName: String
    var patientId: String
    
    @State private var selectedMethod = "Credit Card"
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    
    let paymentMethods = ["Credit Card", "Apple Pay", "PayPal"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Payment Method")
                .font(.customFont(style: .bold, size: .h20))
                .padding(.top)
            
            // Order Summary
            VStack(alignment: .leading, spacing: 10) {
                Text("Order Summary")
                    .font(.headline)
                HStack {
                    Text("Consultation Fee")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(doctor.fee != nil ? "$\(String(format: "%.2f", doctor.fee!))" : "$50.00")
                        .bold()
                }
                Divider()
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text(doctor.fee != nil ? "$\(String(format: "%.2f", doctor.fee!))" : "$50.00")
                        .font(.headline)
                        .foregroundColor(.appBlue)
                }
            }
            .padding()
            .background(Color.lightGray.opacity(0.3))
            .cornerRadius(12)
            
            Text("Select Payment Method")
                .font(.headline)
                .padding(.top)
            
            ForEach(paymentMethods, id: \.self) { method in
                HStack {
                    Image(systemName: methodIcon(method))
                        .foregroundColor(.appBlue)
                        .frame(width: 30)
                    Text(method)
                        .font(.customFont(style: .medium, size: .h16))
                    Spacer()
                    if selectedMethod == method {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.appBlue)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                .onTapGesture {
                    selectedMethod = method
                }
            }
            
            Spacer()
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button {
                processPaymentAndBook()
            } label: {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Pay & Confirm")
                        .font(.customFont(style: .bold, size: .h17))
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(BlueButtonStyle(height: 55, color: .appBlue))
            .disabled(isLoading)
            .navigationDestination(isPresented: $showSuccess) {
                BookingConfirmationView(doctor: doctor, date: date, time: time)
            }
        }
        .padding()
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func methodIcon(_ method: String) -> String {
        switch method {
        case "Credit Card": return "creditcard.fill"
        case "Apple Pay": return "applelogo"
        case "PayPal": return "dollarsign.circle.fill"
        default: return "creditcard"
        }
    }
    
    func processPaymentAndBook() {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else { return }
        isLoading = true
        
        // Simulate Payment Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            let appointment = Appointment(
                doctorId: doctor.doctorID,
                userId: userId,
                patientName: patientName,
                doctorName: doctor.name,
                doctorImage: doctor.image,
                doctorSpeciality: doctor.specialist,
                date: date,
                time: time,
                status: "upcoming",
                location: doctor.address,
                createdAt: Date()
            )
            
            Task {
                do {
                    try await SupabaseDBManager.shared.saveAppointment(appointment: appointment)
                    self.isLoading = false
                    self.showSuccess = true
                } catch {
                    self.isLoading = false
                    self.errorMessage = "Booking failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
