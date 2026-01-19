//
//  FamilyMembersModel.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 20/09/24.
//

import Foundation
// import FirebaseFirestore  // DEPRECATED: Migrated to Supabase

struct FamilyMemberModel: Codable {
    var id: String?  // Changed from @DocumentID for Supabase compatibility
    var members: [MemberModel]
}

struct MemberModel: Codable, Hashable, Identifiable {
    var id: String? = UUID().uuidString
    var firstName, lastName, height, weight, age, bloodGroup, phoneNumber, imageURL: String
    var relation: String = "Family Member"
    
    var name: String {
        return "\(firstName) \(lastName)"
    }
}
