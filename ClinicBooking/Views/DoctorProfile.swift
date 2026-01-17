//
//  DoctorProfile.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 02/09/24.
//

import SwiftUI

struct DoctorProfile: View {
    var doctorDetail: Doctor?
    @State private var selectedDate = Date()
    @State private var timeSessions = ["Morning", "Afternoon", "Evening", "Night"]
    @State private var selectedTimeSession = "Morning"
    @State var selectedTimeState: String?
    @State private var showBookingFlow = false
    var morningTimes = ["08-09 AM", "09-10 AM", "10-11 AM", "11-12 AM"]
    var noonTimes = ["12-01 PM", "01-02 PM", "02-03 PM", "03-04 PM"]
    var eveningTimes = ["04-05 PM", "05-06 PM", "06-07 PM", "07-08 PM"]
    var nightTimes = ["08-09 PM", "09-10 PM", "10-11 PM", "11-12 PM"]
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    headerView
                        .padding(.top, 15)
                    appointmentView
                }
                .padding(.bottom, 40)
                .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 850 : .infinity)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle(Texts.docProfile.description)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.bg)
        }
    }

    var headerView: some View {
        VStack {
            HStack {
                ImageCircle(icon: doctorDetail?.image ?? "user", radius: 50, circleColor: Color.doctorBG)
                VStack(alignment: .leading, spacing: 10) {
                    Text(doctorDetail?.name ?? "")
                        .font(.customFont(style: .bold, size: .h16))
                    Text(doctorDetail?.specialist ?? "")
                        .font(.customFont(style: .medium, size: .h15))
                        .foregroundColor(.gray)
                    HStack {
                        Image("star").resizable()
                            .frame(width: 15, height: 15)
                        Text(doctorDetail?.rating ?? "")
                            .font(.customFont(style: .medium, size: .h15))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 10)
                }
                Spacer()
            }
            .padding(.horizontal)
            VStack (alignment: .leading, spacing: 15) {
                Text(Texts.docBiography.description)
                    .font(.customFont(style: .bold, size: .h15))
                    .multilineTextAlignment(.leading)
                Text(doctorDetail?.about ?? "")
                    .font(.customFont(style: .medium, size: .h15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity)
            .padding()
            Spacer()
        }
    }

    var appointmentView: some View {
        VStack(alignment: .leading) {
            Text(Texts.schedules.description)
                .font(.customFont(style: .bold, size: .h15))
                .multilineTextAlignment(.leading)
            HStack {
                DatePicker("Date", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                    .font(.customFont(style: .medium, size: .h15))
            }
            .padding(.top, 15)
            Text(Texts.chooseTimes.description)
                .font(.customFont(style: .bold, size: .h15))
                .multilineTextAlignment(.leading)
                .padding(.top, 15)
            Picker("Choose Time", selection: $selectedTimeSession) {
                ForEach(timeSessions, id: \.self) { selected in
                    VStack {
                        Text(selected)
                    }
                }
            }
            .pickerStyle(.segmented)
            .background(Color.appBlue.opacity(0.2))
            .frame(maxHeight: 60)
            .padding(.bottom, 10)

            switch selectedTimeSession {
            case TimeSessions.morning.rawValue:
                timeSessionView(morningTimes, TimeSessions.morning.rawValue)
            case TimeSessions.noon.rawValue:
                timeSessionView(noonTimes, TimeSessions.noon.rawValue)
            case TimeSessions.evening.rawValue:
                timeSessionView(eveningTimes, TimeSessions.evening.rawValue)
            case TimeSessions.night.rawValue:
                timeSessionView(nightTimes, TimeSessions.night.rawValue)
            default:
                timeSessionView(morningTimes, TimeSessions.morning.rawValue)
            }

            Button{
                if selectedTimeState != nil {
                    self.showBookingFlow = true
                } else {
                    // Show alert or handle no time selected
                    print("Please select a time")
                }
            } label: {
                Text(Texts.bookAppointment.description)
                    .font(.customFont(style: .bold, size: .h17))
            }
            .buttonStyle(BlueButtonStyle(height: 60, color: .appBlue))
            .padding(.top, 15)
            .navigationDestination(isPresented: $showBookingFlow) {
                if let doctor = doctorDetail, let time = selectedTimeState {
                    PatientSelectionView(doctor: doctor, date: selectedDate, time: time)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    private func timeSessionView(_ timeSession: [String],_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("\(title) Schedule")
                .font(.customFont(style: .medium, size: .h15))
            HStack(spacing: 10) {
                ForEach(0..<timeSession.count, id: \.self) { attribute in
                    Button {
                        self.selectedTimeState = timeSession[attribute]
                        print("Attr pressed")
                    } label: {
                        Text(timeSession[attribute])
                            .foregroundColor(self.selectedTimeState == timeSession[attribute] ? Color.white : Color.black)
                            .font(.customFont(style: .medium, size: .h12))
                            .padding(10)
                    }
                    .background(self.selectedTimeState == timeSession[attribute] ? Color.appBlue : Color.white)
                    .cornerRadius(10)

                }
            }
        }
        .padding(.top, 10)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 120)
        .padding(.horizontal)
        .background(Color.appBlue.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

enum TimeSessions: String {
    case morning = "Morning"
    case noon = "Afternoon"
    case evening = "Evening"
    case night = "Night"
}

#Preview {
    DoctorProfile()
}
//
//  PatientSelectionView.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI

struct PatientSelectionView: View {
    @Environment(\.dismiss) var dismiss
    var doctor: Doctor
    var date: Date
    var time: String
    
    @State private var familyMembers: [MemberModel] = []
    @State private var selectedPatientId: String = "myself" // "myself" or member ID
    @State private var isLoading = false
    @State private var isBooking = false
    @State private var navigateToConfirmation = false
    @State private var errorMessage: String?
    
    // User defaults for basic user info
    let currentUser = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Who is this appointment for?")
                .font(.customFont(style: .bold, size: .h20))
                .padding(.top)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView {
                    VStack(spacing: 15) {
                        // Option 1: Myself
                        patientOptionCard(
                            id: "myself",
                            name: "\(currentUser?.firstName ?? "Me") \(currentUser?.lastName ?? "")",
                            relation: "Self",
                            isSelected: selectedPatientId == "myself"
                        )
                        
                        // Option 2: Family Members
                        ForEach(familyMembers, id: \.id) { member in
                            patientOptionCard(
                                id: member.id ?? UUID().uuidString,
                                name: member.name,
                                relation: member.relation,
                                isSelected: selectedPatientId == (member.id ?? "")
                            )
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            
            Spacer()
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button {
                preparePayment()
            } label: {
                 Text("Proceed to Payment")
                     .font(.customFont(style: .bold, size: .h17))
                     .foregroundColor(.white)
                     .padding()
                     .frame(maxWidth: .infinity)
                     .background(Color.appBlue)
                     .cornerRadius(15)
            }
        }
        .padding()
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 600 : .infinity)
        .frame(maxWidth: .infinity)
        .navigationTitle("Select Patient")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchFamilyMembers()
        }
        .navigationDestination(isPresented: $navigateToConfirmation) {
            PaymentMethodView(
                doctor: doctor,
                date: date,
                time: time,
                patientName: getPatientName(),
                patientId: selectedPatientId
            )
        }
    }

    func getPatientName() -> String {
         if selectedPatientId == "myself" {
             return "\(currentUser?.firstName ?? "Me") \(currentUser?.lastName ?? "")"
         } else {
             return familyMembers.first(where: { $0.id == selectedPatientId })?.name ?? "Family Member"
         }
    }
    
    func preparePayment() {
         self.navigateToConfirmation = true
    }
    
    // ... helper views ...
    
    func patientOptionCard(id: String, name: String, relation: String, isSelected: Bool) -> some View {
        HStack {
            Image(systemName: relation == "Self" ? "person.fill" : "person.2.fill")
                .foregroundColor(isSelected ? .white : .appBlue)
                .padding(10)
                .background(isSelected ? Color.white.opacity(0.3) : Color.appBlue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .black)
                Text(relation)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(isSelected ? Color.appBlue : Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            withAnimation {
                self.selectedPatientId = id
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.appBlue, lineWidth: isSelected ? 0 : 1)
        )
    }
    
    func fetchFamilyMembers() {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else { return }
        self.isLoading = true
        Task {
            await FireStoreManager.shared.getFamilyMembers(userId: userId) { success, model in
                self.isLoading = false
                if success {
                    self.familyMembers = model.members
                }
            }
        }
    }
    
    // confirmBooking removed in favor of PaymentMethodView logic
}
//
//  BookingConfirmationView.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI

struct BookingConfirmationView: View {
    var doctor: Doctor
    var date: Date
    var time: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            
            Text("Appointment Confirmed!")
                .font(.customFont(style: .bold, size: .h24))
            
            Text("You have successfully booked an appointment with")
                .font(.customFont(style: .medium, size: .h15))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            VStack(spacing: 15) {
                HStack {
                    Image(doctor.image) // Falling back to asset name if URL fails, ideally AsyncImage
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(doctor.name)
                            .font(.headline)
                        Text(doctor.specialist)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.lightGray.opacity(0.3))
                .cornerRadius(12)
                
                HStack {
                    Image(systemName: "calendar")
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                    Spacer()
                    Image(systemName: "clock")
                    Text(time)
                }
                .padding()
                .background(Color.lightGray.opacity(0.3))
                .cornerRadius(12)
            }
            .padding()
            
            Spacer()
            
            NavigationLink(destination: HomeDashboard().navigationBarBackButtonHidden(true)) {
                Text("Back to Home")
                    .font(.customFont(style: .bold, size: .h17))
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.appBlue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}
// MARK: - Payment & Success Views

struct PaymentMethodView: View {
    var doctor: Doctor
    var date: Date
    var time: String
    var patientName: String
    var patientId: String
    
    @State private var selectedMethod = "Credit Card"
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    
    let paymentMethods = ["Credit Card", "Apple Pay", "PayPal"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Payment Method")
                .font(.customFont(style: .bold, size: .h20))
                .padding(.top)
            
            // Order Summary
            VStack(alignment: .leading, spacing: 10) {
                Text("Order Summary")
                    .font(.headline)
                HStack {
                    Text("Consultation Fee")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("$50.00") // Fixed price for now
                        .bold()
                }
                Divider()
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text("$50.00")
                        .font(.headline)
                        .foregroundColor(.appBlue)
                }
            }
            .padding()
            .background(Color.lightGray.opacity(0.3))
            .cornerRadius(12)
            
            Text("Select Payment Method")
                .font(.headline)
                .padding(.top)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(paymentMethods, id: \.self) { method in
                        HStack {
                            Image(systemName: methodIcon(method))
                                .foregroundColor(.appBlue)
                                .frame(width: 30)
                            Text(method)
                                .font(.customFont(style: .medium, size: .h16))
                            Spacer()
                            if selectedMethod == method {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.appBlue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .onTapGesture {
                            selectedMethod = method
                        }
                    }
                }
                .padding(.vertical, 5)
            }
            
            Spacer()
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button {
                processPaymentAndBook()
            } label: {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Pay & Confirm")
                        .font(.customFont(style: .bold, size: .h17))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isLoading ? Color.gray.opacity(0.3) : Color.appBlue)
                        .cornerRadius(15)
                }
            }
            .disabled(isLoading)
        }
        .padding()
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 600 : .infinity)
        .frame(maxWidth: .infinity)
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func methodIcon(_ method: String) -> String {
        switch method {
        case "Credit Card": return "creditcard.fill"
        case "Apple Pay": return "applelogo"
        case "PayPal": return "dollarsign.circle.fill"
        default: return "creditcard"
        }
    }
    
    func processPaymentAndBook() {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else {
            self.errorMessage = "User ID not found. Please log in again."
            return
        }
        
        isLoading = true
        errorMessage = nil // Clear previous errors
        
        Task {
            // Simulate Payment Delay
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            let appointment = Appointment(
                doctorId: doctor.doctorID,
                userId: userId,
                patientName: patientName,
                doctorName: doctor.name,
                doctorImage: doctor.image,
                doctorSpeciality: doctor.specialist,
                date: date,
                time: time,
                status: "upcoming",
                location: doctor.address,
                createdAt: Date()
            )
            
            do {
                try await FireStoreManager.shared.saveAppointment(appointment: appointment)
                await MainActor.run {
                    self.isLoading = false
                    self.showSuccess = true
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Booking failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
