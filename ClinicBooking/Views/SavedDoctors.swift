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

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    savedDoctorsView
                    Spacer()
                }
            }
            .navigationTitle("Saved Doctors")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            Task {
                await viewModel.fetchDoctors()
                self.doctors = viewModel.doctors.filter { $0.isSaved }
            }
        }
        .navigationDestination(isPresented: $showDoctorProfile, destination: { DoctorProfile(doctorDetail: doctorDetail) })
    }

    var savedDoctorsView: some View {
        VStack {
            ForEach(0..<doctors.count, id: \.self) { index in
                DoctorsCardView(
                    name: doctors[index].name,
                    speciality: doctors[index].specialist,
                    rating: doctors[index].rating,
                    fee: "$50.99",
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
