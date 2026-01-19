//
//  ImageUploader.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 18/09/24.
//

import Foundation
import SwiftUI
import Supabase

struct ImageUploader {
    static func uploadImage(image: UIImage, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        let fileName = NSUUID().uuidString
        let path = "profile_images/\(fileName).jpg"

        Task {
            do {
                // Upload to Supabase Storage (Bucket must be public)
                try await SupabaseManager.shared.client.storage
                    .from("avatars")
                    .upload(
                        path: path,
                        file: imageData,
                        options: FileOptions(contentType: "image/jpeg")
                    )
                
                // Get Public URL
                let publicURL = try SupabaseManager.shared.client.storage
                    .from("avatars")
                    .getPublicURL(path: path)
                
                completion(publicURL.absoluteString)
            } catch {
                print("Supabase Storage Error: \(error.localizedDescription)")
            }
        }
    }
}
