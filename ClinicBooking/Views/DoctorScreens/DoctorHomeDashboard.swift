//
//  DoctorHomeDashboard.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI

struct DoctorHomeDashboard: View {
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            NavigationStack {
                DoctorHomeTab()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            NavigationStack {
                DoctorAppointmentsView()
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Appointments")
            }
            .tag(1)
            
            NavigationStack {
                PatientHistoryView()
            }
            .tabItem {
                Image(systemName: "clock.arrow.circlepath")
                Text("History")
            }
            .tag(2)
            
            NavigationStack {
                DoctorProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(3)
        }
        .accentColor(.appBlue)
        .navigationBarBackButtonHidden(true)
    }
}
