//
//  ChatBubble.swift
//  ClinicBooking
//
//  Created by AI Assistant on 21/01/26.
//

import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !message.isUser {
                // AI Avatar
                Image(systemName: "stethoscope.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.appBlue)
                    .padding(.top, 4)
            } else {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.customFont(style: .medium, size: .h15))
                    .foregroundColor(message.isUser ? .white : .text)
                    .padding(12)
                    .background(
                        message.isUser ?
                        Color.appBlue :
                        Color.card
                    )
                    .cornerRadius(16)
                
                // Timestamp
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.customFont(style: .medium, size: .h11))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 600 : .infinity, alignment: message.isUser ? .trailing : .leading)
            
            if message.isUser {
                // User Avatar
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            } else {
                Spacer()
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ChatBubble(message: ChatMessage(content: "Hello! How can I help you today?", isUser: false))
        ChatBubble(message: ChatMessage(content: "I have a headache. What should I do?", isUser: true))
    }
    .padding()
}
