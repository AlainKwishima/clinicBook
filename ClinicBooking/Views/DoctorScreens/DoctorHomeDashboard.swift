//
//  DoctorHomeDashboard.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI

struct DoctorHomeDashboard: View {
    @State private var selectedIndex: Int? = 0
    @State var defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
    @State private var showNotifications = false
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                NavigationSplitView {
                    SidebarView(role: "doctor", selectedIndex: $selectedIndex)
                } detail: {
                    detailView
                }
            } else {
                tabView
            }
        }
        .accentColor(.appBlue)
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    var detailView: some View {
        VStack(spacing: 0) {
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadHeader
            }
            
            ZStack {
                switch selectedIndex ?? 0 {
                case 0:
                    NavigationStack {
                        DoctorHomeTab()
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom).animation(.spring())))
                case 1:
                    NavigationStack {
                        DoctorAppointmentsView()
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom).animation(.spring())))
                case 2:
                    NavigationStack {
                        PatientHistoryView()
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom).animation(.spring())))
                case 3:
                    NavigationStack {
                        DoctorProfileView()
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom).animation(.spring())))
                default:
                    NavigationStack {
                        DoctorHomeTab()
                    }
                }
            }
            .id(selectedIndex ?? 0)
        }
    }
    
    var iPadHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(SidebarItem(rawValue: selectedIndex ?? 0)?.title(for: "doctor") ?? "Dashboard")
                    .font(.customFont(style: .bold, size: .h24))
                Text(Date().formatted(date: .long, time: .omitted))
                    .font(.customFont(style: .medium, size: .h14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button {
                    showNotifications = true
                } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.text)
                        .padding(10)
                        .background(Color.card)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5)
                }
                
                Divider()
                    .frame(height: 30)
                    .padding(.horizontal, 5)
                
                Button {
                    selectedIndex = 3 // Profile
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Dr. \(defaults?.firstName ?? "") \(defaults?.lastName ?? "")")
                                .font(.customFont(style: .bold, size: .h14))
                            Text("Medical Specialist")
                                .font(.customFont(style: .medium, size: .h12))
                                .foregroundColor(.appBlue)
                        }
                        
                        AsyncImage(url: URL(string: defaults?.imageURL ?? "")) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image("user").resizable()
                        }
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.appBlue.opacity(0.2), lineWidth: 1))
                    }
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .background(Color.bg)
    }
    
    var tabView: some View {
        TabView(selection: Binding(get: { selectedIndex ?? 0 }, set: { selectedIndex = $0 })) {
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
    }
}
