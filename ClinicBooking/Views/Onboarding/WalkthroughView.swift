//
//  WalkthroughView.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI

struct WalkthroughView: View {
    @Binding var isActive: Bool
    @State private var currentPage = 0
    
    let pages = [
        WalkthroughPage(image: "onboard_1", title: "Find Trusted Doctors", description: "Get the best medical consultation from trusted doctors near you."),
        WalkthroughPage(image: "onboard_2", title: "Instant Booking", description: "Book appointments instantly and manage your schedule with ease."),
        WalkthroughPage(image: "onboard_3", title: "Manage Your Health", description: "Keep track of your medical history, prescriptions, and family health in one place.")
    ]
    
    var body: some View {
        ZStack {
            Color.bg.ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeWalkthrough()
                    }
                    .foregroundColor(.gray)
                    .padding()
                }
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 20) {
                            Image(pages[index].image) // Ensure these assets exist or use system images as fallback
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .padding(.top, 40)
                            
                            Text(pages[index].title)
                                .font(.title)
                                .bold()
                                .foregroundColor(.text)
                                .multilineTextAlignment(.center)
                            
                            Text(pages[index].description)
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                Spacer()
                
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeWalkthrough()
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appBlue)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    func completeWalkthrough() {
        UserDefaults.standard.set(true, forKey: "hasSeenWalkthrough")
        isActive = false
    }
}

struct WalkthroughPage {
    let image: String
    let title: String
    let description: String
}

#Preview {
    WalkthroughView(isActive: .constant(true))
}
