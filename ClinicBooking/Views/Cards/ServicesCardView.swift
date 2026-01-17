//
//  ServicesCardView.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 02/09/24.
//

import SwiftUI

struct ServicesCardView: View {
    var image: String
    var title: String
    var isSymbol: Bool = false
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.lightBlue.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.appBlue.opacity(isHovered ? 0.2 : 0.05), radius: isHovered ? 12 : 5)
                
                if isSymbol {
                    Image(systemName: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.appBlue)
                } else {
                    Image(image).resizable()
                        .frame(width: 45, height: 45)
                }
            }
            .scaleEffect(isHovered ? 1.1 : 1.0)
            
            Text(title)
                .font(.customFont(style: .bold, size: .h15))
                .foregroundColor(isHovered ? .appBlue : .text)
        }
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    ServicesCardView(image: "cardiology", title: "Cardiology")
}
