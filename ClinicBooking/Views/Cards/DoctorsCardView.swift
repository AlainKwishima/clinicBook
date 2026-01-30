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
            HStack(alignment: .top, spacing: 15) {
                ZStack(alignment: .bottomTrailing) {
                    if image.hasPrefix("http") {
                        AsyncImage(url: URL(string: image)) { img in
                            img.resizable()
                                .aspectRatio(1.0, contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 6))
                        } placeholder: {
                            ProgressView()
                                .frame(width: 70, height: 70)
                                .background(Color.doctorBG)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 6))
                        }
                    } else {
                        ImageCircle(icon: image, radius: 35, circleColor: Color.doctorBG)
                    }
                    
                    Button {
                        toggleFavorite()
                    } label: {
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .font(.system(size: 12))
                            .foregroundColor(isSaved ? .red : .gray)
                            .padding(6)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .offset(x: 2, y: 2)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(name)
                        .font(.customFont(style: .bold, size: .h16))
                        .foregroundColor(.text)
                        .lineLimit(1)
                    
                    Text(speciality)
                        .font(.customFont(style: .medium, size: .h13))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.orange)
                        Text(rating)
                            .font(.customFont(style: .medium, size: .h13))
                            .foregroundColor(.text.opacity(0.8))
                    }
                    .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .trailing, spacing: 0) {
                    Text("Fee \(fee)")
                        .font(.customFont(style: .bold, size: .h14))
                        .foregroundColor(.text)
                        .padding(.top, 2)
                    
                    Spacer()
                    
                    Button {
                        btnAction()
                    } label: {
                        Text(Texts.bookNow.description)
                            .font(.customFont(style: .bold, size: .h12))
                            .foregroundColor(.white)
                            .frame(width: 85, height: 32)
                            .background(Color.appBlue)
                            .cornerRadius(16) // More rounded
                    }
                }
            }
            .padding(12)
            .background(Color.card)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
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
