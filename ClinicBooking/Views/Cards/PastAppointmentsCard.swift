//
//  PastAppointmentsCard.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 27/09/24.
//

import SwiftUI

struct PastAppointmetsCard: View {
    var image: String
    var name: String
    var speciality: String
    var date: String
    var time: String
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 15) {
                if image.hasPrefix("http") {
                    AsyncImage(url: URL(string: image)) { img in
                        img.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                            .frame(width: 40, height: 40)
                            .background(Color.doctorBG)
                            .clipShape(Circle())
                    }
                } else {
                    ImageCircle(icon: image, radius: 20, circleColor: Color.doctorBG)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(name)
                        .font(.customFont(style: .bold, size: .h14))
                    Text(speciality)
                        .font(.customFont(style: .medium, size: .h13))

                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            Divider()
            HStack {
                Image(systemName: "calendar")
                Text(date)
                    .font(.customFont(style: .medium, size: .h15))
                Spacer()
                Image(systemName: "clock")
                Text(time)
                    .font(.customFont(style: .medium, size: .h15))
            }
            .padding()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    PastAppointmetsCard(
        image: "edwin",
        name: "Janarthanan Kannan",
        speciality: "General Medicine",
        date: "7 June",
        time: "10:00 AM"
    )
}
