//
//  Plant.swift
//  Planty3
//
//  Created by Noori on 24/02/2025.
//


import Foundation
import CoreLocation

struct PlantInfo: Identifiable {
    let id = UUID()
    let name: String
    let scientificName: String
    let commonUses: String
    let region: String
    let overview: String
    let trditionalUses: String
    let poisn: String
    let image: String
    var latitude: Double? // 🌍 Dynamically fetched
    var longitude: Double?
    
    // ✅ Computed Property: Convert the filename to a valid format
        var imageFileName: String {
            return image
                .lowercased() // Convert to lowercase
                .replacingOccurrences(of: " ", with: "_") // Replace spaces with underscores
                .replacingOccurrences(of: "'", with: "") // Remove apostrophes if needed
        }
}
