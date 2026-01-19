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
    @Environment(\.presentationMode) var presentationMode
    var bloodGroups = ["Blood Group", "O+", "O-", "A+", "A-", "B+", "B-", "AB+", "AB-"]
    @State private var selectedBloodGroup : String = "Blood Group"
    @FocusState private var focusedField: Field?
    @State var isEditing: Bool = false
    @State private var selectedPhotoData: Data?
    @State var imageURL: String = ""
    @StateObject private var userViewModel = UserViewModel()


    var disableForm: Bool {
        firstName.count < 4 || lastName.count < 1 || height.count < 1 || weight.count < 1 || age.count < 1
        || phoneNumber.count < 9
    }

    var body: some View {
        NavigationStack {
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
                                        if defaults?.imageURL == "" {
                                            Image("user")
                                                .resizable()
                                                .frame(width: 120, height: 120)
                                                .clipShape(Circle())
                                        } else {
                                            ProgressView()
                                        }
                                    })
                            }
                            
                            Text("Change Photo")
                                .font(.customFont(style: .bold, size: .h14))
                                .foregroundColor(.appBlue)
                        }
                    }
                    .padding(.vertical, 20)

                    VStack(spacing: 20) {
                        HStack(spacing: -15) {
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
                        
                        HStack(spacing: -15) {
                            CustomTextField(placeholder: Texts.age.description, text: $age)
                                .limitInputLength(value: $age, length: 2)
                                .focused($focusedField, equals: .age)
                                .keyboardType(.numberPad)
                            Spacer()
                            Picker("Select your blood group", selection: $selectedBloodGroup) {
                                ForEach(bloodGroups, id: \.self) { group in
                                    Text(group)
                                }
                            }
                            .frame(width: 150)
                            .padding(.trailing)
                        }
                        
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
                    }
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 600 : .infinity)
                    
                    Spacer()
                    
                    Button {
                        Task {
                            await uploadDetails()
                        }
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label(Texts.updateProfile.description, systemImage: "person.crop.circle.fill.badge.plus")
                            .font(.customFont(style: .bold, size: .h17))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 450 : .infinity)
                            .background(disableForm ? Color.gray.opacity(0.3) : Color.appBlue)
                            .cornerRadius(30)
                    }
                    .disabled(disableForm)
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
                }
                .padding()
                .onTapGesture {
                    self.hideKeyboard()
                }
            }
            .navigationTitle(Texts.updateProfile.description)
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: avatarItem) {
                Task {
                    if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
                        selectedPhotoData = data
                        if let selectedPhotoData,
                           let image = UIImage(data: selectedPhotoData) {
                            ImageUploader.uploadImage(image: image) { response in
                                imageURL = response
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
                           imageURL: imageURL)

        debugPrint("Updating user profile == \(String(describing: appuser))")
        Task {
            // Get user ID safely
            var userId = UserDefaults.standard.string(forKey: "userID")
            if userId == nil {
                if let session = try? await SupabaseManager.shared.client.auth.session {
                    userId = session.user.id.uuidString
                }
            }
            
            if let finalUserId = userId {
                // Save to Supabase using the bridge FireStoreManager
                await SupabaseDBManager.shared.updateUserDetails(
                    finalUserId,
                    dataModel: appuser
                ) { success in
                    if success {
                        print("User details saved successfully in Supabase.")
                    }
                }
            } else {
                print("No authenticated user session found.")
            }
        }
    }
}

#Preview {
    AddFamilyMemberView()
}
