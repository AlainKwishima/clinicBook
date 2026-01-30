//
//  MedicalAssistantView.swift
//  ClinicBooking
//
//  Created by AI Assistant on 21/01/26.
//

import SwiftUI

struct MedicalAssistantView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var showClearAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if viewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .padding(12)
                                    Text("Thinking...")
                                        .font(.customFont(style: .medium, size: .h14))
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input Area
                inputArea
            }
            .navigationTitle("AI Medical Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showClearAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.appBlue)
                    }
                }
            }
            .alert("Clear Conversation?", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    viewModel.clearConversation()
                }
            } message: {
                Text("This will delete all messages in this conversation.")
            }
        }
    }
    
    private var disclaimerBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.system(size: 14))
            
            Text("Not a substitute for professional medical advice")
                .font(.customFont(style: .medium, size: .h12))
                .foregroundColor(.text)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.orange.opacity(0.1))
    }
    
    private var inputArea: some View {
        HStack(spacing: 12) {
            TextField("Ask me anything...", text: $viewModel.currentInput, axis: .vertical)
                .font(.customFont(style: .medium, size: .h15))
                .padding(12)
                .background(Color.card)
                .cornerRadius(20)
                .lineLimit(1...4)
                .submitLabel(.send)
                .onSubmit {
                    viewModel.sendMessage()
                }
            
            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .appBlue)
            }
            .disabled(viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
        }
        .padding()
        .background(Color.bg)
    }
}

#Preview {
    MedicalAssistantView()
}
