//
//  SupabaseManager.swift
//  ClinicBooking
//
//  Created by Janarthanan Kannan on 17/01/26.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    /// The global Supabase client instance.
    /// Configured for project: akhixkhdgfiqjgkfxfph
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://akhixkhdgfiqjgkfxfph.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFraGl4a2hkZ2ZpcWpna2Z4ZnBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg2NTkwNTYsImV4cCI6MjA4NDIzNTA1Nn0.f00QHpnYP8Lzg9zwtFwhTOjMarcJBePIR6CJqNv7jnI"
    )
    
    private init() {}
}
