//
//  LoginView.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 01/09/24.
//

import SwiftUI
// import FirebaseAuth  // DEPRECATED: Migrated to Supabase

struct LoginView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    
    enum Field: Hashable {
        case emailField
        case passwordField
    }
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            if viewModel.isLoading {
                ProgressView("Please wait...")
                    .padding()
                    .background(Color.card)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .zIndex(1)
            }
            VStack {
                // Header with Back Button
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
                        CustomTextField(placeholder: Texts.enterEmail.description, text: $viewModel.email)
                            .textInputAutocapitalization(.never)
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
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .submitLabel(.done)
                            .focused($focusedField, equals: .passwordField)
                            .onTapGesture {
                                viewModel.clearValidationMessage()
                            }
                            .onSubmit {
                                focusedField = nil
                            }
                        
                        Button {
                            print("Forget password tapped!")
                            viewModel.showingResetPasswordSheet = true
                        }  label: {
                            Text(Texts.forgotPassword.description)
                                .font(.customFont(style: .medium, size: .h16))
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 10)
                    }
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                    
                    Button {
                        print("Login tapped!")
                        Task {
                            if await viewModel.signIn() {
                                await viewModel.getUserDetails()
                                viewModel.isShowingHomeView = true
                            }
                        }
                    } label: {
                        Text(Texts.login.description)
                            .foregroundColor(.white)
                            .font(.customFont(style: .bold, size: .h17))
                            .padding()
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                            .background(Color.appBlue)
                            .cornerRadius(30)
                    }
                    .padding(.bottom, 10)
                    
                    Button {
                        print("Signup tapped!")
                        // Notify AppRootView to disable auth listener during signup
                        NotificationCenter.default.post(name: NSNotification.Name("SignupFlowStarted"), object: nil)
                        viewModel.isShowingSignUpScreen = true
                    } label: {
                        HStack(spacing: 10) {
                            Text(Texts.accountMessage.description)
                                .font(.customFont(style: .medium, size: .h15))
                                .foregroundColor(.text)
                            Text(Texts.signup.description)
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
            .scrollDismissesKeyboard(.interactively)
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            print("🔵 LoginView appeared")
        }
    }
}

       

#Preview {
    LoginView(viewModel: AuthenticationViewModel())
}
// MARK: - Appended Views for Project Scope

struct RoleSelectionView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
            
            Text("Welcome to ClinicBooking")
                .font(.customFont(style: .bold, size: .h24))
            
            Text("Please select your role to continue")
                .font(.customFont(style: .medium, size: .h15))
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(spacing: 20) {
                NavigationLink(destination: LoginView(viewModel: viewModel)) {
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.title2)
                        Text("I am a Patient")
                            .font(.customFont(style: .bold, size: .h17))
                    }
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                    .frame(height: 55)
                    .background(Color.appBlue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                
                NavigationLink(destination: DoctorAuthOverviewView(authViewModel: viewModel)) {
                    HStack {
                        Image(systemName: "stethoscope")
                            .font(.title2)
                        Text("I am a Doctor")
                            .font(.customFont(style: .bold, size: .h17))
                    }
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                    .frame(height: 55)
                    .background(Color.bg)
                    .foregroundColor(.appBlue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.appBlue, lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .navigationDestination(isPresented: $viewModel.isShowingSignUpScreen) {
            SignupView(viewModel: viewModel)
        }
        .navigationDestination(isPresented: $viewModel.isShowingHomeView) {
            HomeDashboard()
                .navigationBarBackButtonHidden(true)
        }
        .sheet(isPresented: $viewModel.showingResetPasswordSheet) {
            ForgotPasswordView()
                .presentationDetents([.medium])
        }
    }
}

struct VerificationPendingView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "clock.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
            
            Text("Verification Pending")
                .font(.customFont(style: .bold, size: .h24))
            
            Text("Your doctor account is currently under review. This usually takes 24-48 hours. We will notify you once your credentials have been verified.")
                .font(.customFont(style: .medium, size: .h15))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Spacer()
            
            Button {
                // We no longer sign out here.
                // The AppRootView will detect the successful registration/auth state
                // and switch the view to DoctorHomeDashboard automatically.
                // If the user clicks this, we just want to ensure we clear any local navigation states
                // or just stay put and let the root view handle it.
                dismiss() 
            } label: {
                Text("Return to Home")
                    .font(.customFont(style: .bold, size: .h17))
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                    .frame(height: 55)
                    .background(Color.appBlue.opacity(0.1))
                    .foregroundColor(.appBlue)
                    .cornerRadius(15)
            }
            .padding()
        }
        .padding()
        .navigationBarHidden(true)
    }
}

struct DoctorLoginView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @State private var licenseNumber = ""
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        VStack(spacing: 25) {
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
                Text("Doctor Login")
                    .font(.customFont(style: .bold, size: .h18))
                Spacer()
                Image(systemName: "chevron.left").opacity(0).padding(10)
            }
            .padding(.horizontal, 5)
            .padding()
            
            if viewModel.isLoading {
                ProgressView("Verifying credentials...")
                    .padding()
                    .background(Color.card)
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
            
            ScrollView {
                VStack(spacing: 25) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    
                    Text("Welcome Back, Doctor")
                        .font(.customFont(style: .bold, size: .h24))
                    
                    Text("Enter your credentials to access your dashboard.")
                        .font(.customFont(style: .medium, size: .h15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        CustomTextField(placeholder: "Email Address", text: $viewModel.email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                        CustomTextField(placeholder: "Medical License Number", text: $licenseNumber)
                        
                        CustomTextField(placeholder: "Password", text: $viewModel.password, isSecure: true)
                    }
                    .padding()
                    .frame(maxWidth: sizeClass == .regular ? 450 : .infinity)
                    .frame(maxWidth: .infinity)
                    
                    if let error = viewModel.validationMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button {
                        loginDoctor()
                    } label: {
                        Text("Log In")
                            .font(.customFont(style: .bold, size: .h17))
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                    }
                    .buttonStyle(BlueButtonStyle(height: 55, color: .appBlue))
                    .frame(maxWidth: sizeClass == .regular ? 450 : .infinity)
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HStack {
                        Text("Don't have an account?")
                            .font(.customFont(style: .medium, size: .h15))
                            .foregroundColor(.gray)
                        
                        NavigationLink(destination: DoctorRegistrationContainerView()) {
                            Text("Register")
                                .font(.customFont(style: .bold, size: .h15))
                                .foregroundColor(.appBlue)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    func loginDoctor() {
        Task {
            if await viewModel.signInDoctor(licenseNumber: licenseNumber) {
                dismiss()
            }
        }
    }
}
struct DoctorAuthOverviewView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        VStack(spacing: 30) {
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
                Text("Doctor Portal")
                    .font(.customFont(style: .bold, size: .h18))
                Spacer()
                Image(systemName: "chevron.left").opacity(0).padding(10)
            }
            .padding(.horizontal, 5)
            
            Spacer()
            
            Image(systemName: "stethoscope")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.appBlue)
            
            VStack(spacing: 15) {
                Text("Welcome, Doctor")
                    .font(.customFont(style: .bold, size: .h24))
                
                Text("Join our network of healthcare professionals or sign in to manage your appointments.")
                    .font(.customFont(style: .medium, size: .h15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            VStack(spacing: 20) {
                NavigationLink(destination: DoctorLoginView(viewModel: authViewModel)) {
                    Text("Log In")
                        .font(.customFont(style: .bold, size: .h17))
                        .frame(maxWidth: sizeClass == .regular ? 450 : .infinity)
                        .frame(height: 55)
                        .background(Color.appBlue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                
                NavigationLink(destination: DoctorRegistrationContainerView()) {
                    Text("Join as a Doctor")
                        .font(.customFont(style: .bold, size: .h17))
                        .frame(maxWidth: sizeClass == .regular ? 450 : .infinity)
                        .frame(height: 55)
                        .background(Color.white)
                        .foregroundColor(.appBlue)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.appBlue, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Doctor Registration Views (Consolidated for Scope)

class DoctorRegistrationViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var phoneNumber = ""
    @Published var hospitalName = ""
    @Published var specialty = ""
    @Published var experienceYears = ""
    @Published var selectedCountry = ""
    @Published var selectedCity = ""
    @Published var licenseNumber = ""
    @Published var gender = "Select Gender"
    @Published var aboutMe = ""
    @Published var dob = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    @Published var insuranceProvider = "None"
    @Published var insuranceNumber = ""
    @Published var hasAgreedToTerms = false
    @Published var currentStep = 1
    @Published var totalSteps = 3
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var navigateToPending = false
}

struct DoctorRegistrationContainerView: View {
    @StateObject private var regVM = DoctorRegistrationViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    if regVM.currentStep > 1 { regVM.currentStep -= 1 }
                    else { dismiss() }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(10)
                        .contentShape(Rectangle())
                }
                Spacer()
                Text("Doctor Registration").font(.customFont(style: .bold, size: .h18))
                Spacer()
                Image(systemName: "chevron.left").opacity(0)
            }
            .padding()
            
            HStack(spacing: 4) {
                ForEach(1...regVM.totalSteps, id: \.self) { step in
                    Rectangle()
                        .fill(step <= regVM.currentStep ? Color.appBlue : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }
            .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 20) {
                    if regVM.currentStep == 1 { DoctorRegStep1View(viewModel: regVM) }
                    else if regVM.currentStep == 2 { DoctorRegStep2View(viewModel: regVM) }
                    else { DoctorRegStep3View(viewModel: regVM) }
                }
                .padding()
                .frame(maxWidth: sizeClass == .regular ? 450 : .infinity)
                .frame(maxWidth: .infinity)
            }
            
            VStack(spacing: 15) {
                if let error = regVM.errorMessage {
                    Text(error).foregroundColor(.red).font(.caption)
                }
                
                Button { nextStep() } label: {
                    if regVM.isLoading { ProgressView().tint(.white) }
                    else {
                        Text(regVM.currentStep == regVM.totalSteps ? "Submit Application" : "Continue")
                            .font(.customFont(style: .bold, size: .h17))
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                    }
                }
                .buttonStyle(BlueButtonStyle(height: 55, color: .appBlue))
                .frame(maxWidth: sizeClass == .regular ? 450 : .infinity)
                .disabled(regVM.isLoading)
                
                if regVM.currentStep == 1 {
                    HStack {
                        Text("Already have an account?").font(.customFont(style: .medium, size: .h15)).foregroundColor(.gray)
                        Button { dismiss() } label: {
                            Text("Log In").font(.customFont(style: .bold, size: .h15)).foregroundColor(.appBlue)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .padding()
        }
        .animation(.easeInOut, value: regVM.currentStep)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $regVM.navigateToPending) {
            DoctorVerificationView()
                .navigationBarBackButtonHidden(true)
        }
    }
    
    func nextStep() {
        regVM.errorMessage = nil
        withAnimation {
            if regVM.currentStep == 1 { if validateStep1() { regVM.currentStep = 2 } }
            else if regVM.currentStep == 2 { if validateStep2() { regVM.currentStep = 3 } }
            else { if validateStep3() { submitApplication() } }
        }
    }
    
    func validateStep1() -> Bool {
        if regVM.firstName.isEmpty || regVM.lastName.isEmpty || regVM.email.isEmpty || regVM.password.isEmpty || regVM.phoneNumber.isEmpty {
            regVM.errorMessage = "Please fill in all details."; return false
        }
        return true
    }
    
    func validateStep2() -> Bool {
        if regVM.hospitalName.isEmpty || regVM.specialty.isEmpty || regVM.experienceYears.isEmpty || regVM.selectedCountry.isEmpty || regVM.selectedCity.isEmpty {
            regVM.errorMessage = "Please complete your professional profile."; return false
        }
        return true
    }
    
    func validateStep3() -> Bool {
        if regVM.licenseNumber.isEmpty { regVM.errorMessage = "Medical License Number is required."; return false }
        if !regVM.hasAgreedToTerms { regVM.errorMessage = "You must agree to the Terms & Conditions."; return false }
        return true
    }
    
    func submitApplication() {
        regVM.isLoading = true
        Task {
            let doctorUser = AppUser(
                password: regVM.password,
                email: regVM.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                firstName: regVM.firstName,
                lastName: regVM.lastName,
                createdAt: Date(),
                height: "",
                weight: "",
                age: "",
                bloodGroup: "",
                phoneNumber: regVM.phoneNumber,
                imageURL: "",
                address: "\(regVM.selectedCity), \(regVM.selectedCountry)",
                gender: regVM.gender,
                dob: {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.string(from: regVM.dob)
                }(),
                role: "doctor",
                verificationStatus: "pending",
                hospitalName: regVM.hospitalName,
                experienceYears: regVM.experienceYears,
                country: regVM.selectedCountry,
                city: regVM.selectedCity,
                specialty: regVM.specialty,
                licenseNumber: regVM.licenseNumber,
                aboutMe: regVM.aboutMe,
                insuranceProvider: regVM.insuranceProvider,
                insuranceNumber: regVM.insuranceNumber
            )
            
            
            do {
                print("🔵 Starting doctor registration for: \(doctorUser.email ?? "")")
                
                // Set signup flag to prevent premature auth listener reaction
                SupabaseAuthService.shared.isSignUpFlowInProgress = true
                
                // Race the signUp call against a 30-second timeout
                try await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        _ = try await SupabaseAuthService.shared.signUp(user: doctorUser)
                    }
                    group.addTask {
                        try await Task.sleep(nanoseconds: 30 * 1_000_000_000) // 30 seconds
                        throw URLError(.timedOut)
                    }
                    try await group.next()
                }

                print("✅ Doctor registration successful!")
                
                // Cache user details locally to ensure immediate session availability
                UserDefaults.standard.set(encodable: doctorUser, forKey: "userDetails")
                
                // Note: userID will be picked up by AppRootView listener from session/storedUserID
                
                // Update UI on main thread
                await MainActor.run {
                    print("🟢 Registration finished - navigating to verification")
                    regVM.isLoading = false
                    regVM.navigateToPending = true
                }

            } catch {
                print("❌ Registration error: \(error.localizedDescription)")
                await MainActor.run {
                    regVM.isLoading = false
                    if let urlError = error as? URLError, urlError.code == .timedOut {
                         regVM.errorMessage = "Registration timed out. Please check your internet connection."
                    } else {
                         regVM.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}

struct DoctorRegStep1View: View {
    @ObservedObject var viewModel: DoctorRegistrationViewModel
    var body: some View {
        VStack(spacing: 20) {
            Text("Personal Details").font(.title2).frame(maxWidth: .infinity, alignment: .leading)
            CustomTextField(placeholder: "First Name", text: $viewModel.firstName)
            CustomTextField(placeholder: "Last Name", text: $viewModel.lastName)
            CustomTextField(placeholder: "Phone Number", text: $viewModel.phoneNumber).keyboardType(.phonePad)
            CustomTextField(placeholder: "Email Address", text: $viewModel.email).textInputAutocapitalization(.never).keyboardType(.emailAddress)
            CustomTextField(placeholder: "Password", text: $viewModel.password, isSecure: true)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Gender").font(.subheadline).foregroundColor(.gray)
                Menu {
                    ForEach(AppConstants.genders, id: \.self) { g in
                        Button(g) { viewModel.gender = g }
                    }
                } label: {
                    HStack {
                        Text(viewModel.gender == "Select Gender" ? "Select Gender" : viewModel.gender)
                            .foregroundColor(viewModel.gender == "Select Gender" ? .gray : .text)
                        Spacer(); Image(systemName: "chevron.down").foregroundColor(.gray)
                    }
                    .padding().frame(height: 55).background(Color.bg).cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Date of Birth").font(.subheadline).foregroundColor(.gray)
                DatePicker("", selection: $viewModel.dob, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding().frame(height: 55).background(Color.bg).cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }
            .padding(.top, 5)
        }
    }
}

struct DoctorRegStep2View: View {
    @ObservedObject var viewModel: DoctorRegistrationViewModel
    let specialties = AppConstants.specializations.map { $0.0 }
    var body: some View {
        VStack(spacing: 20) {
            Text("Professional Info").font(.title2).frame(maxWidth: .infinity, alignment: .leading)
            CustomTextField(placeholder: "Hospital / Clinic Name", text: $viewModel.hospitalName)
            Menu {
                ForEach(specialties, id: \.self) { spec in Button(spec) { viewModel.specialty = spec } }
            } label: {
                HStack {
                    Text(viewModel.specialty.isEmpty ? "Select Specialty" : viewModel.specialty).foregroundColor(viewModel.specialty.isEmpty ? .gray : .text)
                    Spacer(); Image(systemName: "chevron.down").foregroundColor(.gray)
                }.padding().frame(height: 55).background(Color.bg).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }
            CustomTextField(placeholder: "Years of Experience", text: $viewModel.experienceYears).keyboardType(.numberPad)
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Country").font(.caption).foregroundColor(.gray)
                    Menu {
                        ForEach(AppConstants.countries, id: \.self) { c in
                            Button(c) { viewModel.selectedCountry = c }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedCountry.isEmpty ? "Select Country" : viewModel.selectedCountry)
                                .font(.system(size: 14))
                                .foregroundColor(viewModel.selectedCountry.isEmpty ? .gray : .text)
                                .lineLimit(1)
                            Spacer(); Image(systemName: "chevron.down").font(.caption).foregroundColor(.gray)
                        }
                        .padding(.horizontal, 10).frame(height: 55).background(Color.bg).cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("City").font(.caption).foregroundColor(.gray)
                    CustomTextField(placeholder: "City", text: $viewModel.selectedCity)
                }
            }
        }
    }
}

struct DoctorRegStep3View: View {
    @ObservedObject var viewModel: DoctorRegistrationViewModel
    @Environment(\.horizontalSizeClass) var sizeClass
    var body: some View {
        VStack(spacing: 20) {
            Text("Professional Details").font(.title2).frame(maxWidth: .infinity, alignment: .leading)
            CustomTextField(placeholder: "Medical License Number", text: $viewModel.licenseNumber)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Insurance Information (Optional)").font(.subheadline).foregroundColor(.gray)
                Menu {
                    ForEach(AppConstants.insuranceProviders, id: \.self) { p in
                        Button(p) { viewModel.insuranceProvider = p }
                    }
                } label: {
                    HStack {
                        Text("Provider: \(viewModel.insuranceProvider)")
                            .foregroundColor(.text)
                        Spacer(); Image(systemName: "chevron.down").foregroundColor(.gray)
                    }
                    .padding().frame(height: 55).background(Color.bg).cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
                
                if viewModel.insuranceProvider != "None" {
                    CustomTextField(placeholder: "Insurance Number / ID", text: $viewModel.insuranceNumber)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("About Me / Biography").font(.subheadline).foregroundColor(.gray)
                TextEditor(text: $viewModel.aboutMe)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color.bg)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }

            Button { } label: {
                VStack(spacing: 10) {
                    Image(systemName: "doc.text.viewfinder").font(.largeTitle).foregroundColor(.appBlue)
                    Text("Upload Medical License / ID").font(.subheadline).foregroundColor(.gray)
                }.frame(maxWidth: .infinity).frame(height: 120).background(Color.appBlue.opacity(0.05)).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appBlue, style: StrokeStyle(lineWidth: 1, dash: [5])))
            }
            .frame(maxWidth: sizeClass == .regular ? 450 : .infinity)
            Toggle(isOn: $viewModel.hasAgreedToTerms) {
                Text("I agree to the Terms & Conditions and certify that the information provided is accurate.").font(.caption).foregroundColor(.gray)
            }.toggleStyle(SwitchToggleStyle(tint: .appBlue))
        }
    }
}
