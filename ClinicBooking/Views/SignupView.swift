//
//  SignupView.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 01/09/24.
//

import SwiftUI
import Supabase

struct SignupView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    enum Field: Hashable {
        case firstName
        case lastName
        case emailField
        case passwordField
    }
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(10)
                            .contentShape(Rectangle())
                    }
                    .padding(.leading, 5)
                    
                    Spacer()
                    
                    HStack {
                        Image("logo").resizable()
                            .frame(width: 70, height: 70)
                            .aspectRatio(contentMode: .fit)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(Texts.medClinic.description)
                                .font(.customFont(style: .bold, size: .h18))
                            Text(Texts.bookDoctor.description)
                                .font(.customFont(style: .medium, size: .h12))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.left").opacity(0)
                        .padding(.trailing)
                }
                .padding(.top, 10)
                Spacer()
                
                VStack(spacing: 25) {
                    if let message = viewModel.validationMessage {
                        Text(message)
                            .foregroundColor(.red)
                            .font(.customFont(style: .medium, size: .h15))
                            .padding()
                    }
                    
                    VStack(spacing: 20) {
                        
                        HStack(spacing: 8) {
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
                    
                    // Removed hidden NavigationLink in favor of .navigationDestination
                    
                    
                    Button {
                        print("DEBUG: Signup 'Continue' tapped")
                        // Dismiss keyboard first to prevent layout issues
                        focusedField = nil
                        
                        // Ensure role is set before navigation
                        if viewModel.role.isEmpty {
                            viewModel.role = "patient"
                        }
                        
                        // signup() sets the flag and shouldNavigateToAdditionalInfo synchronously
                        // Navigation will happen automatically via navigationDestination binding
                        let success = viewModel.signup()
                        print("DEBUG: Signup validation result: \(success), shouldNavigate: \(viewModel.shouldNavigateToAdditionalInfo), role: \(viewModel.role)")
                    } label: {
                        Text("Continue")
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
                        dismiss()
                    } label: {
                        HStack(spacing: 10) {
                            Text(Texts.accountMessage.description)
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
            .onAppear {
                @AppStorage("userID") var currentUserID: String = ""
                print("🔵 [AUTH_TRACE] SignupView onAppear - currentUserID: \(currentUserID)")
                
                // ONLY set flag if it's not already set AND we aren't already logged in.
                // This prevents re-triggering the signup shield during dismissal 
                // after a successful registration.
                if currentUserID.isEmpty && !SupabaseAuthService.shared.isSignUpFlowInProgress {
                    print("🔵 [AUTH_TRACE] SignupView onAppear: Enabling signup flow flag")
                    SupabaseAuthService.shared.isSignUpFlowInProgress = true
                    NotificationCenter.default.post(name: NSNotification.Name("SignupFlowStarted"), object: nil)
                }
                
                // CRITICAL: We NO LONGER call signOut() here. 
            }
        }
        // Present the additional info screen modally to avoid any
        // NavigationStack glitches that can block the push on iPad.
        .sheet(isPresented: $viewModel.shouldNavigateToAdditionalInfo) {
            NavigationStack {
                AdditionalInfoView(viewModel: viewModel, isRegistrationFlow: true)
            }
            .presentationDetents([.large])
            .interactiveDismissDisabled(false)
            .onDisappear {
                // Reset the navigation flag when sheet is dismissed
                // This prevents the sheet from reappearing
                print("🔵 [AUTH_TRACE] AdditionalInfoView sheet dismissed - resetting shouldNavigateToAdditionalInfo")
                viewModel.shouldNavigateToAdditionalInfo = false
                
                // CRITICAL: We do NOT clear isSignUpFlowInProgress here.
                // If the user cancelled, it's fine. If they completed, SuccessStateView 
                // will clear it after the home dashboard is ready.
            }
        }
    }
}

#Preview {
    SignupView(viewModel: AuthenticationViewModel())
}


//
//  AdditionalInfoView.swift
//  ClinicBooking
//
//  Created by Assistant.
//

struct AdditionalInfoView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AuthenticationViewModel
    var isRegistrationFlow: Bool = false
    @AppStorage("userID") var storedUserID: String = ""
    
    // Patient Fields
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var age: String = ""
    @State private var selectedBloodGroup: String = "Blood Group"
    
    // Doctor Fields
    @State private var licenseNumber: String = ""
    @State private var specialty: String = ""
    @State private var experienceYears: String = ""
    @State private var aboutMe: String = ""
    @State private var hospitalName: String = ""
    
    // Common
    @State private var phoneNumber: String = ""
    @State private var gender: String = ""
    @State private var address: String = ""
    @State private var isLoading = false
    @State private var navigateToSuccess = false
    @State private var errorMessage: String?
    @State private var defaults: AppUser?
    @State private var isSyncing = false
    @State private var currentUserRole: String = "patient"
    
    var bloodGroups = ["Blood Group", "O+", "O-", "A+", "A-", "B+", "B-", "AB+", "AB-"]
    
    // New Standardized Fields
    @State private var dob: Date = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
    @State private var selectedInsurance: String = "None"
    @State private var insuranceNumber: String = ""
    @State private var selectedCountry: String = "Rwanda"
    @State private var selectedGender: String = "Select Gender"
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(10)
                        .contentShape(Rectangle())
                }
                Spacer()
                Text("Complete Profile")
                    .font(.customFont(style: .bold, size: .h18))
                Spacer()
                Image(systemName: "chevron.left").opacity(0).padding(10)
            }
            .padding(.horizontal, 5)
            .padding(.top, 10)
            .background(Color(UIColor.systemBackground))

            if isSyncing {
                ProgressView("Loading profile...")
                    .padding()
            }

            ScrollView {
                VStack(spacing: 25) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                    
                    VStack(spacing: 8) {
                        Text("Tell us more about you")
                            .font(.customFont(style: .bold, size: .h24))
                        Text("This information helps us provide you with the best healthcare experience.")
                            .font(.customFont(style: .medium, size: .h15))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 20) {
                            // Common Fields
                            CustomTextField(placeholder: "Resident Address", text: $address)
                            CustomTextField(placeholder: "Phone Number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                            
                            // Standardized Birth Date & Gender Row
                            HStack(spacing: 15) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Gender").font(.caption).foregroundColor(.gray)
                                    Menu {
                                        ForEach(["Male", "Female", "Other"], id: \.self) { g in
                                            Button(g) { selectedGender = g }
                                        }
                                    } label: {
                                        HStack {
                                            Text(selectedGender)
                                                .foregroundColor(selectedGender == "Select Gender" ? .gray : .text)
                                            Spacer()
                                            Image(systemName: "chevron.down").font(.caption).foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 10)
                                        .frame(height: 55)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.bg)
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Date of Birth").font(.caption).foregroundColor(.gray)
                                    DatePicker("", selection: $dob, displayedComponents: .date)
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                        .frame(height: 55)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 10)
                                        .background(Color.bg)
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                }
                                .frame(maxWidth: .infinity)
                            }

                            if currentUserRole == "doctor" {
                                // Doctor Specific
                                CustomTextField(placeholder: "License Number", text: $licenseNumber)
                                CustomTextField(placeholder: "Specialty", text: $specialty)
                                CustomTextField(placeholder: "Years of Experience", text: $experienceYears)
                                    .keyboardType(.numberPad)
                                CustomTextField(placeholder: "Current Hospital/Clinic", text: $hospitalName)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("About Me / Bio").font(.customFont(style: .bold, size: .h14))
                                    TextEditor(text: $aboutMe)
                                        .frame(height: 100)
                                        .padding(8)
                                        .background(Color.bg)
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                }
                            } else {
                                // Patient Specific
                                HStack(spacing: 15) {
                                    CustomTextField(placeholder: "Height (cm)", text: $height).keyboardType(.numberPad)
                                    CustomTextField(placeholder: "Weight (kg)", text: $weight).keyboardType(.numberPad)
                                }
                                
                                Menu {
                                    ForEach(bloodGroups, id: \.self) { group in
                                        Button(group) { selectedBloodGroup = group }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedBloodGroup)
                                            .foregroundColor(selectedBloodGroup == "Blood Group" ? .gray : .text)
                                        Spacer()
                                        Image(systemName: "chevron.down").foregroundColor(.gray)
                                    }
                                    .padding().frame(height: 55).background(Color.bg).cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                }
                            }
                            
                            // Insurance Info (Unified)
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Insurance Information").font(.customFont(style: .bold, size: .h14))
                                Menu {
                                    ForEach(["None", "RSSB", "MMI", "Britam", "UAP", "Other"], id: \.self) { provider in
                                        Button(provider) { selectedInsurance = provider }
                                    }
                                } label: {
                                    HStack {
                                        Text("Provider: \(selectedInsurance)")
                                            .foregroundColor(.text)
                                        Spacer()
                                        Image(systemName: "chevron.down").foregroundColor(.gray)
                                    }
                                    .padding().frame(height: 55).background(Color.bg).cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                }
                                if selectedInsurance != "None" {
                                    CustomTextField(placeholder: "Insurance Number", text: $insuranceNumber)
                                }
                            }
                        }
                        .padding()
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    Button {
                        Task { await saveDetails() }
                    } label: {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Complete Registration")
                                .font(.customFont(style: .bold, size: .h17))
                                .frame(height: 55)
                        }
                    }
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                    .background(Color.appBlue)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding()
                    .disabled(isLoading)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            // Use task instead of onAppear to ensure async initialization completes
            print("🔵 DEBUG: AdditionalInfoView task started - isRegistrationFlow: \(isRegistrationFlow)")
            if isRegistrationFlow {
                // Ensure signup flow flag is set during the entire registration sequence.
                // We MUST set this even if storedUserID exists (e.g. step 2 of signup) 
                // to protect against transient auth state changes.
                SupabaseAuthService.shared.isSignUpFlowInProgress = true
                print("🔵 [AUTH_TRACE] AdditionalInfoView: Shielding auth listener (isSignUpFlowInProgress = true)")
                
                // Ensure role is set, default to patient if not set
                if viewModel.role.isEmpty {
                    viewModel.role = "patient"
                }
                currentUserRole = viewModel.role
                print("🔵 DEBUG: AdditionalInfoView - role set to: \(currentUserRole)")
            } else {
                await syncUserData()
            }
        }
        .sheet(isPresented: $navigateToSuccess) {
            SuccessStateView(onComplete: {
                // Callback to dismiss both sheets
                self.navigateToSuccess = false
                // Also dismiss the parent AdditionalInfoView sheet
                self.dismiss()
            })
        }
    }
    
    private func syncUserData() async {
        print("⚠️ DEBUG: syncUserData called - isRegistrationFlow: \(isRegistrationFlow)")
        if isRegistrationFlow {
            currentUserRole = viewModel.role
            return
        }
        
        if storedUserID.isEmpty {
             if let session = try? await SupabaseManager.shared.client.auth.session {
                 storedUserID = session.user.id.uuidString
                 UserDefaults.standard.set(storedUserID, forKey: "userID")
             }
        }
        
        guard !storedUserID.isEmpty else { return }
        let userId = storedUserID
        
        isSyncing = true
        await SupabaseDBManager.shared.getUserDetails(userId: userId) { success in
            if success {
                defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
                if let savedUser = defaults {
                    self.currentUserRole = savedUser.role ?? "patient"
                    self.address = savedUser.address ?? ""
                    self.phoneNumber = savedUser.phoneNumber ?? ""
                    self.selectedGender = savedUser.gender ?? "Select Gender"
                    self.selectedCountry = savedUser.country ?? "Rwanda"
                    self.selectedInsurance = savedUser.insuranceProvider ?? "None"
                    self.insuranceNumber = savedUser.insuranceNumber ?? ""
                    
                    // Health Metrics Sync
                    self.height = savedUser.height ?? ""
                    self.weight = savedUser.weight ?? ""
                    self.selectedBloodGroup = savedUser.bloodGroup ?? "Blood Group"
                    self.age = savedUser.age ?? ""
                    
                    if let dobStr = savedUser.dob {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        if let date = formatter.date(from: dobStr) {
                            self.dob = date
                        }
                    }
                    
                    if savedUser.role == "doctor" {
                        self.licenseNumber = savedUser.licenseNumber ?? ""
                        self.specialty = savedUser.specialty ?? ""
                        self.experienceYears = savedUser.experienceYears ?? ""
                        self.hospitalName = savedUser.hospitalName ?? ""
                        self.aboutMe = savedUser.aboutMe ?? ""
                    }
                }
            }
            isSyncing = false
        }
    }
    
    private func calculateAge(from birthDate: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        return "\(ageComponents.year ?? 0)"
    }
    
    
    func saveDetails() async {
        if address.isEmpty {
             errorMessage = "Please enter your address."
             return
        }
        
        let userRole = isRegistrationFlow ? viewModel.role : currentUserRole
        if userRole == "doctor" && (licenseNumber.isEmpty || specialty.isEmpty) {
            errorMessage = "License Number and Specialty are required."
            return
        }
        
        self.isLoading = true
        
        Task {
            if isRegistrationFlow {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let userAge = calculateAge(from: dob)
                let newUser = AppUser(
                    password: viewModel.password,
                    email: viewModel.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                    firstName: viewModel.firstName,
                    lastName: viewModel.lastName,
                    createdAt: Date(),
                    height: height,
                    weight: weight,
                    age: userAge,
                    bloodGroup: selectedBloodGroup,
                    phoneNumber: phoneNumber,
                    imageURL: "",
                    address: address,
                    gender: selectedGender,
                    dob: formatter.string(from: dob),
                    role: userRole,
                    verificationStatus: userRole == "doctor" ? "pending" : "verified",
                    hospitalName: hospitalName,
                    experienceYears: experienceYears,
                    country: selectedCountry,
                    city: address.components(separatedBy: ",").last?.trimmingCharacters(in: .whitespaces) ?? "",
                    specialty: specialty,
                    licenseNumber: licenseNumber,
                    aboutMe: aboutMe,
                    insuranceProvider: selectedInsurance,
                    insuranceNumber: insuranceNumber
                )
                
                do {
                    print("🔵 DEBUG: saveDetails() - Calling SupabaseAuthService.signUp")
                    let signUpResult = try await SupabaseAuthService.shared.signUp(user: newUser)
                    UserDefaults.standard.set(encodable: newUser, forKey: "userDetails")
                    if let uid = signUpResult?.id.uuidString {
                        storedUserID = uid
                        UserDefaults.standard.set(uid, forKey: "userID")
                        
                        // Explicitly update the profile in DB to ensure verificationStatus is set correctly
                        // (e.g. "verified" for patients) and all fields are populated.
                        print("🔵 DEBUG: saveDetails() - Updating database profile for user: \(uid)")
                        try await SupabaseDBManager.shared.updateUserDetails(userId: uid, user: newUser)
                    }
                    
                    await MainActor.run {
                        self.isLoading = false
                        print("🔵 DEBUG: saveDetails() - Navigating to SuccessStateView")
                        self.navigateToSuccess = true
                    }
                } catch {
                    print("❌ DEBUG: saveDetails() failed: \(error.localizedDescription)")
                    await MainActor.run {
                        self.errorMessage = "Registration failed: \(error.localizedDescription)"
                        self.isLoading = false
                        // Reset flag on error too
                        SupabaseAuthService.shared.isSignUpFlowInProgress = false
                    }
                }
                return
            }
            
            // Existing User Update Mode
            if storedUserID.isEmpty {
                if let session = try? await SupabaseManager.shared.client.auth.session {
                    storedUserID = session.user.id.uuidString
                    UserDefaults.standard.set(storedUserID, forKey: "userID")
                }
            }
            
            guard !storedUserID.isEmpty else {
                self.isLoading = false
                self.errorMessage = "User session not found."
                return
            }
            
            if var updatedUser = UserDefaults.standard.value(AppUser.self, forKey: "userDetails") {
                updatedUser.address = address
                updatedUser.phoneNumber = phoneNumber
                updatedUser.gender = selectedGender
                updatedUser.country = selectedCountry
                updatedUser.insuranceProvider = selectedInsurance
                updatedUser.insuranceNumber = insuranceNumber
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                updatedUser.dob = formatter.string(from: dob)
                
                if (updatedUser.role ?? userRole) == "doctor" {
                    updatedUser.licenseNumber = licenseNumber
                    updatedUser.specialty = specialty
                    updatedUser.experienceYears = experienceYears
                    updatedUser.hospitalName = hospitalName
                    updatedUser.aboutMe = aboutMe
                    updatedUser.verificationStatus = "pending"
                } else {
                    updatedUser.height = height
                    updatedUser.weight = weight
                    updatedUser.bloodGroup = selectedBloodGroup
                    updatedUser.verificationStatus = "verified"
                    updatedUser.age = calculateAge(from: dob)
                }
                
                await SupabaseDBManager.shared.updateUserDetails(storedUserID, dataModel: updatedUser) { success in
                    self.isLoading = false
                    if success { self.navigateToSuccess = true }
                    else { self.errorMessage = "Failed to save details." }
                }
            } else {
                self.isLoading = false
                self.errorMessage = "Local profile not found."
            }
        }
    }
}

// Role-aware SuccessStateView (No NavigationStack here, it's provided by the parent)
struct SuccessStateView: View {
    @State private var userRole: String = "patient"
    @State private var isCompleting = false
    @Environment(\.dismiss) var dismiss
    var onComplete: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: userRole == "doctor" ? "clock.badge.checkmark.fill" : "checkmark.seal.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.appBlue)
                .padding()
            
            Text(userRole == "doctor" ? "Registration Received!" : "All set!")
                .font(.customFont(style: .bold, size: .h24))
                .padding(.top, 10)
            
            Text(userRole == "doctor" 
                 ? "Your professional profile is now under review for verification. This usually takes 24-48 hours. In the meantime, you can access your dashboard."
                 : "Your profile has been created successfully.")
                .font(.customFont(style: .medium, size: .h15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 5)
            
            Spacer()
            
            VStack(spacing: 10) {
                Text("Redirecting to home...")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                ProgressView()
                    .tint(.appBlue)
            }
            .padding(.bottom, 20)
            
            Button {
                handleCompletion()
            } label: {
                Text(userRole == "doctor" ? "Go to Doctor Dashboard" : "Go to Home")
                    .font(.customFont(style: .bold, size: .h17))
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                    .frame(height: 55)
                    .background(Color.appBlue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding()
            .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let user = UserDefaults.standard.value(AppUser.self, forKey: "userDetails") {
                self.userRole = user.role ?? "patient"
                print("SuccessStateView: Detected user role as \(self.userRole)")
            } else {
                print("SuccessStateView: userDetails not found in UserDefaults, defaulting to patient")
            }
            
            // Auto-dismiss after 2.5 seconds
            Task {
                try? await Task.sleep(nanoseconds: 2_500_000_000)
                await MainActor.run {
                    handleCompletion()
                }
            }
        }
    }
    
    private func handleCompletion() {
        guard !isCompleting else { 
            print("⚠️ SuccessStateView: Already completing, ignoring.")
            return 
        }
        isCompleting = true
        
        print("🔵 SuccessStateView: Completing registration flow")
        
        // Call the completion callback to dismiss parent sheets
        onComplete?()
        
        // Trigger navigation update
        Task { @MainActor in
            // Small buffer to allow sheets to dismiss and session to stabilize
            try? await Task.sleep(nanoseconds: 500_000_000) 
            
            // ENSURE Signup flag is cleared AFTER we've triggered the final auth status refresh
            // We also do a quick check: if storedUserID is empty here, we have a problem.
            if UserDefaults.standard.string(forKey: "userID")?.isEmpty ?? true {
                print("⚠️ [AUTH_TRACE] SuccessStateView completion: userID is unexpectedly empty!")
            }
            
            SupabaseAuthService.shared.isSignUpFlowInProgress = false
            NotificationCenter.default.post(name: NSNotification.Name("SignupFlowCompleted"), object: nil)
            
            print("🔵 SuccessStateView: Triggering AuthStatusChanged")
            NotificationCenter.default.post(name: NSNotification.Name("AuthStatusChanged"), object: nil)
        }
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        if userRole == "doctor" {
            DoctorHomeDashboard()
        } else {
            HomeDashboard()
        }
    }
}
