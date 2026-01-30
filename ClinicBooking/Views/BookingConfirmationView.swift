//
//  BookingConfirmationView.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI

struct BookingConfirmationView: View {
    var doctor: Doctor
    var date: Date
    var time: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            
            Text("Appointment Confirmed!")
                .font(.customFont(style: .bold, size: .h24))
            
            Text("You have successfully booked an appointment with")
                .font(.customFont(style: .medium, size: .h15))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            VStack(spacing: 15) {
                HStack {
                    AsyncImage(url: URL(string: doctor.image)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image("user").resizable()
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(doctor.name)
                            .font(.headline)
                        Text(doctor.specialist)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.lightGray.opacity(0.3))
                .cornerRadius(12)
                
                HStack {
                    Image(systemName: "calendar")
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                    Spacer()
                    Image(systemName: "clock")
                    Text(time)
                }
                .padding()
                .background(Color.lightGray.opacity(0.3))
                .cornerRadius(12)
            }
            .padding()
            
            Spacer()
            
            Button {
                // Return to home by dismissing the confirmation and search flow
                // Since this might be deep in a stack, we can use a root notification or dismiss environment
                // For now, closing the search sheet is the most common expected behavior
                NotificationCenter.default.post(name: NSNotification.Name("DismissSearch"), object: nil)
            } label: {
                Text("Back to Home")
                    .font(.customFont(style: .bold, size: .h17))
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                    .frame(height: 55)
                    .background(Color.appBlue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}
