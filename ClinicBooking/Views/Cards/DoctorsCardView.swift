//
//  DoctorsCardView.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 02/09/24.
//

import SwiftUI

struct DoctorsCardView: View {
    var id: String? // Added ID
    var name: String
    var speciality: String
    var rating: String
    var fee: String
    var image: String
    var btnAction: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isSaved: Bool = false
    
    // Check initial state
    func checkIsSaved() {
        guard let user = UserDefaults.standard.value(AppUser.self, forKey: "userDetails"),
              let favs = user.favoriteDoctorIds,
              let docId = id else { return }
        isSaved = favs.contains(docId)
    }
    
    func toggleFavorite() {
        guard let docId = id, let userId = UserDefaults.standard.string(forKey: "userID") else { return }
        // Optimistic UI
        isSaved.toggle()
        
        Task {
            do {
                let _ = try await SupabaseDBManager.shared.toggleFavoriteDoctor(doctorId: docId, userId: userId)
            } catch {
                isSaved.toggle() // Revert on error
                print("Error toggling favorite: \(error)")
            }
        }
    }

    var body: some View {
            HStack(spacing: 15) {
                ZStack(alignment: .bottomTrailing) {
                    ImageCircle(icon: image, radius: 40, circleColor: Color.doctorBG)
                    
                    Button {
                        toggleFavorite()
                    } label: {
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .foregroundColor(isSaved ? .red : .gray)
                            .padding(6)
                            .background(Color.bg)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .offset(x: 5, y: 5)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(name)
                        .font(.customFont(style: .bold, size: .h16))
                        .foregroundColor(.text)
                    Text(speciality)
                        .font(.customFont(style: .medium, size: .h14))
                        .foregroundColor(.gray)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.yellow)
                        Text(rating)
                            .font(.customFont(style: .medium, size: .h14))
                            .foregroundColor(.text.opacity(0.8))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Fee \(fee)")
                        .font(.customFont(style: .bold, size: .h14))
                        .foregroundColor(.text)
                    
                    Button {
                        btnAction()
                    } label: {
                        Text(Texts.bookNow.description)
                            .font(.customFont(style: .bold, size: .h13))
                            .foregroundColor(.white)
                            .frame(width: 90, height: 38)
                            .background(colorScheme == .dark ? Color.appGreen : Color.appBlue)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(15)
            .background(Color.card)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            .contextMenu {
                Button {
                    btnAction()
                } label: {
                    Label("Book Appointment", systemImage: "calendar.badge.plus")
                }
                
                Button {
                    toggleFavorite()
                } label: {
                    Label(isSaved ? "Remove from Saved" : "Save Doctor", systemImage: isSaved ? "heart.fill" : "heart")
                }
                
                Button {
                    // Call action
                } label: {
                    Label("Contact Clinic", systemImage: "phone.fill")
                }
            }
            .onAppear {
                checkIsSaved()
            }
    }
}

#Preview {
    DoctorsCardView(name: "Name", speciality: "Speciality", rating: "4.5 (2200)", fee: "$50.99", image: "edwin") {
        print("Btn clicked")
    }
}
