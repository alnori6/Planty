//
//  PlantDetailView.swift
//  Planty3
//
//  Created by Noori on 24/02/2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct PlantDetailView: View {
    @EnvironmentObject var plantyVM: PlantViewModel
    let plant: PlantInfo
//    var plantImage: UIImage
    @State private var plantImage: UIImage?
    
    init(plant: PlantInfo, plantImage: UIImage?) {
            self.plant = plant
            self._plantImage = State(initialValue: plantImage) // ✅ Initialize as State
        }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
//                    PlantImageView(image: plantImage) // ✅ Optimized Image Section
                    if let image = plantImage {
                       PlantImageView(image: image)
                   }
                    
                    PlantNameView(name: plant.name, scientificName: plant.scientificName) // ✅ Optimized Name Section
                    
                    Divider().foregroundColor(Color("yellow"))
                    
                    Text("Overview")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color("darkBlue"))
                    
                    Divider()
                    
                    Text(plant.overview)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .padding(.bottom, 24)
                    
                    InformationCardView(title: "Common Names", text: plant.commonNames.joined(separator: ", ")) // ✅ Common Names
                    
                    MedicinalUsesView(uses: plant.commonUses) // ✅ Medicinal Uses List
                    InformationCardView(title: "Poison Effects", text: plant.poison) // ✅ Poison Effects
                    
                    InformationCardView(title: "Traditional Uses", text: plant.traditionalUses) // ✅ Traditional Uses
                    RegionView(plant: plant) // ✅ Region Information (Map & Text)
                    
                    
                    Spacer()
                    
                    // MARK: - Save to Library Button
                    Button(action: {
//                        plantyVM.toggleSavePlant(plant)
                        if let imageToSave = plantImage {
                            plantyVM.toggleSavePlant(plant, image: imageToSave) 
                        }
                    }) {
                        HStack {
                            Image(systemName: plantyVM.isPlantSaved(plant) ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 22))
                                .foregroundColor(Color("yellow"))
                            Text(plantyVM.isPlantSaved(plant) ? "Remove from Library" : "Save to Library")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(plantyVM.isPlantSaved(plant) ? Color("darkBlue") : Color.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(plantyVM.isPlantSaved(plant) ? Color("lightBlue") : Color("darkBlue"))
                        .cornerRadius(12)
                    }
                    .padding(.bottom, 24)
                }
                .padding()
            }
            .onAppear {
                if let firstRegion = plant.region.first, !firstRegion.isEmpty {
                    plantyVM.fetchCoordinates(for: firstRegion)
                } else {
                    print("⚠️ No valid region found for this plant.")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: home()) {
                        Button {
                            plantImage = nil // ✅ Clear image to free memory
                        } label: {
                            Text("Done")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color.accentColor)
                        }
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(plant.name)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color("darkGreen"))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
    }
}


struct PlantImageView: View {
    let image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}


struct PlantNameView: View {
    let name: String
    let scientificName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color("darkGreen"))
            
            HStack {
                Text("Scientific Name:")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color("darkBlue"))
                Text(scientificName)
                    .font(.system(size: 16, weight: .medium))
            }
        }
        .padding(.top, 4)
    }
}


struct InformationCardView: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("darkBlue"))
            
            Divider()
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
        }
        .padding()
        .background(Color("yellow").opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 24)
    }
}

struct MedicinalUsesView: View {
    let uses: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Medicinal Uses")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("darkBlue"))
            
            Divider()
            
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(uses, id: \.self) { use in
                    HStack(alignment: .top) {
                        Text("•")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                        Text(use)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .padding()
        .background(Color("lightGreen").opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 24)
    }
}


struct RegionView: View {
    @EnvironmentObject var plantyVM: PlantViewModel
    let plant: PlantInfo
    

    var body: some View {
        VStack {
            Text("Where it Grows:")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("darkBlue"))
            
            Text(plant.region.joined(separator: ", "))
                .font(.system(size: 16, weight: .medium))
                .padding(.bottom, 8)
            
            if let region = plantyVM.region {
                let regionFirst = plant.region.first
                Map(position: .constant(.region(region))) {
                    Marker(regionFirst!, coordinate: CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude))
                }
                .frame(height: 200)
                .cornerRadius(12)
            } else {
                if plantyVM.isLoading {
                    ProgressView("Fetching location...")
                } else {
                    Text("Unable to find location")
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .padding(.bottom, 24)
    }
}


#Preview {
    PlantDetailView(
        plant: PlantInfo(
            name: "Aloe Vera",
            scientificName: "Aloe barbadensis miller",
            commonNames: ["Burn Plant", "Lily of the Desert"],
            commonUses: ["Soothes burns", "Aids digestion", "Supports skin health"],
            region: ["Africa", "India", "Middle East"], // ✅ Fixed region placement
            overview: "Used for centuries for its cooling and healing properties in skincare and gut health.", // ✅ Fixed overview placement
            traditionalUses: "Ancient Egyptians called Aloe Vera the 'Plant of Immortality,' using it in embalming and for wound healing. In India, it has been a key ingredient in Ayurvedic treatments for skin conditions and digestion. In the Middle East, it has been used for centuries to hydrate the skin in desert climates.", // ✅ Fixed traditional uses placement
            poison: "Oral consumption of latex form may cause digestive irritation.",
            image: UIImage(named: "nomiCircle2") ?? UIImage()
            
        ),
        plantImage: UIImage(named: "nomiCircle2") ?? UIImage() // ✅ Placeholder image for preview
    )
    .environmentObject(PlantViewModel())
}
