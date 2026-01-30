//
//  ButtonStyles.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 19/09/24.
//

import SwiftUI

struct BlueButtonStyle: ButtonStyle {
    var height: CGFloat
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundColor(.white)
            .frame(height: height)
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 400 : .infinity)
            .background(color)
            .cornerRadius(10)
    }
}

struct BorderButtonStyle: ButtonStyle {
    var borderColor: Color
    var foregroundColor: Color
    var height: CGFloat
    var background: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundColor(foregroundColor)
            .frame(height: height)
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 400 : .infinity)
            .background(background)
            .overlay(RoundedRectangle(cornerRadius: 30)
                .stroke(borderColor, lineWidth: 2))
    }
}
