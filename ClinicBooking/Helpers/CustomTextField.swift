//
//  CustomTextField.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 01/09/24.
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    @State var isSecure: Bool = false
    @State private var showPassword: Bool = false
    @FocusState private var isFieldFocus: FieldToFocus?
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        HStack {
            if isSecure {
                if showPassword {
                    TextField(placeholder, text: $text)
                        .font(.customFont(style: .medium, size: .h16))
                        .focused($isFieldFocus, equals: .textField)
                        .keyboardType(.default)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } else {
                    SecureField(placeholder, text: $text)
                        .font(.customFont(style: .medium, size: .h16))
                        .focused($isFieldFocus, equals: .secureField)
                        .keyboardType(.default)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            } else {
                TextField(placeholder, text: $text)
                    .font(.customFont(style: .medium, size: .h16))
                    .keyboardType(.default)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            if isSecure && !text.isEmpty {
                Button(action: {
                    self.showPassword.toggle()
                }, label: {
                    Image(systemName: self.showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.gray)
                })
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: sizeClass == .regular ? 450 : .infinity, minHeight: 60)
        .background(Color.bg)
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.lightGray, lineWidth: 2)
        )
    }

    enum FieldToFocus {
        case secureField, textField
    }
}

#Preview {
    VStack {
        CustomTextField(placeholder: "Email", text: .constant(""))
        CustomTextField(placeholder: "Password", text: .constant("123456"), isSecure: true)
    }
    .padding()
}

struct TextFieldLimitModifier: ViewModifier {
    @Binding var value: String
    var length: Int

    func body(content: Content) -> some View {
        content
            .onReceive(value.publisher.collect()) {
                value = String($0.prefix(length))
            }
    }
}

extension View {
    func limitInputLength(value: Binding<String>, length: Int) -> some View {
        self.modifier(TextFieldLimitModifier(value: value, length: length))
    }
}
