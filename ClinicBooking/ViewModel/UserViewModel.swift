//
//  UserViewModel.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 19/09/24.
//

import Foundation
import Supabase

@MainActor
class UserViewModel: ObservableObject {

    @Published var familyMembers: FamilyMemberModel?
    private let dbManager = SupabaseDBManager.shared

    func getFamilyMembers() async {
        if let session = try? await SupabaseManager.shared.client.auth.session {
            do {
                // In Supabase, family members are a separate table related by user_id
                // For now, mirroring the existing FamilyMemberModel decoding if possible, 
                // but usually this would be a [MemberModel] direct fetch.
                let members: [MemberModel] = try await SupabaseManager.shared.client.from("family_members")
                    .select()
                    .eq("user_id", value: session.user.id.uuidString)
                    .execute()
                    .value
                
                self.familyMembers = FamilyMemberModel(members: members)
                debugPrint("Family Members == \(String(describing: self.familyMembers))")
            } catch {
                debugPrint("Error fetching family members from Supabase: \(error)")
            }
        }
    }

    func getUserDetails() async {
        if let session = try? await SupabaseManager.shared.client.auth.session {
            do {
                let details = try await dbManager.getUserDetails(userId: session.user.id.uuidString)
                UserDefaults.standard.set(encodable: details, forKey: "userDetails")
                debugPrint("User Details fetched from Supabase")
            } catch {
                debugPrint("Error fetching user details: \(error)")
            }
        }
    }


}
