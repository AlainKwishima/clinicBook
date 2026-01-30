//
//  AddFamilyMemberView.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 03/09/24.
//

import SwiftUI
import PhotosUI
import iPhoneNumberField
import Supabase

struct EditProfileView: View {
    enum Field: Hashable {
        case firstName
        case lastName
        case height
        case weight
        case age
        case phoneNumber
    }
    @State var defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""
    @State var height: String = ""
    @State var weight: String = ""
    @State var age: String = ""
    @State var bloodGroup: String = ""
    @State var phoneNumber: String = ""
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @Environment(\.dismiss) var dismiss
    var bloodGroups = ["Blood Group", "O+", "O-", "A+", "A-", "B+", "B-", "AB+", "AB-"]
    @State private var selectedBloodGroup : String = "Blood Group"
    @FocusState private var focusedField: Field?
    @State var isEditing: Bool = false
    @State private var selectedPhotoData: Data?
    @State var imageURL: String = ""
    @StateObject private var userViewModel = UserViewModel()
    
    // Doctor Specific Fields
    @State var hospitalName: String = ""
    @State var specialty: String = ""
    @State var experienceYears: String = ""
    @State var aboutMe: String = ""
    @State var licenseNumber: String = ""
    @State private var isUploadingImage: Bool = false
    @State private var isSaving: Bool = false


    var disableForm: Bool {
        firstName.count < 4 || lastName.count < 1 || height.count < 1 || weight.count < 1 || age.count < 1
        || phoneNumber.count < 9
    }

    var body: some View {
        VStack(spacing: 0) {
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
                Spacer()
                Text("Edit Profile")
                    .font(.customFont(style: .bold, size: .h18))
                Spacer()
                Image(systemName: "chevron.left").opacity(0).padding(10)
            }
            .padding(.horizontal, 5)
            .padding(.top, 10)
            .background(Color.white)
            
            ScrollView(.vertical) {
                VStack(spacing: 25) {
                    PhotosPicker(selection: $avatarItem, matching: .images) {
                        VStack(spacing: 12) {
                            if imageURL == "" {
                                avatarImage?
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.appBlue.opacity(0.1), lineWidth: 4))
                            } else {
                                AsyncImage(
                                    url: URL(string: defaults?.imageURL ?? ""),
                                    content: { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.appBlue.opacity(0.1), lineWidth: 4))
                                    },
                                    placeholder: {
                                        if (defaults?.imageURL ?? "").isEmpty {
                                            Image("user")
                                                .resizable()
                                                .frame(width: 120, height: 120)
                                                .clipShape(Circle())
                                        } else {
                                            ProgressView()
                                                .frame(width: 120, height: 120)
                                        }
                                    })
                            }
                            
                            if isUploadingImage {
                                ProgressView()
                                    .frame(width: 120, height: 120)
                                    .background(Color.white.opacity(0.7))
                                    .clipShape(Circle())
                                    .padding(.top, -132) // Overlay on top of image
                            }
                            
                            Text("Change Photo")
                                .font(.customFont(style: .bold, size: .h14))
                                .foregroundColor(.appBlue)
                        }
                    }
                    .padding(.vertical, 20)

                    VStack(spacing: 20) {
                        HStack(spacing: 15) {
                            CustomTextField(placeholder: defaults?.firstName ?? "", text: $firstName)
                                .submitLabel(.next)
                                .disabled(true)
                                .focused($focusedField, equals: .firstName)
                                .onSubmit {
                                    focusedField = .lastName
                                }
                            CustomTextField(placeholder: defaults?.lastName ?? "", text: $lastName)
                                .submitLabel(.next)
                                .disabled(true)
                                .focused($focusedField, equals: .lastName)
                                .onSubmit {
                                    focusedField = .height
                                }
                        }
                        .padding(.horizontal, 5)
                        
                        CustomTextField(placeholder: defaults?.email ?? "", text: $email)
                            .disabled(true)
                        
                        CustomTextField(placeholder: Texts.heightInInch.description, text: $height)
                            .keyboardType(.numbersAndPunctuation)
                            .submitLabel(.next)
                            .focused($focusedField, equals: .height)
                            .limitInputLength(value: $height, length: 5)
                            .onSubmit {
                                focusedField = .weight
                            }
                        
                        CustomTextField(placeholder: Texts.weightInKG.description, text: $weight)
                            .keyboardType(.numberPad)
                            .limitInputLength(value: $weight, length: 3)
                            .focused($focusedField, equals: .weight)
                        
                        HStack(spacing: 15) {
                            CustomTextField(placeholder: Texts.age.description, text: $age)
                                .limitInputLength(value: $age, length: 3) // Age can be 3 digits (100+)
                                .focused($focusedField, equals: .age)
                                .keyboardType(.numberPad)
                                .frame(maxWidth: .infinity)
                            
                            Spacer()
                            
                            Picker("Select your blood group", selection: $selectedBloodGroup) {
                                ForEach(bloodGroups, id: \.self) { group in
                                    Text(group)
                                }
                            }
                            .frame(width: 140)
                            .padding(.trailing, 10)
                        }
                        .padding(.horizontal, 5)
                        
                        iPhoneNumberField("(000) 000-0000", text: $phoneNumber, isEditing: $isEditing, formatted: true)
                            .flagHidden(false)
                            .flagSelectable(true)
                            .font(UIFont(size: 18, weight: .medium, design: .rounded))
                            .maximumDigits(10)
                            .clearButtonMode(.whileEditing)
                            .onClear { _ in isEditing.toggle() }
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.lightGray, lineWidth: 2)
                            )
                            .padding(.horizontal)
                        
                        if defaults?.role == "doctor" {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Professional Information")
                                    .font(.customFont(style: .bold, size: .h16))
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                                
                                CustomTextField(placeholder: "Hospital Name", text: $hospitalName)
                                CustomTextField(placeholder: "Specialty (e.g. Cardiologist)", text: $specialty)
                                
                                HStack(spacing: 15) {
                                    CustomTextField(placeholder: "Experience (Years)", text: $experienceYears)
                                        .keyboardType(.numberPad)
                                    CustomTextField(placeholder: "License Number", text: $licenseNumber)
                                        .disabled(true) // Usually fixed
                                }
                                .padding(.horizontal, 5)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("About Me")
                                        .font(.customFont(style: .medium, size: .h14))
                                        .padding(.horizontal, 25)
                                    
                                    TextEditor(text: $aboutMe)
                                        .frame(height: 100)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.lightGray, lineWidth: 2)
                                        )
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 600 : .infinity)
                    
                    Spacer()
                    
                    Button {
                        Task {
                            await uploadDetails()
                        }
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 10)
                                Text("Updating...")
                            } else {
                                Label(Texts.updateProfile.description, systemImage: "person.crop.circle.fill.badge.plus")
                            }
                        }
                        .font(.customFont(style: .bold, size: .h17))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                        .background(disableForm || isSaving || isUploadingImage ? Color.gray.opacity(0.3) : Color.appBlue)
                        .cornerRadius(30)
                    }
                    .disabled(disableForm || isSaving || isUploadingImage)
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .onAppear {
                    firstName = defaults?.firstName ?? ""
                    lastName = defaults?.lastName ?? ""
                    email = defaults?.email ?? ""
                    height = defaults?.height ?? ""
                    weight = defaults?.weight ?? ""
                    age = defaults?.age ?? ""
                    imageURL = defaults?.imageURL ?? ""
                    selectedBloodGroup = defaults?.bloodGroup ?? "Blood Group"
                    phoneNumber = defaults?.phoneNumber ?? ""
                    
                    // Populate Doctor Fields
                    hospitalName = defaults?.hospitalName ?? ""
                    specialty = defaults?.specialty ?? ""
                    experienceYears = defaults?.experienceYears ?? ""
                    aboutMe = defaults?.aboutMe ?? ""
                    licenseNumber = defaults?.licenseNumber ?? ""
                }
                .padding()
                .onTapGesture {
                    self.hideKeyboard()
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: avatarItem) {
            Task {
                if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
                    selectedPhotoData = data
                    if let selectedPhotoData,
                       let image = UIImage(data: selectedPhotoData) {
                        isUploadingImage = true
                        ImageUploader.uploadImage(image: image) { response in
                            imageURL = response
                            isUploadingImage = false
                            print("Image URL= \(imageURL)")
                        }
                    }
                }
                if let loaded = try? await avatarItem?.loadTransferable(type: Image.self) {
                    avatarImage = loaded
                } else {
                    print("Failed to pick image")
                }
            }
        }
    }
    func hideKeyboard() {
       UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
   }
    func uploadDetails() async {
        let appuser = AppUser(password: defaults?.password ?? "",
                           email: email,
                           firstName: firstName,
                           lastName: lastName,
                           createdAt: Date(),
                           height: height,
                           weight: weight,
                           age: age,
                           bloodGroup: selectedBloodGroup,
                           phoneNumber: phoneNumber,
                           imageURL: imageURL,
                           hospitalName: hospitalName,
                           experienceYears: experienceYears,
                           specialty: specialty,
                           licenseNumber: licenseNumber,
                           aboutMe: aboutMe)

        debugPrint("Updating user profile == \(String(describing: appuser))")
        isSaving = true
        
        // Get user ID safely
        var userId = UserDefaults.standard.string(forKey: "userID")
        if userId == nil {
            if let session = try? await SupabaseManager.shared.client.auth.session {
                userId = session.user.id.uuidString
            }
        }
        
        if let finalUserId = userId {
            // Save to Supabase using the bridge FireStoreManager
            // Using a continuation to await the completion handler
            let success: Bool = await withCheckedContinuation { continuation in
                Task {
                    await SupabaseDBManager.shared.updateUserDetails(
                        finalUserId,
                        dataModel: appuser
                    ) { result in
                        continuation.resume(returning: result)
                    }
                }
            }
            
            if success {
                print("User details saved successfully in Supabase.")
                // Refresh local state before dismissing
                defaults = appuser
                isSaving = false
                dismiss()
            } else {
                print("Failed to save user details.")
                isSaving = false
            }
        } else {
            print("No authenticated user session found.")
            isSaving = false
        }
    }
}

#Preview {
    AddFamilyMemberView()
}
