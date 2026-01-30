//
//  ChatViewModel.swift
//  ClinicBooking
//
//  Created by AI Assistant on 21/01/26.
//

import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service = OpenRouterService.shared
    
    init() {
        // Add welcome message
        addWelcomeMessage()
    }
    
    private func addWelcomeMessage() {
        let welcomeMessage = ChatMessage(
            content: """
            👋 Hello! I'm your AI Medical Assistant.
            
            I can help you with:
            • General health questions
            • Understanding symptoms
            • Preparing for appointments
            • Health and wellness tips
            
            ⚠️ Important: I'm not a doctor and can't diagnose conditions or prescribe treatments. Always consult a healthcare professional for medical advice.
            
            How can I help you today?
            """,
            isUser: false
        )
        messages.append(welcomeMessage)
    }
    
    func sendMessage() {
        let trimmedInput = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(content: trimmedInput, isUser: true)
        messages.append(userMessage)
        
        // Clear input
        currentInput = ""
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Get current user ID and profile for tracking and context
                let userId = UserDefaults.standard.string(forKey: "userID")
                let user: AppUser? = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
                
                let response = try await service.sendMessage(trimmedInput, conversationHistory: messages, user: user, userId: userId)
                
                // Add AI response
                let aiMessage = ChatMessage(content: response, isUser: false)
                messages.append(aiMessage)
                
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
                
                // Add error message to chat
                let errorMsg = ChatMessage(
                    content: "Sorry, I encountered an error: \(error.localizedDescription). Please try again.",
                    isUser: false
                )
                messages.append(errorMsg)
            }
        }
    }
    
    func clearConversation() {
        messages.removeAll()
        addWelcomeMessage()
        errorMessage = nil
    }
}
