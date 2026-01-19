//
//  SavedDoctors.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 27/11/24.
//

import SwiftUI

struct SavedDoctors: View {
    @StateObject var viewModel: DoctorsViewModel = DoctorsViewModel()
    @State var doctors: [Doctor] = []
    @State var doctorDetail : Doctor?

    @State private var showDoctorProfile: Bool = false
    @State private var showSearch = false
    @State private var showNotifications = false
    @State private var defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")

    var body: some View {
        VStack(spacing: 0) {

            if doctors.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.3))
                    Text("No saved doctors yet")
                        .font(.customFont(style: .medium, size: .h16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    savedDoctorsView
                        .padding()
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchDoctors()
                self.doctors = viewModel.doctors.filter { $0.isSaved }
            }
        }

        .navigationTitle("Saved Doctors")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showDoctorProfile, destination: { DoctorProfile(doctorDetail: doctorDetail) })
        .fullScreenCover(isPresented: $showSearch) {
            SearchFilterView()
        }
        .navigationDestination(isPresented: $showNotifications) {
            NotificationCenterView()
        }
    }


    var savedDoctorsView: some View {
        let columns = [GridItem(.adaptive(minimum: 300), spacing: 20)]
        
        return LazyVGrid(columns: columns, spacing: 15) {
            ForEach(0..<doctors.count, id: \.self) { index in
                DoctorsCardView(
                    id: doctors[index].doctorID,
                    name: doctors[index].name,
                    speciality: doctors[index].specialist,
                    rating: doctors[index].rating,
                    fee: doctors[index].fee != nil ? "$\(String(format: "%.2f", doctors[index].fee!))" : "$50.99",
                    image: doctors[index].image,
                    btnAction: {
                        showDoctorProfile =  true
                        self.doctorDetail = doctors[index]
                    }
                )
                .onTapGesture {
                    showDoctorProfile =  true
                    self.doctorDetail = doctors[index]
                }
            }
        }
    }
}

#Preview {
    SavedDoctors()
}
