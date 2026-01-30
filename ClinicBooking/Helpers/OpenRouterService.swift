//
//  OpenRouterService.swift
//  ClinicBooking
//
//  Created by AI Assistant on 21/01/26.
//

import Foundation

class OpenRouterService {
    static let shared = OpenRouterService()
    
    private let apiKey: String
    private let model: String
    private let apiURL: URL
    private let appName: String
    private let siteURL: String
    
    private init() {
        guard let path = Bundle.main.path(forResource: "OpenRouterConfig", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let key = config["API_KEY"] as? String,
              let modelName = config["MODEL"] as? String,
              let urlString = config["API_URL"] as? String,
              let url = URL(string: urlString),
              let name = config["APP_NAME"] as? String,
              let site = config["SITE_URL"] as? String else {
            fatalError("OpenRouter configuration missing. Ensure OpenRouterConfig.plist exists.")
        }
        
        self.apiKey = key
        self.model = modelName
        self.apiURL = url
        self.appName = name
        self.siteURL = site
    }
    
    func sendMessage(_ userMessage: String, conversationHistory: [ChatMessage]) async throws -> String {
        // Build messages array with system prompt
        var messages: [[String: String]] = [
            [
                "role": "system",
                "content": """
                You are a helpful medical assistant for the ClinicBooking app. You provide general health information, 
                help users understand symptoms, and guide them on when to see a doctor. 
                
                IMPORTANT RULES:
                - You NEVER diagnose conditions or prescribe treatments
                - Always remind users that you're not a replacement for professional medical advice
                - Be empathetic and supportive
                - Keep responses concise and easy to understand
                - If a symptom sounds serious, always recommend seeing a doctor immediately
                - Do not request or store any personally identifiable health information
                """
            ]
        ]
        
        // Add conversation history (last 10 messages for context)
        let recentHistory = conversationHistory.suffix(10)
        for message in recentHistory {
            messages.append([
                "role": message.isUser ? "user" : "assistant",
                "content": message.content
            ])
        }
        
        // Add current user message
        messages.append([
            "role": "user",
            "content": userMessage
        ])
        
        // Build request body
        let requestBody: [String: Any] = [
            "model": model,
            "messages": messages,
            "max_tokens": 1000,
            "temperature": 0.7
        ]
        
        // Create request
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(siteURL, forHTTPHeaderField: "HTTP-Referer")
        request.setValue(appName, forHTTPHeaderField: "X-Title")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Send request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenRouterError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw OpenRouterError.apiError(errorData.error.message)
            }
            throw OpenRouterError.httpError(httpResponse.statusCode)
        }
        
        // Parse response
        let decoder = JSONDecoder()
        let chatResponse = try decoder.decode(ChatCompletionResponse.self, from: data)
        
        guard let content = chatResponse.choices.first?.message.content else {
            throw OpenRouterError.emptyResponse
        }
        
        return content
    }
}

// MARK: - Response Models
struct ChatCompletionResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

struct ErrorResponse: Codable {
    let error: ErrorDetail
    
    struct ErrorDetail: Codable {
        let message: String
    }
}

// MARK: - Errors
enum OpenRouterError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case emptyResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return "API error: \(message)"
        case .emptyResponse:
            return "Received empty response"
        }
    }
}
