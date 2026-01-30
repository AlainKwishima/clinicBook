//
//  UIFont+Extension.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 01/09/24.
//

import Foundation
import SwiftUI

extension Font {
    static func customFont(
        style: FontStyle,
        size: FontSize,
        isScaled: Bool = true
    ) -> Font {

        let fontName: String = "Futura" + style.rawValue
        return Font.custom(fontName, size: size.rawValue)
    }
}

enum FontStyle: String {
    case medium = "-Medium"
    case mediumItalic = "-MediumItalic"
    case bold = "-Bold"
    case condensedMedium = "-CondensedMedium"
    case condensedExtraBold = "-CondensedExtraBold"
}

enum FontSize: CGFloat {
    case h11 = 10.0
    case h12 = 11.0
    case h13 = 12.0
    case h14 = 13.0
    case h15 = 14.0
    case h16 = 15.0
    case h17 = 16.0
    case h18 = 17.0
    case h20 = 19.0
    case h22 = 21.0
    case h24 = 23.0
    case h26 = 25.0
    case h27 = 26.0
    case h28 = 27.0
    case h30 = 29.0
    case h31 = 30.0
    case h32 = 31.0
    case h33 = 32.0
    case h34 = 33.0
    case h35 = 34.0
    case h36 = 35.0
    case h37 = 36.0
    case h38 = 37.0
}
