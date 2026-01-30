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

struct AddFamilyMemberView: View {
    enum Field: Hashable {
        case firstName
        case lastName
        case height
        case weight
        case age
        case phoneNumber
    }
    @State var firstName: String = ""
    @State var lastName: String = ""
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
                Text("Add Family Member")
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
                            if avatarImage == nil {
                                Image("user")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.appBlue.opacity(0.1), lineWidth: 4))
                            } else {
                                avatarImage?
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.appBlue.opacity(0.1), lineWidth: 4))
                            }
                            
                            Text("Select Photo")
                                .font(.customFont(style: .bold, size: .h14))
                                .foregroundColor(.appBlue)
                        }
                    }
                    .padding(.vertical, 20)

                    VStack(spacing: 20) {
                        HStack(spacing: -15) {
                            CustomTextField(placeholder: Texts.firstName.description, text: $firstName)
                                .submitLabel(.next)
                                .focused($focusedField, equals: .firstName)
                                .onSubmit {
                                    focusedField = .lastName
                                }
                            CustomTextField(placeholder: Texts.lastName.description, text: $lastName)
                                .submitLabel(.next)
                                .focused($focusedField, equals: .lastName)
                                .onSubmit {
                                    focusedField = .height
                                }
                        }
                        
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
                        uploadDetails()
                        dismiss()
                    } label: {
                        Label(Texts.addMember.description, systemImage: "person.crop.circle.fill.badge.plus")
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
                .onTapGesture {
                    self.hideKeyboard()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
               await userViewModel.getFamilyMembers()
            }
        }
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
    func hideKeyboard() {
       UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
   }
    func uploadDetails() {

        let model = MemberModel(
            firstName: firstName,
            lastName: lastName,
            height: height,
            weight: weight,
            age: age,
            bloodGroup: selectedBloodGroup,
            phoneNumber: phoneNumber,
            imageURL: imageURL
        )
        if userViewModel.familyMembers == nil {
            userViewModel.familyMembers = FamilyMemberModel(members: [])
        }
        userViewModel.familyMembers?.members.append(model)

        debugPrint("Family Members == \(String(describing: userViewModel.familyMembers))")
        Task {
            let session = try? await SupabaseManager.shared.client.auth.session
            if let userId = UserDefaults.standard.string(forKey: "userID") ?? session?.user.id.uuidString,
               let currentMembers = userViewModel.familyMembers {
                // Save to Supabase using the bridge FireStoreManager
                SupabaseDBManager.shared.updateFamilyMembers(
                    userId,
                    dataModel: currentMembers
                ) { success in
                    if success {
                        print("Family Members details saved successfully in Supabase.")
                    } else {
                        print("Failed to save Family Members details to Supabase.")
                    }
                }
            } else {
                print("No authenticated user session found or family members missing.")
            }
        }
    }
}

#Preview {
    AddFamilyMemberView()
}
