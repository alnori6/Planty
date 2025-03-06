//
//  Plant.swift
//  Planty3
//
//  Created by Noori on 24/02/2025.
//

import SwiftUI
import Foundation
import CoreLocation

// MARK: - PlantInfo Model
struct PlantInfo {
    let id = UUID()
    let name: String
    let scientificName: String
    let commonNames: [String]
    let commonUses: [String]
    let region: [String]
    let overview: String
    let traditionalUses: String
    let poison: String
    var image: UIImage
    
    var latitude: Double? // 🌍 Dynamically fetched
    var longitude: Double?
        
  
}


// MARK: - Structure to Store Saved Plants
struct PlantLibraryItem: Identifiable {
    let id = UUID()
    let plant: PlantInfo
    let image: UIImage
}
