//
//  UserProfileView.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 02/09/24.
//

import SwiftUI
import Supabase

struct UserProfileView: View {
    @State var addMember: Bool = false
    @State var showEditProfile: Bool = false
    @State var showDeleteAlert: Bool = false
    @State var defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
    @StateObject private var viewModel = AuthenticationViewModel()
    @StateObject private var userViewModel = UserViewModel()
    @State private var showSignoutAlert = false

    @State private var isSyncing = false
    @State private var showSearch = false
    @State private var showNotifications = false

    var body: some View {
            VStack(spacing: 0) {

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        profileHeaderView
                        
                        VStack(spacing: 30) {
                            familyMemberView
                            helpAndSupportView
                        }
                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 16)
                    }
                    .padding(.bottom, 40)
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 850 : .infinity)
                    .frame(maxWidth: .infinity)
                }
            }

        .onAppear{
            Task {
                await userViewModel.getFamilyMembers()
                await syncUserData()
            }
        }

        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await syncUserData()
        }
        .fullScreenCover(isPresented: $showSearch) {
            SearchFilterView()
        }
        .navigationDestination(isPresented: $showNotifications) {
            NotificationCenterView()
        }
    }
    
    private func syncUserData() async {
        var userId = UserDefaults.standard.string(forKey: "userID")
        if userId == nil {
            if let session = try? await SupabaseManager.shared.client.auth.session {
                userId = session.user.id.uuidString
            }
        }
        
        guard let finalUserId = userId else { return }
        
        isSyncing = true
        await SupabaseDBManager.shared.getUserDetails(userId: finalUserId) { _ in
            defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
            isSyncing = false
        }
    }

    var profileHeaderView: some View {
        VStack(spacing: 25) {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.appBlue.opacity(0.1))
                    .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 350 : 300)
                
                VStack(spacing: 15) {
                    AsyncImage(
                        url: URL(string: defaults?.imageURL ?? ""),
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        },
                        placeholder: {
                            Image("user")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        }
                    )
                    
                    VStack(spacing: 5) {
                        Text("\(defaults?.firstName ?? "") \(defaults?.lastName ?? "")")
                            .font(.customFont(style: .bold, size: .h20))
                            .foregroundColor(.text)
                        
                        Text("\(defaults?.email?.lowercased() ?? "")")
                            .font(.customFont(style: .medium, size: .h15))
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 15) {
                        Button {
                            showEditProfile = true
                        } label: {
                            Label("Edit Profile", systemImage: "pencil")
                                .font(.customFont(style: .bold, size: .h14))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .foregroundColor(.text)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        Button {
                            showSignoutAlert = true
                        } label: {
                            Label("Sign Out", systemImage: "power")
                                .font(.customFont(style: .bold, size: .h14))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.appBlue.opacity(0.1))
                                .foregroundColor(.appBlue)
                                .cornerRadius(12)
                        }
                        .alert("Sign Out", isPresented: $showSignoutAlert) {
                            Button("Sign Out", role: .destructive) {
                                Task { await viewModel.signOut() }
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("Are you sure you want to sign out?")
                        }
                    }
                }
            }
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 16)
            
            // Stats Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                UserDetailsCardView(image: "height", title: Texts.height.description, value: "\(defaults?.height ?? "") in")
                UserDetailsCardView(image: "weight", title: Texts.weight.description, value: "\(defaults?.weight ?? "") KG")
                UserDetailsCardView(image: "age", title: Texts.age.description, value: "\(defaults?.age ?? "")")
                UserDetailsCardView(image: "blood", title: Texts.blood.description, value: "\(defaults?.bloodGroup ?? "")")
            }
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 16)
        }
        .onAppear {
            defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
        }
    }

    var familyMemberView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(Texts.familyMembers.description)
                    .font(.customFont(style: .bold, size: .h18))
                Spacer()
                Button {
                    addMember = true
                } label: {
                    Label(Texts.addNew.description, systemImage: "plus")
                        .font(.customFont(style: .bold, size: .h14))
                }
                .buttonStyle(BlueButtonStyle(height: 35, color: Color.appBlue))
                .frame(width: 130)
            }
            
            if let member = userViewModel.familyMembers?.members, !member.isEmpty {
                VStack(spacing: 0) {
                    ForEach(0..<member.count, id: \.self) { index in
                        FamilyMembersListView(
                            imageUrl: member[index].imageURL,
                            name: (member[index].firstName) + " " + (member[index].lastName),
                            phoneNumber: member[index].phoneNumber,
                            bloodGroup: member[index].bloodGroup,
                            age: member[index].age,
                            height: member[index].height,
                            weight: member[index].weight
                        )
                        .padding()
                        
                        if index < member.count - 1 {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
                .background(Color.card)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
            } else {
                Text("No family members added yet.")
                    .font(.customFont(style: .medium, size: .h14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }

    var helpAndSupportView: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Help & Support")
                    .font(.customFont(style: .bold, size: .h18))
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    supportItem(icon: "questionmark.circle", title: "FAQ")
                    Divider()
                    supportItem(icon: "envelope", title: "Contact Us")
                    Divider()
                    supportItem(icon: "message", title: "In-app Chat")
                }
                .background(Color.card)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
            .padding(.top, 20)
            
            Button(action: {
                showDeleteAlert = true
            }) {
                Text("Delete Account")
                    .font(.customFont(style: .bold, size: .h16))
                    .foregroundColor(.red)
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .alert("Delete Account", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete your account? This action is irreversible and will remove all your data.")
            }
        }
    }
    
    func deleteAccount() {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else { return }
        Task {
            do {
                try await SupabaseDBManager.shared.deleteUserAccount(userId: userId)
                // Sign out locally
                await viewModel.signOut()
                UserDefaults.standard.removeObject(forKey: "userDetails")
                UserDefaults.standard.removeObject(forKey: "userID")
            } catch {
                print("Error deleting account: \(error)")
            }
        }
    }
    
    func supportItem(icon: String, title: String) -> some View {
        Button {
            handleSupportAction(title: title)
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.appBlue)
                    .frame(width: 30)
                Text(title)
                    .foregroundColor(.text)
                    .font(.customFont(style: .medium, size: .h16))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
        }
    }
    
    func handleSupportAction(title: String) {
        if title == "Contact Us" {
            if let url = URL(string: "mailto:support@clinicbooking.com") {
                UIApplication.shared.open(url)
            }
        } else if title == "In-app Chat" {
             // Mock action or open webview
             print("Opening chat...")
        } else if title == "FAQ" {
            if let url = URL(string: "https://clinicbooking.com/faq") {
                UIApplication.shared.open(url)
            }
        }
    }

}

#Preview {
    UserProfileView()
}

struct FamilyMembersListView: View {
    var imageUrl: String
    var name, phoneNumber, bloodGroup, age, height, weight: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AsyncImage(
                    url: URL(string: imageUrl),
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 50, maxHeight: 50)
                            .clipShape(Circle())
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
                VStack(alignment: .leading, spacing: 12) {
                    Text(name)
                        .font(.customFont(style: .medium, size: .h15))
                    Text("\(phoneNumber)  -  Blood Group: \(bloodGroup)")
                        .font(.customFont(style: .medium, size: .h14))
                        .foregroundStyle(.gray)
                    HStack(spacing: 12) {
                        Text("Age: \(age)")
                            .font(.customFont(style: .medium, size: .h13))
                            .foregroundStyle(.gray)
                        Divider()
                        Text("Height: \(height) in")
                            .font(.customFont(style: .medium, size: .h13))
                            .foregroundStyle(.gray)
                        Divider()
                        Text("Weight: \(weight) KGS")
                            .font(.customFont(style: .medium, size: .h13))
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        Divider()
    }
}
