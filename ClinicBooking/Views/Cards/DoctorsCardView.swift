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
                let _ = try await FireStoreManager.shared.toggleFavoriteDoctor(doctorId: docId, userId: userId)
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
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .offset(x: 5, y: 5)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(name)
                        .font(.customFont(style: .bold, size: .h14))
                    Text(speciality)
                        .font(.customFont(style: .medium, size: .h13))
                    HStack {
                        Image("star").resizable()
                            .frame(width: 15, height: 15)
                        Text(rating)
                            .font(.customFont(style: .medium, size: .h13))
                    }
                }
//                .padding(.trailing, 10)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Fee \(fee)")
                        .font(.customFont(style: .medium, size: .h13))
                    Button {
                        /// Button action for book now
                        btnAction()
                    } label: {
                        Text(Texts.bookNow.description)
                            .font(.customFont(style: .medium, size: .h11))
                            .foregroundColor(.white)
                            .frame(width: 70, height: 40)
                            .background(colorScheme == .dark ? Color.appGreen : Color.appBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .frame(width: 85)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .onAppear {
                checkIsSaved()
            }
            Divider()
    }
}

#Preview {
    DoctorsCardView(name: "Name", speciality: "Speciality", rating: "4.5 (2200)", fee: "$50.99", image: "edwin") {
        print("Btn clicked")
    }
}
