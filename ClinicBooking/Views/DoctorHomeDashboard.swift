//
//  DoctorHomeDashboard.swift
//  ClinicBooking
//
//  Created by Assistant on 08/01/26.
//

import SwiftUI
import Supabase
import Realtime
import UserNotifications


struct PatientDetailView: View {
    let patientId: String
    @Environment(\.dismiss) var dismiss
    
    @State private var patient: AppUser?
    @State private var familyMembers: [MemberModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(10)
                }
                
                Spacer()
                
                Text("Patient Profile")
                    .font(.customFont(style: .bold, size: .h18))
                
                Spacer()
                
                // Placeholder to balance the header
                Image(systemName: "chevron.left").opacity(0).padding(10)
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .background(Color.white)
            
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading patient details...")
                    Spacer()
                }
            } else if let patient = patient {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Profile Header Section
                        profileHeaderSection(patient: patient)
                        
                        // Vital Stats Grid
                        vitalStatsGrid(patient: patient)
                        
                        // Personal Information Section
                        personalInfoSection(patient: patient)
                        
                        // Family Members Section
                        if !familyMembers.isEmpty {
                            familyMembersSection
                        }
                    }
                    .padding(.bottom, 30)
                }
                .background(Color.bg)
            } else if let error = errorMessage {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text("Could Not Load Patient")
                        .font(.customFont(style: .bold, size: .h18))
                    Text(error)
                        .font(.customFont(style: .medium, size: .h14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Try Again") {
                        fetchPatientData()
                    }
                    .buttonStyle(BlueButtonStyle(height: 45, color: .appBlue))
                    .frame(width: 200)
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchPatientData()
        }
    }
    
    // MARK: - Components
    
    private func profileHeaderSection(patient: AppUser) -> some View {
        VStack(spacing: 15) {
            AsyncImage(
                url: URL(string: patient.imageURL ?? ""),
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                },
                placeholder: {
                    Image("user")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .background(Color.appBlue.opacity(0.1))
                }
            )
            
            VStack(spacing: 5) {
                Text("\(patient.firstName) \(patient.lastName)")
                    .font(.customFont(style: .bold, size: .h22))
                    .foregroundColor(.text)
                
                Text(patient.email?.lowercased() ?? "No email provided")
                    .font(.customFont(style: .medium, size: .h15))
                    .foregroundColor(.gray)
                
                if let phone = patient.phoneNumber, !phone.isEmpty {
                    Text(phone)
                        .font(.customFont(style: .medium, size: .h14))
                        .foregroundColor(.appBlue)
                        .padding(.top, 2)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 30)
    }
    
    private func vitalStatsGrid(patient: AppUser) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            UserDetailsCardView(image: "height", title: "Height", value: "\(patient.height ?? "N/A") in")
            UserDetailsCardView(image: "weight", title: "Weight", value: "\(patient.weight ?? "N/A") KG")
            UserDetailsCardView(image: "age", title: "Age", value: "\(patient.age ?? "N/A")")
            UserDetailsCardView(image: "blood", title: "Blood", value: "\(patient.bloodGroup ?? "N/A")")
        }
        .padding(.horizontal)
    }
    
    private func personalInfoSection(patient: AppUser) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Personal Information")
                .font(.customFont(style: .bold, size: .h18))
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                infoRow(icon: "person.fill", title: "Gender", value: patient.gender ?? "Not specified")
                Divider()
                infoRow(icon: "calendar", title: "Date of Birth", value: patient.dob ?? "Not specified")
                Divider()
                infoRow(icon: "mappin.and.ellipse", title: "Address", value: patient.address ?? "No address added")
                Divider()
                infoRow(icon: "checkmark.shield.fill", title: "Insurance", value: patient.insuranceProvider ?? "None")
            }
            .background(Color.card)
            .cornerRadius(12)
            .padding(.horizontal)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    private var familyMembersSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Family Members")
                .font(.customFont(style: .bold, size: .h18))
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(familyMembers, id: \.id) { member in
                    FamilyMemberDetailRow(member: member)
                    if member.id != familyMembers.last?.id {
                        Divider().padding(.horizontal)
                    }
                }
            }
            .background(Color.card)
            .cornerRadius(12)
            .padding(.horizontal)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.appBlue)
                .frame(width: 30)
            Text(title)
                .font(.customFont(style: .medium, size: .h14))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.customFont(style: .medium, size: .h14))
                .foregroundColor(.text)
                .multilineTextAlignment(.trailing)
        }
        .padding()
    }
    
    // MARK: - Data Fetching
    
    private func fetchPatientData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 1. Fetch main profile
                let fetchedPatient = try await SupabaseDBManager.shared.fetchPublicProfile(userId: patientId)
                
                // 2. Fetch family members
                let fetchedMembers = try await SupabaseDBManager.shared.getFamilyMembersAsync(userId: patientId)
                
                await MainActor.run {
                    self.patient = fetchedPatient
                    self.familyMembers = fetchedMembers
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct FamilyMemberDetailRow: View {
    let member: MemberModel
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: member.imageURL)) { img in
                img.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.appBlue.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.customFont(style: .bold, size: .h16))
                HStack {
                    Text(member.relation)
                        .font(.customFont(style: .medium, size: .h13))
                        .foregroundColor(.appBlue)
                    Text("•")
                    Text("\(member.age) yrs")
                        .font(.customFont(style: .medium, size: .h13))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(member.bloodGroup)
                    .font(.customFont(style: .bold, size: .h13))
                    .foregroundColor(.appBlue)
                Text("\(member.height) in, \(member.weight) kg")
                    .font(.customFont(style: .medium, size: .h11))
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

struct DoctorHomeDashboard: View {
    @State private var selectedIndex: Int? = 0
    @State var defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
    @State private var showNotifications = false
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                NavigationSplitView {
                    SidebarView(role: "doctor", selectedIndex: $selectedIndex)
                } detail: {
                    detailView
                }
            } else {
                tabView
            }
        }
        .accentColor(.appBlue)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            refreshProfile()
        }
    }
    
    func refreshProfile() {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else { return }
        Task {
            do {
                let user = try await SupabaseDBManager.shared.fetchUserProfile(userId: userId)
                await MainActor.run {
                    self.defaults = user
                }
            } catch {
                print("Error refreshing profile: \(error)")
            }
        }
    }
    
    @ViewBuilder
    var detailView: some View {
        VStack(spacing: 0) {
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadHeader
            }
            
            // Pending Verification Banner
            if let user = defaults, user.verificationStatus == "pending" {
                pendingVerificationBanner
            }
            
            ZStack {
                switch selectedIndex ?? 0 {
                case 0:
                    NavigationStack {
                        DoctorHomeTab()
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom).animation(.spring())))
                case 1:
                    NavigationStack {
                        DoctorAppointmentsView()
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom).animation(.spring())))
                case 2:
                    NavigationStack {
                        PatientHistoryView()
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom).animation(.spring())))
                case 3:
                    NavigationStack {
                        DoctorProfileView()
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom).animation(.spring())))
                case 4:
                    NavigationStack {
                        DoctorProfileView()
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom).animation(.spring())))
                default:
                    NavigationStack {
                        DoctorHomeTab()
                    }
                }
            }
            .id(selectedIndex ?? 0)
        }
    }
    
    var iPadHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(SidebarItem(rawValue: selectedIndex ?? 0)?.title(for: "doctor") ?? "Dashboard")
                    .font(.customFont(style: .bold, size: .h24))
                Text(Date().formatted(date: .long, time: .omitted))
                    .font(.customFont(style: .medium, size: .h14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button {
                    showNotifications = true
                } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.text)
                        .padding(10)
                        .background(Color.card)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5)
                }
                
                Divider()
                    .frame(height: 30)
                    .padding(.horizontal, 5)
                
                Button {
                    selectedIndex = 4 // Profile
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Dr. \(defaults?.firstName ?? "") \(defaults?.lastName ?? "")")
                                .font(.customFont(style: .bold, size: .h14))
                            Text(defaults?.specialty ?? "Medical Specialist")
                                .font(.customFont(style: .medium, size: .h12))
                                .foregroundColor(.appBlue)
                        }
                        
                        AsyncImage(url: URL(string: defaults?.imageURL ?? "")) { (image: Image) in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            if (defaults?.imageURL ?? "").isEmpty {
                                Image("user").resizable()
                            } else {
                                ProgressView()
                            }
                        }
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.appBlue.opacity(0.2), lineWidth: 1))
                    }
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .background(Color.bg)
    }
    
    var tabView: some View {
        TabView(selection: Binding(get: { selectedIndex ?? 0 }, set: { selectedIndex = $0 })) {
            NavigationStack {
                VStack(spacing: 0) {
                    if let user = defaults, user.verificationStatus == "pending" {
                        pendingVerificationBanner
                    }
                    DoctorHomeTab()
                }
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
            .tag(4)
        }
    }
    
    var pendingVerificationBanner: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Account Pending Verification")
                        .font(.customFont(style: .bold, size: .h16))
                        .foregroundColor(.text)
                    
                    Text("Your application is being reviewed (24-48 hours). You have read-only access until verified.")
                        .font(.customFont(style: .medium, size: .h13))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Appended Views for Scope Resolution

struct DoctorHomeTab: View {
    @State var defaults = UserDefaults.standard.value(AppUser.self, forKey: "userDetails")
    @State var todayAppointments: [Appointment] = []
    @State var allDoctorAppointments: [Appointment] = []
    @State private var isRefreshing = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 25) {
                if UIDevice.current.userInterfaceIdiom != .pad {
                    headerView
                        .padding(.top, 10)
                }
                
                if defaults?.verificationStatus == "pending" {
                    VStack(spacing: 15) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.appBlue.opacity(0.7))
                        Text("Account Under Review")
                            .font(.title3)
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
                        StatCard(title: "Pending", count: "\(allDoctorAppointments.filter { $0.status == "pending" }.count)", color: .appBlue.opacity(0.9), icon: "clock.arrow.circlepath")
                        StatCard(title: "Confirmed", count: "\(allDoctorAppointments.filter { $0.status == "upcoming" }.count)", color: .appBlue.opacity(0.7), icon: "checkmark.seal")
                        StatCard(title: "Completed", count: "\(allDoctorAppointments.filter { $0.status == "completed" }.count)", color: .appBlue.opacity(0.5), icon: "checkmark.circle")
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
                                    .foregroundColor(.text)
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
                                NavigationLink(destination: PatientDetailView(patientId: appointment.userId)) {
                                    UpcomingAppointmentCardView(
                                        address: appointment.location,
                                        date: appointment.time,
                                        time: appointment.time,
                                        name: appointment.patientName,
                                        speciality: "Patient Visit",
                                        image: appointment.patientImage ?? "user"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 16)
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 1100 : .infinity)
                }
            }
        }
        .onAppear {
            refreshData()
        }
    }
    
    func refreshData() {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else { return }
        
        // Refresh profile status first
        Task {
            do {
                let user = try await SupabaseDBManager.shared.fetchUserProfile(userId: userId)
                await MainActor.run {
                    self.defaults = user
                }
            } catch {
                print("Error refreshing profile in Tab: \(error)")
            }
        }
        
        fetchTodayAppointments()
    }
    
    var headerView: some View {
        HStack {
            AsyncImage(
                url: URL(string: defaults?.imageURL ?? ""),
                content: { (image: Image) in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.appBlue.opacity(0.3), lineWidth: 2)
                        )
                },
                placeholder: {
                    if (defaults?.imageURL ?? "").isEmpty {
                        Image("user").resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        ProgressView()
                            .frame(width: 50, height: 50)
                    }
                })
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello Dr. \(defaults?.lastName ?? "")")
                    .font(.customFont(style: .bold, size: .h17))
                    .foregroundColor(.text)
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
                Text("\(allDoctorAppointments.filter { Calendar.current.isDate( $0.date, equalTo: Date(), toGranularity: .weekOfYear)}.count)")
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
                Text("\(Set(allDoctorAppointments.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }.map { $0.patientName }).count)")
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
    
    func fetchTodayAppointments() {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else { return }
        
        // Initial fetch
        Task {
            do {
                let allAppointments = try await SupabaseDBManager.shared.fetchDoctorAppointments(doctorId: userId)
                let calendar = Calendar.current
                await MainActor.run {
                    self.allDoctorAppointments = allAppointments
                    self.todayAppointments = allAppointments.filter { calendar.isDateInToday($0.date) }
                }
            } catch {
                print("Error fetching today's appointments: \(error)")
            }
        }
        
        // Realtime subscription
        Task {
            let channel = SupabaseManager.shared.client.channel("doctor_appointments_\(userId)")
            let insertionStream = channel.postgresChange(
                AnyAction.self,
                schema: "public",
                table: "appointments",
                filter: "doctor_id=eq.\(userId)"
            )
            
            await channel.subscribe()
            
            for await _ in insertionStream {
                print("🔔 New appointment received via Realtime!")
                // Refresh data
                do {
                    let allAppointments = try await SupabaseDBManager.shared.fetchDoctorAppointments(doctorId: userId)
                    let calendar = Calendar.current
                    await MainActor.run {
                        self.allDoctorAppointments = allAppointments
                        self.todayAppointments = allAppointments.filter { calendar.isDateInToday($0.date) }
                        
                        // Local Notification
                        sendLocalNotification(title: "New Appointment!", body: "A new patient has booked an appointment with you.")
                    }
                } catch {
                    print("Error refreshing Realtime appointments: \(error)")
                }
            }
        }
    }
    
    private func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
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
                                    NavigationLink(destination: PatientDetailView(patientId: appointment.userId)) {
                                        UpcomingAppointmentCardView(
                                            address: appointment.location,
                                            date: appointment.date.formatted(date: .abbreviated, time: .omitted),
                                            time: appointment.time,
                                            name: appointment.patientName,
                                            speciality: "Appointment",
                                            image: appointment.patientImage ?? "user"
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
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
                                    NavigationLink(destination: PatientDetailView(patientId: appointment.userId)) {
                                        PastAppointmetsCard(
                                            image: appointment.patientImage ?? "user",
                                            name: appointment.patientName,
                                            speciality: "Completed",
                                            date: appointment.date.formatted(date: .abbreviated, time: .omitted),
                                            time: appointment.time
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
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
        guard let userId = UserDefaults.standard.string(forKey: "userID") else { return }
        self.isLoading = true
        
        // Initial fetch
        Task {
            do {
                let allAppointments = try await SupabaseDBManager.shared.fetchDoctorAppointments(doctorId: userId)
                let now = Date()
                await MainActor.run {
                    self.upcomingAppointments = allAppointments.filter { $0.date >= now }
                    self.pastAppointments = allAppointments.filter { $0.date < now }
                    self.isLoading = false
                    print("✅ Fetched \(allAppointments.count) appointments for doctor \(userId)")
                }
            } catch {
                print("Error fetching doctor appointments: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        // Realtime subscription
        Task {
            let channel = SupabaseManager.shared.client.channel("doctor_all_appointments_\(userId)")
            let insertionStream = channel.postgresChange(
                AnyAction.self,
                schema: "public",
                table: "appointments",
                filter: "doctor_id=eq.\(userId)"
            )
            
            await channel.subscribe()
            
            for await _ in insertionStream {
                print("🔔 New appointment received via Realtime in Appointments View!")
                do {
                    let allAppointments = try await SupabaseDBManager.shared.fetchDoctorAppointments(doctorId: userId)
                    let now = Date()
                    await MainActor.run {
                        self.upcomingAppointments = allAppointments.filter { $0.date >= now }
                        self.pastAppointments = allAppointments.filter { $0.date < now }
                        
                        // Local Notification
                        sendLocalNotification(title: "New Booking!", body: "A new appointment has been added to your schedule.")
                    }
                } catch {
                    print("Error refreshing Realtime appointments in View: \(error)")
                }
            }
        }
    }
    
    private func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct PatientRecord: Identifiable {
    let userId: String
    let name: String
    let lastVisit: Date
    let diagnosis: String
    let image: String
    
    var id: String { userId } // Use userId as the unique identifier
}

// Individual patient row component
struct PatientHistoryRowView: View {
    let patient: PatientRecord
    let showDivider: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: PatientDetailView(patientId: patient.userId)) {
                HStack(spacing: 15) {
                    AsyncImage(url: URL(string: patient.image)) { img in
                        img.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(patient.name)
                            .font(.headline)
                            .foregroundColor(.text)
                        Text("Last Visit: \(patient.lastVisit.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(patient.diagnosis)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.appBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.appBlue.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(PlainButtonStyle())
            
            if showDivider {
                Divider()
                    .padding(.leading, 80)
            }
        }
    }
}

// Helper view to avoid ForEach binding inference issues
struct PatientHistoryListView: View {
    let patients: [PatientRecord]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(patients.enumerated()), id: \.element.id) { index, patient in
                    PatientHistoryRowView(
                        patient: patient,
                        showDivider: index < patients.count - 1
                    )
                }
            }
            .background(Color.white)
        }
        .background(Color.bg)
    }
}

struct PatientHistoryView: View {
    @State private var patients: [PatientRecord] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    
    var body: some View {
        let patientData = patients // Extract to local constant
        
        return NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                } else if patientData.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No patient history yet")
                            .font(.headline)
                        Text("Completed appointments will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    PatientHistoryListView(patients: patientData)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                fetchPatientHistory()
            }
        }
    }
    
    func fetchPatientHistory() {
        guard let userId = UserDefaults.standard.string(forKey: "userID") else { return }
        self.isLoading = true
        
        Task {
            do {
                // Fetch all appointments for the doctor
                let allAppointments = try await SupabaseDBManager.shared.fetchDoctorAppointments(doctorId: userId)
                
                await MainActor.run {
                    // Group by patientId and find the latest appointment for each
                    let grouped = Dictionary(grouping: allAppointments, by: { $0.userId })
                    
                    self.patients = grouped.compactMap { (key, value) -> PatientRecord? in
                        guard let lastAppt = value.sorted(by: { $0.date > $1.date }).first else { return nil }
                        
                        // Only include if at least one appointment is completed or past
                        // You can adjust logic to show all patients regardless of status
                        return PatientRecord(
                            userId: lastAppt.userId,
                            name: lastAppt.patientName,
                            lastVisit: lastAppt.date,
                            diagnosis: lastAppt.status.capitalized, // Using status as proxy for diagnosis/reason
                            image: lastAppt.patientImage ?? ""
                        )
                    }.sorted(by: { $0.lastVisit > $1.lastVisit })
                    
                    self.isLoading = false
                }
            } catch {
                print("Error fetching patient history: \(error)")
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        
        // Realtime subscription
        Task {
            let channel = SupabaseManager.shared.client.channel("doctor_history_\(userId)")
            let insertionStream = channel.postgresChange(
                AnyAction.self,
                schema: "public",
                table: "appointments",
                filter: "doctor_id=eq.\(userId)"
            )
            
            await channel.subscribe()
            
            for await _ in insertionStream {
                fetchPatientHistory() // Refresh on change
            }
        }
    }
}




#Preview {
    PatientDetailView(patientId: "test-id")
}
