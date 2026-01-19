//
//  SignupView.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 01/09/24.
//

import SwiftUI

struct SignupView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    enum Field: Hashable {
        case firstName
        case lastName
        case emailField
        case passwordField
    }
    @FocusState private var focusedField: Field?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Image("logo").resizable()
                        .frame(width: 90, height: 90)
                        .aspectRatio(contentMode: .fit)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(Texts.medClinic.description)
                            .font(.customFont(style: .bold, size: .h24))
                        Text(Texts.bookDoctor.description)
                            .font(.customFont(style: .medium, size: .h15))
                    }
                }
                Spacer()
                VStack(spacing: 25) {
                    if let message = viewModel.validationMessage {
                        Text(message)
                            .foregroundColor(.red)
                            .font(.customFont(style: .medium, size: .h15))
                            .padding()
                    }
                    
                    VStack(spacing: 20) {
                        HStack(spacing: -10) {
                            CustomTextField(placeholder: Texts.firstName.description, text: $viewModel.firstName)
                                .submitLabel(.next)
                                .focused($focusedField, equals: .firstName)
                                .onTapGesture {
                                    viewModel.clearValidationMessage()
                                }
                                .onSubmit {
                                    focusedField = .lastName
                                }
                            CustomTextField(placeholder: Texts.lastName.description, text: $viewModel.lastName)
                                .submitLabel(.next)
                                .focused($focusedField, equals: .lastName)
                                .onTapGesture {
                                    viewModel.clearValidationMessage()
                                }
                                .onSubmit {
                                    focusedField = .emailField
                                }
                        }
                        
                        CustomTextField(placeholder: Texts.enterEmail.description, text: $viewModel.email)
                            .submitLabel(.next)
                            .focused($focusedField, equals: .emailField)
                            .onTapGesture {
                                viewModel.clearValidationMessage()
                            }
                            .onSubmit {
                                focusedField = .passwordField
                            }
                        
                        CustomTextField(placeholder: Texts.enterPassword.description, text: $viewModel.password, isSecure: true)
                            .padding(.bottom, 10)
                            .submitLabel(.done)
                            .focused($focusedField, equals: .passwordField)
                            .onTapGesture {
                                viewModel.clearValidationMessage()
                            }
                            .onSubmit {
                                focusedField = nil
                            }
                    }
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                    
                    Button {
                        print("Signup tapped!")
                        Task {
                            await viewModel.signup()
                        }
                    } label: {
                        Text(Texts.signup.description)
                            .foregroundColor(.white)
                            .font(.customFont(style: .bold, size: .h17))
                            .padding()
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                            .background(Color.appBlue)
                            .cornerRadius(30)
                    }
                    .padding(.bottom, 10)
                    
                    Button {
                        print("Login tapped!")
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack(spacing: 10) {
                            Text(Texts.loginAccountMessage.description)
                                .font(.customFont(style: .medium, size: .h15))
                                .foregroundColor(.text)
                            Text(Texts.login.description)
                                .foregroundColor(Color.appBlue)
                                .underline()
                                .font(.customFont(style: .bold, size: .h17))
                        }
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                Spacer()
                Spacer()
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToAdditionalInfo) {
                AdditionalInfoView()
            }
        }
    }
}

#Preview {
    SignupView()
}
//
//  AdditionalInfoView.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI
import Supabase

struct AdditionalInfoView: View {
    @StateObject private var viewModel = AuthenticationViewModel() // We might need a shared VM or just use FireStoreManager directly
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var age: String = ""
    @State private var address: String = ""
    @State private var selectedBloodGroup: String = "Blood Group"
    @State private var isLoading = false
    @State private var navigateToSuccess = false
    @State private var errorMessage: String?
    @State private var defaults: AppUser? // To hold current user details from UserDefaults
    @State private var isSyncing = false // To manage loading state for data sync
    
    var bloodGroups = ["Blood Group", "O+", "O-", "A+", "A-", "B+", "B-", "AB+", "AB-"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tell us more about you")
                .font(.customFont(style: .bold, size: .h24))
                .padding(.top, 40)
            
            Text("These details help us provide better health recommendations.")
                .font(.customFont(style: .medium, size: .h15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 15) {
                    CustomTextField(placeholder: "Height (in)", text: $height)
                        .keyboardType(.numberPad)
                    
                    CustomTextField(placeholder: "Weight (kg)", text: $weight)
                        .keyboardType(.numberPad)
                    
                    CustomTextField(placeholder: "Age", text: $age)
                        .keyboardType(.numberPad)
                    
                    CustomTextField(placeholder: "Address / Location", text: $address)
                    
                    HStack {
                        Text("Blood Group")
                            .font(.customFont(style: .medium, size: .h16))
                            .foregroundColor(.gray)
                        Spacer()
                        Picker("Blood Group", selection: $selectedBloodGroup) {
                            ForEach(bloodGroups, id: \.self) { group in
                                Text(group)
                            }
                        }
                    }
                    .padding()
                    .background(Color.card)
                    .cornerRadius(12)
                }
                .padding()
                .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                .frame(maxWidth: .infinity)
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button {
                Task {
                    await saveDetails()
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Continue")
                        .font(.customFont(style: .bold, size: .h17))
                        .padding()
                        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                        .background(Color.appBlue)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
            }
            .padding()
            .disabled(isLoading)
            .navigationDestination(isPresented: $navigateToSuccess) {
                SuccessStateView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                await syncUserData()
            }
        }
    }
    
    private func syncUserData() async {
        // Retrieve ID or fetch from session
        var finalUserId: String? = UserDefaults.standard.string(forKey: "userID")
        
        if finalUserId == nil || finalUserId?.isEmpty == true {
             if let session = try? await SupabaseManager.shared.client.auth.session {
                 finalUserId = session.user.id.uuidString
                 // Persist for future use
                 UserDefaults.standard.set(finalUserId, forKey: "userID")
             }
        }
        
        guard let userId = finalUserId, !userId.isEmpty else { return }
        
        isSyncing = true
        await SupabaseDBManager.shared.getUserDetails(userId: userId) { success in
            if success {
                defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
            }
            isSyncing = false
        }
    }
    
    
    func saveDetails() async {
        if height.isEmpty || weight.isEmpty || age.isEmpty || address.isEmpty || selectedBloodGroup == "Blood Group" {
            errorMessage = "Please fill in all fields."
            return
        }
        
        self.isLoading = true
        
        Task {
            var finalUserId: String? = UserDefaults.standard.string(forKey: "userID")
            
            if finalUserId == nil || finalUserId?.isEmpty == true {
                if let session = try? await SupabaseManager.shared.client.auth.session {
                    finalUserId = session.user.id.uuidString
                }
            }
            
            guard let userId = finalUserId, !userId.isEmpty else {
                self.isLoading = false
                self.errorMessage = "User not logged in."
                return
            }
            
            // Fetch current user and update with additional info
            if let currentUser = UserDefaults.standard.value(AppUser.self, forKey: "userDetails") {
                let updatedUser = AppUser(
                    password: currentUser.password,
                    email: currentUser.email,
                    firstName: currentUser.firstName,
                    lastName: currentUser.lastName,
                    createdAt: currentUser.createdAt,
                    height: height,
                    weight: weight,
                    age: age,
                    bloodGroup: selectedBloodGroup,
                    phoneNumber: currentUser.phoneNumber,
                    imageURL: currentUser.imageURL,
                    address: address
                )
                
                await SupabaseDBManager.shared.updateUserDetails(userId, dataModel: updatedUser) { success in
                    self.isLoading = false
                    if success {
                        self.navigateToSuccess = true
                    } else {
                        self.errorMessage = "Failed to save details."
                    }
                }
            } else {
                self.isLoading = false
                self.errorMessage = "User details not found locally."
            }
        }
    }
}

#Preview {
    AdditionalInfoView()
}
//
//  SuccessStateView.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI

struct SuccessStateView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.appBlue)
                    .padding()
                
                Text("All set!")
                    .font(.customFont(style: .bold, size: .h24))
                    .padding(.top, 10)
                
                Text("Your profile has been created successfully. You can now start booking appointments.")
                    .font(.customFont(style: .medium, size: .h15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 5)
                
                Spacer()
                
                Button {
                    // Force a full refresh of the auth state to return to the proper root dashboard
                    NotificationCenter.default.post(name: NSNotification.Name("AuthStatusChanged"), object: nil)
                    // In current structure, clicking this just takes them home.
                    // To be safe and clean, we rely on AppRootView. 
                    // But since this is a NavigationLink, let's keep it as is for UI continuity 
                    // but ensure the underlying data is already persisted.
                } label: {
                    NavigationLink(destination: HomeDashboard().navigationBarBackButtonHidden(true)) {
                        Text("Go to Home")
                            .font(.customFont(style: .bold, size: .h17))
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                            .frame(height: 55)
                            .background(Color.appBlue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                }
                .padding()
                .padding(.bottom, 20)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    SuccessStateView()
}
