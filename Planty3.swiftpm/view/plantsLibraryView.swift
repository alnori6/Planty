//
//  PlantsLibraryView.swift
//  Planty
//
//  Created by Noori on 23/02/2025.
//

import SwiftUI

struct plantsLibraryView: View {
    
    @EnvironmentObject var plantyVM: PlantViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("lightGreen").edgesIgnoringSafeArea(.all)
                
                if plantyVM.savedPlants.isEmpty {
                    EmptyLibraryView()
                } else {
                    PlantGridView(savedPlants: plantyVM.savedPlants)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Plants Library")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color("darkGreen"))
                }
            }
        }
    }
}


// MARK: - Grid View for Saved Plants
struct PlantGridView: View {
    let savedPlants: [PlantLibraryItem]
    
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(savedPlants) { savedPlant in
                    NavigationLink(destination: PlantDetailView(plant: savedPlant.plant, plantImage: savedPlant.image)) {
                        PlantCardView(plant: savedPlant.plant, plantImage: savedPlant.image)
                    }
                }
            }
            .padding()
        }
    }
}



// MARK: - Plant Card View
struct PlantCardView: View {
    let plant: PlantInfo
    let plantImage: UIImage
    
    var body: some View {
        VStack {
            Image(uiImage: plantImage)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 3)
            
            Text(plant.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}



// MARK: - Empty Library View
struct EmptyLibraryView: View {
    var body: some View {
        VStack {
            Image(systemName: "leaf")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
                .opacity(0.6)
            
            Text("No saved plants yet.")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.gray)
                .padding()
        }
        .padding()
    }
}



#Preview {
    plantsLibraryView()
        .environmentObject(PlantViewModel())
}
