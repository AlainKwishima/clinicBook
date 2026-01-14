//
//  LoginView.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 01/09/24.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    enum Field: Hashable {
        case emailField
        case passwordField
    }
    @FocusState private var focusedField: Field?

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            if viewModel.isLoading {
                ProgressView("Please wait...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .zIndex(1)
            }
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
                VStack(spacing: 20) {
                    if let message = viewModel.validationMessage {
                        Text(message)
                            .foregroundColor(.red)
                            .font(.customFont(style: .medium, size: .h15))
                            .padding()
                    }
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
                    .padding()
                    .foregroundColor(Color.appBlue)
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
                            .frame(maxWidth: .infinity)
                            .background(Color.appBlue)
                            .cornerRadius(30)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }
                    Button {
                        print("Sigup tapped!")
                        viewModel.isShowingSignUpScreen = true
                    } label: {
                        HStack(spacing: 10) {
                            Text(Texts.accountMessage.description)
                                .font(.customFont(style: .medium, size: .h15))
                                .foregroundColor(.black)
                            Text(Texts.signup.description)
                                .foregroundColor(Color.appBlue)
                                .underline()
                                .font(.customFont(style: .bold, size: .h17))
                        }
                    }
                }
                Spacer()
                Spacer()
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .ignoresSafeArea(.keyboard)
        .navigationDestination(isPresented: $viewModel.isShowingSignUpScreen) {
            SignupView()
        }
        .navigationDestination(isPresented: $viewModel.isShowingHomeView) {
            HomeDashboard()
                .navigationBarBackButtonHidden(true)
        }
        .sheet(isPresented: $viewModel.showingResetPasswordSheet) {
            ForgotPasswordView()
                .presentationDetents([.medium])
        }
        .onAppear {

        }
    }
}

#Preview {
    LoginView()
}
// MARK: - Appended Views for Project Scope

struct RoleSelectionView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
            
            Text("Welcome to ClinicBooking")
                .font(.customFont(style: .bold, size: .h24))
                .padding(.bottom, 10)
            
            Text("Please select your role to continue")
                .font(.customFont(style: .medium, size: .h15))
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(spacing: 20) {
                NavigationLink(destination: LoginView()) {
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.title2)
                        Text("I am a Patient")
                            .font(.customFont(style: .bold, size: .h17))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.appBlue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                
                NavigationLink(destination: DoctorAuthOverviewView()) {
                    HStack {
                        Image(systemName: "stethoscope")
                            .font(.title2)
                        Text("I am a Doctor")
                            .font(.customFont(style: .bold, size: .h17))
                    }
                    .frame(maxWidth: .infinity)
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
                    .frame(maxWidth: .infinity)
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
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var licenseNumber = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
                Text("Doctor Login")
                    .font(.customFont(style: .bold, size: .h18))
                Spacer()
                Image(systemName: "chevron.left").opacity(0)
            }
            .padding()
            
            if viewModel.isLoading {
                ProgressView("Verifying credentials...")
                    .padding()
                    .background(Color.white)
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
                        
                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    .padding()
                    
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
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BlueButtonStyle(height: 55, color: .appBlue))
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
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
                Text("Doctor Portal")
                    .font(.customFont(style: .bold, size: .h18))
                Spacer()
                Image(systemName: "chevron.left").opacity(0)
            }
            .padding()
            
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
                NavigationLink(destination: DoctorLoginView()) {
                    Text("Log In")
                        .font(.customFont(style: .bold, size: .h17))
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.appBlue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                
                NavigationLink(destination: DoctorRegistrationContainerView()) {
                    Text("Join as a Doctor")
                        .font(.customFont(style: .bold, size: .h17))
                        .frame(maxWidth: .infinity)
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
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    if regVM.currentStep > 1 { regVM.currentStep -= 1 }
                    else { dismiss() }
                }) {
                    Image(systemName: "chevron.left").font(.title2).foregroundColor(.black)
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
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(BlueButtonStyle(height: 55, color: .appBlue))
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
            VerificationPendingView()
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
            let authModel = AuthenticationViewModel()
            authModel.email = regVM.email
            authModel.password = regVM.password
            authModel.firstName = regVM.firstName
            authModel.lastName = regVM.lastName
            await authModel.signup()
            
            if authModel.shouldNavigateToAdditionalInfo || authModel.validationMessage?.contains("Successful") == true {
                if let userId = Auth.auth().currentUser?.uid {
                    let doctorUser = AppUser(
                        password: regVM.password, email: regVM.email, firstName: regVM.firstName, lastName: regVM.lastName, createdAt: Date(),
                        height: "", weight: "", age: "", bloodGroup: "", phoneNumber: regVM.phoneNumber, imageURL: "",
                        address: "\(regVM.selectedCity), \(regVM.selectedCountry)", role: "doctor", verificationStatus: "pending",
                        hospitalName: regVM.hospitalName, experienceYears: regVM.experienceYears, country: regVM.selectedCountry, city: regVM.selectedCity,
                        specialty: regVM.specialty, licenseNumber: regVM.licenseNumber, aboutMe: ""
                    )
                    await FireStoreManager.shared.updateUserDetails(userId, dataModel: doctorUser) { success in
                        regVM.isLoading = false
                        if success { regVM.navigateToPending = true }
                        else { regVM.errorMessage = "Failed to save doctor details." }
                    }
                }
            } else {
                regVM.isLoading = false
                regVM.errorMessage = authModel.validationMessage ?? "Registration failed."
            }
        }
    }
}

struct DoctorRegStep1View: View {
    @ObservedObject var viewModel: DoctorRegistrationViewModel
    var body: some View {
        VStack(spacing: 20) {
            Text("Personal Details").font(.title2).bold().frame(maxWidth: .infinity, alignment: .leading)
            CustomTextField(placeholder: "First Name", text: $viewModel.firstName)
            CustomTextField(placeholder: "Last Name", text: $viewModel.lastName)
            CustomTextField(placeholder: "Phone Number", text: $viewModel.phoneNumber).keyboardType(.phonePad)
            CustomTextField(placeholder: "Email Address", text: $viewModel.email).textInputAutocapitalization(.never).keyboardType(.emailAddress)
            SecureField("Password", text: $viewModel.password).padding().frame(height: 55).background(Color.white).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
        }
    }
}

struct DoctorRegStep2View: View {
    @ObservedObject var viewModel: DoctorRegistrationViewModel
    let specialties = AppConstants.specializations.map { $0.0 }
    var body: some View {
        VStack(spacing: 20) {
            Text("Professional Info").font(.title2).bold().frame(maxWidth: .infinity, alignment: .leading)
            CustomTextField(placeholder: "Hospital / Clinic Name", text: $viewModel.hospitalName)
            Menu {
                ForEach(specialties, id: \.self) { spec in Button(spec) { viewModel.specialty = spec } }
            } label: {
                HStack {
                    Text(viewModel.specialty.isEmpty ? "Select Specialty" : viewModel.specialty).foregroundColor(viewModel.specialty.isEmpty ? .gray : .black)
                    Spacer(); Image(systemName: "chevron.down").foregroundColor(.gray)
                }.padding().frame(height: 55).background(Color.white).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }
            CustomTextField(placeholder: "Years of Experience", text: $viewModel.experienceYears).keyboardType(.numberPad)
            HStack(spacing: 15) {
                CustomTextField(placeholder: "Country", text: $viewModel.selectedCountry)
                CustomTextField(placeholder: "City", text: $viewModel.selectedCity)
            }
        }
    }
}

struct DoctorRegStep3View: View {
    @ObservedObject var viewModel: DoctorRegistrationViewModel
    var body: some View {
        VStack(spacing: 20) {
            Text("Verification & Terms").font(.title2).bold().frame(maxWidth: .infinity, alignment: .leading)
            CustomTextField(placeholder: "Medical License Number", text: $viewModel.licenseNumber)
            Button { } label: {
                VStack(spacing: 10) {
                    Image(systemName: "doc.text.viewfinder").font(.largeTitle).foregroundColor(.appBlue)
                    Text("Upload Medical License / ID").font(.subheadline).foregroundColor(.gray)
                }.frame(maxWidth: .infinity).frame(height: 120).background(Color.appBlue.opacity(0.05)).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appBlue, style: StrokeStyle(lineWidth: 1, dash: [5])))
            }
            Toggle(isOn: $viewModel.hasAgreedToTerms) {
                Text("I agree to the Terms & Conditions and certify that the information provided is accurate.").font(.caption).foregroundColor(.gray)
            }.toggleStyle(SwitchToggleStyle(tint: .appBlue))
        }
    }
}
