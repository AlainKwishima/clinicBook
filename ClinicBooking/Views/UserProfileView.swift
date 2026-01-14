//
//  UserProfileView.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 02/09/24.
//

import SwiftUI
import FirebaseAuth

struct UserProfileView: View {
    @State var addMember: Bool = false
    @State var showEditProfile: Bool = false
    @State var showDeleteAlert: Bool = false
    @State var defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
    @StateObject private var viewModel = AuthenticationViewModel()
    @StateObject private var userViewModel = UserViewModel()
    @State private var showSignoutAlert = false
    @State private var isSyncing = false

    var body: some View {
            VStack {
                ScrollView {
                    
                    profileHeaderView
                    familyMemberView
                    helpAndSupportView
                    Spacer()
                        .navigationTitle("Profile")
                        .navigationBarTitleDisplayMode(.inline)
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }

        .onAppear{
            Task {
                await userViewModel.getFamilyMembers()
                await syncUserData()
            }
        }
        .refreshable {
            await syncUserData()
        }
    }
    
    private func syncUserData() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isSyncing = true
        await FireStoreManager.shared.getUserDetails(userId: userId) { _ in
            defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
            isSyncing = false
        }
    }

    var profileHeaderView: some View {
        VStack {
            ZStack(alignment: .center) {
                    Color(Color.appBlue.opacity(0.2))
                    VStack(spacing: 15) {
//                        Image("user").resizable()
//                            .frame(width: 100, height: 100)
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
                        Text("\(defaults?.firstName ?? "") \(defaults?.lastName ?? "")")
                            .foregroundColor(.black)
                            .font(.customFont(style: .bold, size: .h17))
                        Text("\(defaults?.email.lowercased() ?? "")")
                            .foregroundColor(.gray)
                            .font(.customFont(style: .medium, size: .h15))
                        HStack(spacing: 15) {
                            Button {
                                print("Edit profile tapped!")
                                showEditProfile = true
                            } label: {
                                Label(
                                    title: {
                                        Text(Texts.editProfile.description)
                                            .font(.customFont(style: .bold, size: .h14))
                                    },
                                    icon: { Image(systemName: "pencil") }
                                )
                            }
                            .buttonStyle(BorderButtonStyle(borderColor: Color.gray, foregroundColor: .black, height: 60, background: .clear))
                            Button {
                                print("Signout Tapped!")
                                showSignoutAlert = true
                            } label: {
                                Label(
                                    title: { 
                                        Text(Texts.signOut.description)
                                            .font(.customFont(style: .bold, size: .h14))
                                    },
                                    icon: { Image(systemName: "power") }
                                )
                            }
                            .buttonStyle(BorderButtonStyle(borderColor: Color.appBlue, foregroundColor: .black, height: 60, background: .clear))
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
                .padding(.bottom, 20)
                HStack(spacing: 15) {
                    UserDetailsCardView(image: "height", title: Texts.height.description, value: "\(defaults?.height ?? "") in")
                    UserDetailsCardView(image: "weight", title: Texts.weight.description, value: "\(defaults?.weight ?? "") KG")
                    UserDetailsCardView(image: "age", title: Texts.age.description, value: "\(defaults?.age ?? "")")
                    UserDetailsCardView(image: "blood", title: Texts.blood.description, value: "\(defaults?.bloodGroup ?? "")")
                }
                .alert("Are you sure you want to logging out?", isPresented: $showSignoutAlert) {
                    Button("OK") {
                        viewModel.signOut()
                        UserDefaults.standard.removeObject(forKey: "userDetails")
                    }
                    Button("Cancel", role: .cancel) {}
                }
                .navigationDestination(isPresented: $addMember) {
                    AddFamilyMemberView()
                }
                .navigationDestination(isPresented: $showEditProfile) {
                    EditProfileView()
                        .transition(.slide)
                }
                .onAppear {
                    // Prompt refresh of user details when view appears
                    defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
                }
            }
        }

    var familyMemberView: some View {
        VStack {
            HStack {
                Text(Texts.familyMembers.description)
                    .font(.customFont(style: .bold, size: .h18))
                Spacer()
                Button {
                    /// Button Action
                    addMember = true
                } label: {
                    Label(Texts.addNew.description, systemImage: "plus")
                }
                .buttonStyle(BlueButtonStyle(height: 35, color: Color.appBlue))
                .frame(width: 120)
            }
            Spacer()
                .padding(.top, 10)
            if let member = userViewModel.familyMembers?.members {
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
                }
            }
        }
        .padding()
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
                .background(Color.white)
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
                    .frame(maxWidth: .infinity)
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
                try await FireStoreManager.shared.deleteUserAccount(userId: userId)
                // Sign out locally
                viewModel.signOut()
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
                    .foregroundColor(.black)
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
