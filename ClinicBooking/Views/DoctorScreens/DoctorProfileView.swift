//
//  DoctorProfileView.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI
import Supabase

struct DoctorProfileView: View {
    @State var defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var showSignoutAlert = false
    @State private var isSyncing = false
    @State private var verificationCode = ""
    @State private var showVerificationAlert = false
    @State private var verificationAlertMessage = ""
    
    var body: some View {
            VStack {
                ScrollView {
                    if defaults?.verificationStatus != "verified" {
                        verifyAccountSection
                    }
                    
                    profileHeaderView
                    
                    // Professional Details Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Professional Info")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ProfileDetailRow(icon: "cross.case.fill", title: "Hospital", value: defaults?.hospitalName ?? "N/A")
                            Divider()
                            ProfileDetailRow(icon: "star.fill", title: "Specialty", value: defaults?.specialty ?? "N/A")
                            Divider()
                            ProfileDetailRow(icon: "clock.fill", title: "Experience", value: "\(defaults?.experienceYears ?? "0") Years")
                            Divider()
                            ProfileDetailRow(icon: "doc.text.fill", title: "License", value: defaults?.licenseNumber ?? "N/A")
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding()
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 850 : .infinity)
                .frame(maxWidth: .infinity)
                .navigationTitle("Doctor Profile")
                .navigationBarTitleDisplayMode(.inline)
                .refreshable {
                    await syncUserData()
                }
            }
        .onAppear {
             Task {
                 await syncUserData()
             }
        }
    }
    
    private func syncUserData() async {
        guard let userId = UserDefaults.standard.string(forKey: "userID") ?? (try? await SupabaseManager.shared.client.auth.session)?.user.id.uuidString else { return }
        isSyncing = true
        await SupabaseDBManager.shared.getUserDetails(userId: userId) { _ in
            defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
            isSyncing = false
        }
    }

    var verifyAccountSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                Text("Registry Verification")
                    .font(.customFont(style: .bold, size: .h18))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Your professional profile is currently in 'Registry Pending' mode. To activate your visibility to all patients, please enter your institution's registration key.")
                    .font(.customFont(style: .medium, size: .h14))
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 12) {
                    TextField("", text: $verificationCode, prompt: Text("Enter Registration Key").foregroundColor(.white.opacity(0.6)))
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.characters)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    Button(action: { verifyCode() }) {
                        if isSyncing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .appBlue))
                                .frame(width: 80, height: 50)
                                .background(Color.white)
                                .cornerRadius(12)
                        } else {
                            Text("Activate")
                                .font(.customFont(style: .bold, size: .h14))
                                .foregroundColor(.appBlue)
                                .frame(width: 80, height: 50)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.1), radius: 5)
                        }
                    }
                }
            }
            .padding([.horizontal, .bottom], 20)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.appBlue, Color.appBlue.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .padding()
        .shadow(color: Color.appBlue.opacity(0.3), radius: 10, x: 0, y: 5)
        .alert("Registry Status", isPresented: $showVerificationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(verificationAlertMessage)
        }
    }

    private func verifyCode() {
        let masterCode = "CLINIC-2026-OK"
        if verificationCode.uppercased() == masterCode {
            Task {
                guard let userId = UserDefaults.standard.string(forKey: "userID") ?? (try? await SupabaseManager.shared.client.auth.session)?.user.id.uuidString else { 
                    verificationAlertMessage = "Error: User ID not found."
                    showVerificationAlert = true
                    return 
                }
                do {
                    isSyncing = true
                    try await SupabaseDBManager.shared.updateVerificationStatus(userId: userId, status: "verified")
                    await syncUserData()
                    verificationAlertMessage = "Success! Your doctor profile is now verified and visible to patients."
                    showVerificationAlert = true
                    verificationCode = ""
                } catch {
                    verificationAlertMessage = "Error: \(error.localizedDescription)"
                    showVerificationAlert = true
                }
                isSyncing = false
            }
        } else {
            verificationAlertMessage = "Invalid verification code. Please contact your administrator."
            showVerificationAlert = true
        }
    }
    
    var profileHeaderView: some View {
        VStack {
            ZStack(alignment: .center) {
                Color(Color.appBlue.opacity(0.2))
                VStack(spacing: 15) {
                    AsyncImage(
                        url: URL(string: defaults?.imageURL ?? ""),
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: 120, maxHeight: 120)
                                .clipShape(Circle())
                        },
                        placeholder: {
                            if defaults?.imageURL == "" {
                                Image("user").resizable()
                                    .frame(width: 120, height: 120)
                            } else {
                                ProgressView()
                            }
                        })
                    Text("Dr. \(defaults?.firstName ?? "") \(defaults?.lastName ?? "")")
                        .foregroundColor(.black)
                        .font(.customFont(style: .bold, size: .h17))
                    Text("\(defaults?.email?.lowercased() ?? "")")
                        .foregroundColor(.black)
                        .font(.customFont(style: .medium, size: .h15))
                    
                    Button {
                        showSignoutAlert = true
                    } label: {
                        Label("Sign Out", systemImage: "power")
                            .font(.customFont(style: .bold, size: .h14))
                    }
                    .buttonStyle(BorderButtonStyle(borderColor: Color.appBlue, foregroundColor: .black, height: 50, background: .clear))
                    .padding(.horizontal, 50)
                }
                .padding(.vertical, 30)
            }
            .alert("Are you sure you want to sign out?", isPresented: $showSignoutAlert) {
                Button("Sign Out", role: .destructive) {
                    Task {
                        await viewModel.signOut()
                        UserDefaults.standard.removeObject(forKey: "userDetails")
                        UserDefaults.standard.removeObject(forKey: "userID")
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

struct ProfileDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.appBlue)
                .frame(width: 30)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .bold()
        }
        .padding()
    }
}
