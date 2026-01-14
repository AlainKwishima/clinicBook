//
//  ContentView.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 01/09/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeDashboard: View {
    @State private var selectedIndex: Int = 0
    @State private var isShowServices: Bool = false
    @State private var showDoctorProfile: Bool = false
    @State private var showSearch: Bool = false
    @State private var showNotifications: Bool = false
    @StateObject var viewModel: DoctorsViewModel = DoctorsViewModel()
    @StateObject var clinicsVM = ClinicsViewModel()
    @State var doctors: [Doctor] = []
    @State var doctorDetail : Doctor?
    @State private var selectedSearchCategory: String? = nil
    @State private var showClinicProfile = false
    @State private var selectedClinic: Clinic?
    @State var defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")

    var body: some View {
        tabView
            .onAppear {
                Task {
                    await viewModel.fetchDoctors()
                    self.doctors = Array(viewModel.doctors.prefix(10))
                    await clinicsVM.fetchClinics()
                }
            }
    }

    var headerView: some View {
        HStack {
            Button(action: {
                // Profile action
            }, label: {
                AsyncImage(
                    url: URL(string: defaults?.imageURL ?? ""),
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 35, maxHeight: 35)
                            .clipShape(Circle())
                    },
                    placeholder: {
                        if defaults?.imageURL == "" {
                            Image("user").resizable()
                                .frame(width: 35, height: 35)
                        } else {
                            ProgressView()
                        }
                    })
            })
            VStack(alignment: .leading) {
                Text(Texts.welcomeBack.description)
                    .font(.customFont(style: .medium, size: .h13))
                Text("Mr.\(defaults?.firstName ?? "") \(defaults?.lastName ?? "")!")
                    .font(.customFont(style: .bold, size: .h15))
            }
            Spacer()
            Button(action: {
                selectedSearchCategory = nil
                showSearch = true
            }, label: {
                Image(systemName: "magnifyingglass.circle")
                    .font(.customFont(style: .medium, size: .h24))
                    .foregroundColor(Color.appBlue)
            })
            Button(action: {
                showNotifications = true
            }, label: {
                Image(systemName: "bell.circle")
                    .font(.customFont(style: .medium, size: .h24))
                    .foregroundColor(Color.appBlue)
            })
            .navigationDestination(isPresented: $showNotifications) {
                NotificationCenterView()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .padding(.horizontal)
    }

    var tabView: some View {
        TabView(selection: $selectedIndex) {
            NavigationStack() {
                homeContent
                    .navigationDestination(isPresented: $showDoctorProfile, destination: { DoctorProfile(doctorDetail: doctorDetail) })
                    .navigationDestination(isPresented: $showClinicProfile, destination: { if let clinic = selectedClinic { ClinicProfileView(clinic: clinic) } })
                    .navigationDestination(isPresented: $isShowServices, destination: { ServicesView() })
                    .fullScreenCover(isPresented: $showSearch, onDismiss: { selectedSearchCategory = nil }) {
                        SearchFilterView(initialCategory: selectedSearchCategory)
                    }
            }
            .tabItem {
                Image(systemName: "house.fill")
                    .renderingMode(.template)
            }
            .tag(0)
            NavigationStack {
                AppointmentsView()
                    .navigationTitle("Appointments")
            }
            .tabItem {
                Image(systemName: "calendar")
                    .renderingMode(.template)
            }
            .tag(1)
            NavigationStack {
                MedicalRecordsView()
            }
            .tabItem {
                Image(systemName: "text.book.closed.fill")
                    .renderingMode(.template)
            }
            .tag(2)
            NavigationStack {
                SavedDoctors()
                    .navigationTitle("Saved Doctors")
            }
            .tabItem {
                Image(systemName: "heart")
                    .renderingMode(.template)
            }
            .tag(3)
            NavigationStack() {
                UserProfileView()
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("", systemImage: "person.fill")
            }
            .tag(4)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {

            UITabBar.appearance().backgroundColor = UIColor.systemBackground
        }
        .accentColor(Color.appBlue)
    }

    var homeContent: some View {
        ScrollView(.vertical) {
            headerView
                .padding(.horizontal)
                .padding(.top, 10)
            
            searchHeaderView
                .padding(.vertical, 10)
            
            servicesView
                .padding(.horizontal)
                .padding(.bottom, 15)
            
            clinicsView
                .padding(.horizontal)
                .padding(.bottom, 15)
            
            popularDoctorsView
                .padding(.horizontal)
        }
    }

    var searchHeaderView: some View {
        ZStack {
            Spacer()
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.appBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .padding(.horizontal)
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text(Texts.lookingForDoctors.description)
                        .font(.customFont(style: .bold, size: .h18))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button {
                        showSearch = true
                    } label: {
                        Text(Texts.searchFor.description)
                            .font(.customFont(style: .bold, size: .h14))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(.leading, 30)
                
                Spacer()
                
                Image("home-doctor")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140)
                    .padding(.trailing, 20)
                    .offset(y: 5)
            }
            .padding(.horizontal)
        }
    }

    var servicesView: some View {
        VStack {
            HStack {
                Text(Texts.findYourDoctor.description)
                    .font(.customFont(style: .bold, size: .h18))
                Spacer()
                Button {
                    isShowServices = true
                } label: {
                    Text(Texts.seeAll.description)
                        .font(.customFont(style: .medium, size: .h15))
                }
            }
            Spacer()
                .padding(.top, 10)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30) {
                    ForEach(0..<AppConstants.specializations.count, id: \.self) { index in
                        let category = AppConstants.specializations[index]
                        Button {
                            selectedSearchCategory = category.0
                            showSearch = true
                        } label: {
                            ServicesCardView(
                                image: category.1,
                                title: category.0,
                                isSymbol: category.2
                            )
                        }
                    }
                }
            }
        }
    }

    var clinicsView: some View {
        VStack {
            HStack {
                Text("Clinics & Hospitals")
                    .font(.customFont(style: .bold, size: .h18))
                Spacer()
                Button {
                    // isShowClinics = true
                } label: {
                    Text(Texts.seeAll.description)
                        .font(.customFont(style: .medium, size: .h15))
                }
            }
            Spacer()
                .padding(.top, 10)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(clinicsVM.clinics) { clinic in
                        Button {
                            selectedClinic = clinic
                            showClinicProfile = true
                        } label: {
                            ClinicCardView(clinic: clinic)
                        }
                    }
                }
            }
        }
    }

    var popularDoctorsView: some View {
        VStack {
            HStack {
                Text(Texts.popularDoctors.description)
                    .font(.customFont(style: .bold, size: .h18))
                Spacer()
                Button {

                } label: {
                    Text(Texts.seeAll.description)
                        .font(.customFont(style: .medium, size: .h15))
                }
            }
            Spacer()
                .padding(.top, 10)
//            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ForEach(0..<doctors.count, id: \.self) { index in
                        DoctorsCardView(
                            id: doctors[index].doctorID,
                            name: doctors[index].name,
                            speciality: doctors[index].specialist,
                            rating: doctors[index].rating,
                            fee: "$50.99", 
                            image: doctors[index].image,
                            btnAction: {
                                showDoctorProfile = true
                                self.doctorDetail = doctors[index]
                            }
                        )
                        .onTapGesture {
                            showDoctorProfile =  true
                            self.doctorDetail = doctors[index]
                        }
                    }
//                }
            }
//            NavigationLink(destination: DoctorProfile(), isActive: $showDoctorProfile) { EmptyView() }
        }
    }
} // End HomeDashboard

#Preview {
    HomeDashboard()
}
//
//  SearchFilterView.swift
//  ClinicBooking
//

struct SearchFilterView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = DoctorsViewModel()
    @StateObject var clinicsVM = ClinicsViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var showFilters = false
    @State private var showDoctorProfile = false
    @State private var selectedDoctor: Doctor?
    @State private var showClinicProfileFromSearch = false
    @State private var selectedClinicForSearch: Clinic?
    var initialCategory: String? = nil
    
    init(initialCategory: String? = nil) {
        self.initialCategory = initialCategory
    }
    
    // Grid layout for categories
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var selectedSearchMode = 0 // 0: Doctors, 1: Hospitals
    
    let categories = AppConstants.specializations
    
    var filteredDoctors: [Doctor] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        return viewModel.doctors.filter { doctor in
            let matchesName = query.isEmpty || doctor.name.localizedCaseInsensitiveContains(query)
            let matchesSpecialty = query.isEmpty || doctor.specialist.localizedCaseInsensitiveContains(query)
            
            // For category selection, we use exact match or contains
            let matchesCategory = selectedCategory == nil || doctor.specialist.localizedCaseInsensitiveContains(selectedCategory!)
            
            return (matchesName || matchesSpecialty) && matchesCategory
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search doctors, specialties...", text: $searchText)
                    }
                    .padding()
                    .background(Color.lightGray.opacity(0.3))
                    .cornerRadius(12)
                    
                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .padding()
                            .background(Color.appBlue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
                
                Picker("Search Mode", selection: $selectedSearchMode) {
                    Text("Doctors").tag(0)
                    Text("Facilities").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if searchText.isEmpty && selectedCategory == nil {
                    // Show Categories
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text("Categories")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(categories, id: \.0) { category in
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.blue.opacity(0.1))
                                                .frame(width: 80, height: 80)
                                            
                                            if category.2 { // isSymbol
                                                Image(systemName: category.1)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(.appBlue)
                                            } else {
                                                Image(category.1)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 45, height: 45)
                                            }
                                        }
                                        
                                        Text(category.0)
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.black)
                                    }
                                    .onTapGesture {
                                        selectedCategory = category.0
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                } else {
                    // Show Results
                    ScrollView {
                        VStack(spacing: 15) {
                            if selectedSearchMode == 0 {
                                // Selected Category Chip
                                if selectedCategory != nil {
                                    HStack {
                                        Text("Category: \(selectedCategory!)")
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.appBlue.opacity(0.2))
                                            .cornerRadius(8)
                                        Button("Clear") {
                                            selectedCategory = nil
                                        }
                                        .font(.caption)
                                    }
                                    .padding(.leading)
                                }
                                
                                // Doctor Results
                                if viewModel.isLoading {
                                    ProgressView()
                                        .padding(.top, 50)
                                } else if filteredDoctors.isEmpty {
                                    VStack(spacing: 15) {
                                        Image(systemName: "person.crop.circle.badge.xmark")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray)
                                        Text("No doctors found")
                                            .font(.headline)
                                        Text("Try adjusting your search or pull down to refresh")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 50)
                                } else {
                                    ForEach(filteredDoctors) { doctor in
                                        Button {
                                            selectedDoctor = doctor
                                            showDoctorProfile = true
                                        } label: {
                                            DoctorRowView(doctor: doctor)
                                        }
                                    }
                                }
                            } else {
                                // Clinic Results
                                ForEach(clinicsVM.clinics) { clinic in
                                    Button {
                                        selectedClinicForSearch = clinic
                                        showClinicProfileFromSearch = true
                                    } label: {
                                        ClinicRowView(clinic: clinic)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.fetchDoctors()
                    }
                }
            }
            .navigationTitle(selectedSearchMode == 0 ? "Find Doctor" : "Find Facility")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showDoctorProfile) {
                if let doctor = selectedDoctor {
                    DoctorProfile(doctorDetail: doctor)
                }
            }
            .fullScreenCover(isPresented: $showClinicProfileFromSearch) {
                if let clinic = selectedClinicForSearch {
                    ClinicProfileView(clinic: clinic)
                }
            }
            .onAppear {
                if let initial = initialCategory {
                    selectedCategory = initial
                }
                Task {
                    await viewModel.fetchDoctors()
                }
            }
        }
    }
}

struct DoctorRowView: View {
    let doctor: Doctor
    
    var body: some View {
        NavigationLink(destination: DoctorProfile(doctorDetail: doctor)) {
            HStack {
                if doctor.image.hasPrefix("http") {
                    AsyncImage(url: URL(string: doctor.image)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                            .frame(width: 60, height: 60)
                    }
                } else {
                    Image(doctor.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(doctor.name)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(doctor.specialist)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(doctor.rating)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Text(doctor.fee != nil ? "$\(String(format: "%.2f", doctor.fee!))" : "N/A")
                    .font(.headline)
                    .foregroundColor(.appBlue)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.bottom, 8)
        }
    }
}

struct ClinicRowView: View {
    let clinic: Clinic
    
    var body: some View {
        HStack {
            if clinic.image.hasPrefix("http") {
                AsyncImage(url: URL(string: clinic.image)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } placeholder: {
                    ProgressView()
                        .frame(width: 60, height: 60)
                }
            } else {
                Image(clinic.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(clinic.name)
                    .font(.customFont(style: .bold, size: .h15))
                    .foregroundColor(.black)
                Text(clinic.type)
                    .font(.customFont(style: .medium, size: .h13))
                    .foregroundColor(.gray)
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(clinic.address)
                }
                .font(.customFont(style: .medium, size: .h12))
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Text(clinic.rating)
                    .font(.customFont(style: .bold, size: .h13))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.bottom, 8)
    }
}

//
//  NotificationCenterView.swift
//  ClinicBooking
//

struct NotificationCenterView: View {
    // Mock notifications for now, as backend doesn't support them yet
    let notifications = [
        NotificationItem(title: "Appointment Confirmed", message: "Your appointment with Dr. Edwin is confirmed for tomorrow.", time: "2 hours ago", isRead: false),
        NotificationItem(title: "Welcome!", message: "Thanks for joining ClinicBooking.", time: "1 day ago", isRead: true),
        NotificationItem(title: "Profile Updated", message: "Your health details have been successfully updated.", time: "2 days ago", isRead: true)
    ]
    
    var body: some View {
        NavigationStack {
            List(notifications) { notification in
                HStack(alignment: .top) {
                    Circle()
                        .fill(notification.isRead ? Color.gray.opacity(0.3) : Color.appBlue)
                        .frame(width: 10, height: 10)
                        .padding(.top, 5)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(notification.title)
                            .font(.headline)
                        Text(notification.message)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(notification.time)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 8)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Notifications")
        }
    }
}

struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let time: String
    let isRead: Bool
}

#Preview {
    NotificationCenterView()
}
// MARK: - Doctor Module Views

struct DoctorHomeDashboard: View {
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            NavigationStack {
                DoctorHomeTab()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            NavigationStack {
                DoctorAppointmentsView()
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Appointments")
            }
            .tag(1)
            
            NavigationStack {
                PatientHistoryView()
            }
            .tabItem {
                Image(systemName: "clock.arrow.circlepath")
                Text("History")
            }
            .tag(2)
            
            NavigationStack {
                DoctorProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(3)
        }
        .accentColor(.appBlue)
        .navigationBarBackButtonHidden(true)
    }
}

struct DoctorHomeTab: View {
    @State var defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
    @State var todayAppointments: [Appointment] = []
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            headerView
            
            if defaults?.verificationStatus == "pending" {
                VStack(spacing: 15) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.appBlue.opacity(0.7))
                    Text("Account Under Review")
                        .font(.title3)
                        .bold()
                    Text("Your account is currently pending verification. You cannot receive appointments or view patient data until your license has been verified by our team.")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                .padding(.top, 50)
            } else {
                // Stats Overview - AppBlue variants
                HStack(spacing: 12) {
                    StatCard(title: "Pending", count: "3", color: .appBlue.opacity(0.9), icon: "clock.arrow.circlepath")
                    StatCard(title: "Confirmed", count: "8", color: .appBlue.opacity(0.7), icon: "checkmark.seal")
                    StatCard(title: "Completed", count: "12", color: .appBlue.opacity(0.5), icon: "checkmark.circle")
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Quick Insights Panel
                quickInsightsView
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                
                // Today's Schedule
                VStack(alignment: .leading, spacing: 15) {
                    Text("Today's Schedule")
                        .font(.customFont(style: .bold, size: .h18))
                        .padding(.horizontal)
                    
                    if todayAppointments.isEmpty {
                        // Premium empty state
                        VStack(spacing: 15) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 50))
                                .foregroundColor(.appBlue.opacity(0.4))
                            Text("No appointments for today")
                                .font(.customFont(style: .bold, size: .h16))
                                .foregroundColor(.black)
                            Text("Enjoy your free time or catch up on patient notes")
                                .font(.customFont(style: .medium, size: .h14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(Color.appBlue.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else {
                        ForEach(todayAppointments) { appointment in
                            UpcomingAppointmentCardView(
                                address: "",
                                date: appointment.time,
                                time: appointment.time,
                                name: appointment.doctorName,
                                speciality: "General Checkup",
                                image: "user"
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    var headerView: some View {
        HStack {
            AsyncImage(
                url: URL(string: defaults?.imageURL ?? ""),
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.appBlue.opacity(0.3), lineWidth: 2)
                        )
                },
                placeholder: {
                    if defaults?.imageURL == "" {
                        Image("user").resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        ProgressView()
                    }
                })
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello Dr. \(defaults?.lastName ?? "")")
                    .font(.customFont(style: .bold, size: .h17))
                    .foregroundColor(.black)
                Text("Have a great day at work!")
                    .font(.customFont(style: .medium, size: .h13))
                    .foregroundColor(.gray)
            }
            Spacer()
            
            Button(action: {
                // Notification action
            }, label: {
                Image(systemName: "bell.badge")
                    .font(.system(size: 24))
                    .foregroundColor(Color.appBlue)
            })
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.appBlue.opacity(0.08), Color.appBlue.opacity(0.02)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    var quickInsightsView: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.white.opacity(0.9))
                    Text("This Week")
                        .font(.customFont(style: .medium, size: .h14))
                        .foregroundColor(.white.opacity(0.9))
                }
                Text("23")
                    .font(.customFont(style: .bold, size: .h24))
                    .foregroundColor(.white)
                Text("Total Appointments")
                    .font(.customFont(style: .medium, size: .h12))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .frame(height: 60)
                .background(Color.white.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.2")
                        .foregroundColor(.white.opacity(0.9))
                    Text("Patients")
                        .font(.customFont(style: .medium, size: .h14))
                        .foregroundColor(.white.opacity(0.9))
                }
                Text("18")
                    .font(.customFont(style: .bold, size: .h24))
                    .foregroundColor(.white)
                Text("Seen This Week")
                    .font(.customFont(style: .medium, size: .h12))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.appBlue, Color.appBlue.opacity(0.85)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .shadow(color: Color.appBlue.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct StatCard: View {
    let title: String
    let count: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.9))
            Text(count)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(color)
        .cornerRadius(15)
        .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

struct DoctorAppointmentsView: View {
    @State private var upcomingAppointments: [Appointment] = []
    @State private var pastAppointments: [Appointment] = []
    @State private var isLoading = false
    @State var defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if defaults?.verificationStatus == "pending" {
                    VStack(spacing: 15) {
                        Spacer()
                        Image(systemName: "lock.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        Text("Appointments Locked")
                            .font(.title2)
                            .bold()
                        Text("You must be verified to accept appointments.")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if upcomingAppointments.isEmpty && pastAppointments.isEmpty {
                    VStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No appointments yet")
                            .font(.headline)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(.vertical) {
                        if !upcomingAppointments.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Upcoming")
                                    .font(.customFont(style: .bold, size: .h16))
                                    .padding(.horizontal, 16)
                                ForEach(upcomingAppointments) { appointment in
                                    UpcomingAppointmentCardView(
                                        address: "",
                                        date: appointment.date.formatted(date: .abbreviated, time: .omitted),
                                        time: appointment.time,
                                        name: "Patient Name",
                                        speciality: "Consultation",
                                        image: "user"
                                    )
                                    .padding([.leading, .trailing], 16)
                                    .padding(.bottom, 10)
                                }
                            }
                            .padding([.top, .bottom], 10)
                        }
                        
                        if !pastAppointments.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Past")
                                    .font(.customFont(style: .bold, size: .h16))
                                    .padding(.horizontal, 16)
                                ForEach(pastAppointments) { appointment in
                                    PastAppointmetsCard(
                                        image: "user",
                                        name: "Patient Name",
                                        speciality: "Checkup",
                                        date: appointment.date.formatted(date: .abbreviated, time: .omitted),
                                        time: appointment.time
                                    )
                                    .padding([.leading, .trailing], 16)
                                    .padding(.bottom, 5)
                                }
                            }
                        }
                        Spacer()
                    }
                    .background(Color.lightGray.opacity(0.7))
                }
            }
            .navigationTitle("My Appointments")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchAppointments()
            }
        }
    }
    
    func fetchAppointments() {
        self.isLoading = false
    }
}

struct PatientHistoryView: View {
    struct PatientRecord: Identifiable {
        let id = UUID()
        let name: String
        let lastVisit: String
        let diagnosis: String
        let image: String
    }
    
    let patients = [
        PatientRecord(name: "John Doe", lastVisit: "Oct 24, 2024", diagnosis: "Flu", image: "user"),
        PatientRecord(name: "Jane Smith", lastVisit: "Oct 20, 2024", diagnosis: "Migraine", image: "user"),
        PatientRecord(name: "Robert Brown", lastVisit: "Sep 15, 2024", diagnosis: "Checkup", image: "user")
    ]
    
    var body: some View {
        NavigationStack {
            List(patients) { patient in
                HStack {
                    Image(patient.image)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(patient.name)
                            .font(.headline)
                        Text("Last Visit: \(patient.lastVisit)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(patient.diagnosis)
                        .font(.subheadline)
                        .foregroundColor(.appBlue)
                        .padding(6)
                        .background(Color.appBlue.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.vertical, 5)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Patient History")
        }
    }
}

// MARK: - Doctor Profile View
struct DoctorProfileView: View {
    @State var defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var showSignoutAlert = false
    @State private var isSyncing = false
    @State private var verificationCode = ""
    @State private var showVerificationAlert = false
    @State private var verificationAlertMessage = ""
    
    var body: some View {
        VStack {
            ScrollView {
                // PROMINENT DEBUG HEADER
                if defaults?.role == "doctor" && defaults?.verificationStatus != "verified" {
                    verifyAccountSection
                }
                
                profileHeaderView
                
                // Professional Details Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Professional Info")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ProfileDetailRow(icon: "cross.case.fill", title: "Hospital", value: defaults?.hospitalName ?? "N/A")
                        Divider()
                        ProfileDetailRow(icon: "star.fill", title: "Specialty", value: defaults?.specialty ?? "N/A")
                        Divider()
                        ProfileDetailRow(icon: "clock.fill", title: "Experience", value: "\(defaults?.experienceYears ?? "0") Years")
                        Divider()
                        ProfileDetailRow(icon: "doc.text.fill", title: "License", value: defaults?.licenseNumber ?? "N/A")
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding()
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                Spacer()
            }
            .navigationTitle("Doctor Profile")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await syncUserData()
            }
        }
        .onAppear {
            Task {
                await syncUserData()
            }
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
    
    var verifyAccountSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                Text("Registry Verification")
                    .font(.customFont(style: .bold, size: .h18))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Your professional profile is currently in 'Registry Pending' mode. To activate your visibility to all patients, please enter your institution's registration key.")
                    .font(.customFont(style: .medium, size: .h14))
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 12) {
                    TextField("", text: $verificationCode, prompt: Text("Enter Registration Key").foregroundColor(.white.opacity(0.6)))
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.characters)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    Button(action: { verifyCode() }) {
                        if isSyncing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .appBlue))
                                .frame(width: 80, height: 50)
                                .background(Color.white)
                                .cornerRadius(12)
                        } else {
                            Text("Activate")
                                .font(.customFont(style: .bold, size: .h14))
                                .foregroundColor(.appBlue)
                                .frame(width: 80, height: 50)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.1), radius: 5)
                        }
                    }
                }
            }
            .padding([.horizontal, .bottom], 20)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.appBlue, Color.appBlue.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .padding()
        .shadow(color: Color.appBlue.opacity(0.3), radius: 10, x: 0, y: 5)
        .alert("Registry Status", isPresented: $showVerificationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(verificationAlertMessage)
        }
    }
    
    private func verifyCode() {
        let masterCode = "CLINIC-2026-OK"
        if verificationCode.uppercased() == masterCode {
            Task {
                guard let userId = Auth.auth().currentUser?.uid else {
                    verificationAlertMessage = "Error: User ID not found."
                    showVerificationAlert = true
                    return
                }
                do {
                    isSyncing = true
                    try await FireStoreManager.shared.updateVerificationStatus(userId: userId, status: "verified")
                    await syncUserData()
                    verificationAlertMessage = "Success! Your doctor profile is now verified and visible to patients."
                    showVerificationAlert = true
                    verificationCode = ""
                } catch {
                    verificationAlertMessage = "Error: \(error.localizedDescription)"
                    showVerificationAlert = true
                }
                isSyncing = false
            }
        } else {
            verificationAlertMessage = "Invalid verification code. Please contact your administrator."
            showVerificationAlert = true
        }
    }
    
    var profileHeaderView: some View {
        VStack {
            ZStack(alignment: .center) {
                Color(Color.appBlue.opacity(0.2))
                VStack(spacing: 15) {
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
                    Text("Dr. \(defaults?.firstName ?? "") \(defaults?.lastName ?? "")")
                        .foregroundColor(.black)
                        .font(.customFont(style: .bold, size: .h17))
                    Text("\(defaults?.email.lowercased() ?? "")")
                        .foregroundColor(.black)
                        .font(.customFont(style: .medium, size: .h15))
                    
                    Button {
                        showSignoutAlert = true
                    } label: {
                        Label("Sign Out", systemImage: "power")
                            .font(.customFont(style: .bold, size: .h14))
                    }
                    .buttonStyle(BorderButtonStyle(borderColor: Color.appBlue, foregroundColor: .black, height: 50, background: .clear))
                    .padding(.horizontal, 50)
                }
                .padding(.vertical, 30)
            }
            .alert("Are you sure you want to sign out?", isPresented: $showSignoutAlert) {
                Button("Sign Out", role: .destructive) {
                    viewModel.signOut()
                    UserDefaults.standard.removeObject(forKey: "userDetails")
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

struct ProfileDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.appBlue)
                .frame(width: 30)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .bold()
        }
        .padding()
    }
}

// MARK: - Medical Records View
struct MedicalRecordsView: View {
    @State private var selectedSegment = 0
    @State private var showUploadSuccess = false
    let segments = ["Prescriptions", "Lab Reports", "Vaccinations"]
    
    var body: some View {
        VStack {
            // Segmented Control
            Picker("Records Type", selection: $selectedSegment) {
                ForEach(0..<segments.count, id: \.self) { index in
                    Text(segments[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Spacer()
            
            // Content
            VStack(spacing: 20) {
                Image(systemName: getIconForSegment(selectedSegment))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray.opacity(0.5))
                
                Text("No \(segments[selectedSegment]) Found")
                    .font(.customFont(style: .bold, size: .h20))
                    .foregroundColor(.gray)
                
                Text(getDescriptionForSegment(selectedSegment))
                    .font(.customFont(style: .medium, size: .h16))
                    .foregroundColor(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    // Upload action simulation
                    showUploadSuccess = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Upload Document")
                    }
                    .font(.customFont(style: .bold, size: .h16))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.appBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .navigationTitle("Medical Records")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Upload Successful", isPresented: $showUploadSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your document has been securely uploaded and added to your records.")
        }
    }
    
    func getIconForSegment(_ index: Int) -> String {
        switch index {
        case 0: return "doc.text"
        case 1: return "flask.fill"
        case 2: return "syringe.fill"
        default: return "doc"
        }
    }
    
    func getDescriptionForSegment(_ index: Int) -> String {
        switch index {
        case 0: return "Your doctor prescriptions will appear here."
        case 1: return "Upload or view your lab test results safely."
        case 2: return "Keep track of your immunization history."
        default: return ""
        }
    }
}

// MARK: - Clinic UI Components

struct ClinicCardView: View {
    let clinic: Clinic
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                if clinic.image.hasPrefix("http") {
                    AsyncImage(url: URL(string: clinic.image)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.1)
                    }
                    .frame(width: 200, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                } else {
                    Image(clinic.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
                Text(clinic.type)
                    .font(.customFont(style: .bold, size: .h11))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appBlue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding(10)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(clinic.name)
                    .font(.customFont(style: .bold, size: .h15))
                    .foregroundColor(.black)
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                    Text(clinic.address)
                        .font(.customFont(style: .medium, size: .h13))
                }
                .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(clinic.rating)
                        .font(.customFont(style: .bold, size: .h13))
                    Spacer()
                    Text("Details")
                        .font(.caption).bold()
                        .foregroundColor(.appBlue)
                }
            }
            .padding(.horizontal, 5)
        }
        .frame(width: 200)
    }
}

struct ClinicProfileView: View {
    let clinic: Clinic
    @Environment(\.dismiss) var dismiss
    @StateObject var doctorsViewModel = DoctorsViewModel()
    @State private var selectedTab = 0
    @State private var showDoctorProfile = false
    @State private var selectedDoctor: Doctor?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Image with Gradient
                    ZStack(alignment: .bottomLeading) {
                        if clinic.image.hasPrefix("http") {
                            AsyncImage(url: URL(string: clinic.image)) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle().fill(Color.gray.opacity(0.1))
                            }
                            .frame(height: 300)
                            .clipped()
                        } else {
                            Image(clinic.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .clipped()
                        }
                        
                        // Bottom Gradient for smooth transition to card
                        LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                            .frame(height: 300)
                    }
                    
                    VStack(alignment: .leading, spacing: 25) {
                        // Title & Rating Card
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(clinic.name)
                                    .font(.customFont(style: .bold, size: .h22))
                                    .foregroundColor(.black)
                                
                                Text(clinic.type)
                                    .font(.customFont(style: .medium, size: .h13))
                                    .foregroundColor(.appBlue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.appBlue.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 5) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(clinic.rating)
                                    .font(.customFont(style: .bold, size: .h15))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: .black.opacity(0.1), radius: 5)
                        }
                        
                        // Premium Tab Picker
                        HStack(spacing: 0) {
                            TabButton(title: "About", isSelected: selectedTab == 0) {
                                withAnimation(.spring()) { selectedTab = 0 }
                            }
                            TabButton(title: "Our Doctors", isSelected: selectedTab == 1) {
                                withAnimation(.spring()) { selectedTab = 1 }
                            }
                        }
                        .padding(5)
                        .background(Color.lightGray.opacity(0.5))
                        .cornerRadius(18)
                        
                        if selectedTab == 0 {
                            AboutSection(clinic: clinic)
                                .transition(.opacity)
                        } else {
                            DoctorsSection(clinic: clinic, viewModel: doctorsViewModel) { doctor in
                                selectedDoctor = doctor
                                showDoctorProfile = true
                            }
                            .transition(.opacity)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 30)
                    .background(Color.white)
                    .cornerRadius(25)
                    .padding(.horizontal, 15)
                    .offset(y: -50)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
                }
            }
            .edgesIgnoringSafeArea(.top)
            
            // Re-positioned Back Button (Safe Area Aware)
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.bold())
                    .padding(12)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .foregroundColor(.black)
                    .shadow(radius: 4)
            }
            .padding(.leading, 40)
            .padding(.top, 70)
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await doctorsViewModel.fetchDoctors()
            }
        }
        .fullScreenCover(isPresented: $showDoctorProfile) {
            if let doctor = selectedDoctor {
                DoctorProfile(doctorDetail: doctor)
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.customFont(style: .bold, size: .h15))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.appBlue : Color.clear)
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AboutSection: View {
    let clinic: Clinic
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Address")
                    .font(.customFont(style: .bold, size: .h18))
                HStack(spacing: 10) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.appBlue)
                        .font(.title3)
                    Text(clinic.address)
                        .font(.customFont(style: .medium, size: .h15))
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("About")
                    .font(.customFont(style: .bold, size: .h18))
                Text(clinic.about)
                    .font(.customFont(style: .medium, size: .h15))
                    .foregroundColor(.gray)
                    .lineSpacing(6)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Available Services")
                    .font(.customFont(style: .bold, size: .h18))
                FlowLayout(items: clinic.services) { service in
                    Text(service)
                        .font(.customFont(style: .bold, size: .h12))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.lightBlue.opacity(0.4))
                        .foregroundColor(.appBlue)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

struct DoctorsSection: View {
    let clinic: Clinic
    @ObservedObject var viewModel: DoctorsViewModel
    let onDoctorSelect: (Doctor) -> Void
    
    var clinicDoctors: [Doctor] {
        viewModel.doctors.filter { doc in
            doc.address.contains(clinic.name) || doc.position.contains(clinic.name) || clinic.doctorIds.contains(doc.doctorID)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Medical Team")
                .font(.customFont(style: .bold, size: .h18))
                .padding(.bottom, 5)
            
            if clinicDoctors.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.3))
                    Text("No doctors listed for this facility yet.")
                        .font(.customFont(style: .medium, size: .h14))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(clinicDoctors) { doctor in
                    DoctorsCardView(
                        id: doctor.doctorID,
                        name: doctor.name,
                        speciality: doctor.specialist,
                        rating: doctor.rating,
                        fee: doctor.fee != nil ? "$\(String(format: "%.2f", doctor.fee!))" : "$50.00",
                        image: doctor.image,
                        btnAction: { onDoctorSelect(doctor) }
                    )
                    .onTapGesture { onDoctorSelect(doctor) }
                }
            }
        }
    }
}

struct FlowLayout<Data, Content: View>: View {
    let items: [Data]
    let content: (Data) -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ForEach(0..<min(items.count, 3), id: \.self) { i in
                    content(items[i])
                }
            }
            if items.count > 3 {
                HStack(spacing: 10) {
                    ForEach(3..<min(items.count, 6), id: \.self) { i in
                        content(items[i])
                    }
                }
            }
            if items.count > 6 {
                HStack(spacing: 10) {
                    ForEach(6..<items.count, id: \.self) { i in
                        content(items[i])
                    }
                }
            }
        }
    }
}

