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
    let plant: PlantInfo
    let plantImage: UIImage
    @State private var region: MKCoordinateRegion?
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                // 📷 Plant Image (Placeholder)
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 250)
                    .overlay(
                        Image(uiImage: plantImage) // Assuming image is named after the plant
                            .resizable()
                            .scaledToFill()
                            .padding()
                    ).clipShape(RoundedRectangle(cornerRadius: 16))

                
                // 🌿 Plant Name
                Text(plant.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color("darkGreen"))
                
                // 🔬 Scientific Name
                HStack {
                    Text("Scientific Name:")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color("darkBlue"))
                    Text(plant.scientificName)
                        .font(.system(size: 16, weight: .medium))
                    
                }
                .padding(.top, 4)
                
                Divider()
                    .background(Color("yellow"))
                
                // 📌 Overview
                Text("Overview")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color("darkBlue"))
                    .padding(.top, 24)
                
                Text(plant.overview)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.bottom, 24)
                
                
                // ⚕️ Medicinal Uses
                VStack(alignment: .leading, spacing: 16) {
                    Text("⚕️Medicinal Uses")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color("darkBlue"))
                    
                    Divider()
                    
                    ForEach(plant.commonUses.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }, id: \.self) { use in
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
                .padding()
                .background(Color("lightGreen").opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 24)
                
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("⚠ Poisons Effect")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color("darkBlue"))
                    
                    Divider()
                    
                    ForEach(plant.poisn.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }, id: \.self) { use in
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
                .padding()
                .background(Color("lightBlue").opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 24)
                
                
                
                VStack{
                    // 🌍 Region
                    Text("Where it Grows:")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color("darkBlue"))
                    
                    Text(plant.region)
                        .font(.system(size: 16, weight: .medium))
                        .padding(.bottom, 16)
                    
                    if let region = region {
                        Map(coordinateRegion: .constant(region), annotationItems: [plant]) { plant in
                            MapMarker(coordinate: CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude), tint: .green)
                        }
                        .frame(height: 200)
                        .cornerRadius(12)
                    } else {
                        if isLoading {
                            ProgressView("Fetching location...")
                        } else {
                            Text("⚠️ Unable to find location")
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .padding(.bottom, 24)
                
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Traditional Uses")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color("darkBlue"))
                    
                    Divider()
                    
                    ForEach(plant.trditionalUses.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }, id: \.self) { use in
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
                .padding()
                .background(Color("yellow").opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 24)
                
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            fetchCoordinates(for: plant.region)
        }
        .toolbar{
            ToolbarItem(placement: .principal){
                Text("Plant Info")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color("darkGreen"))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        
        
    }
    
    //MARK: - search for location
    private func fetchCoordinates(for region: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(region) { placemarks, error in
            DispatchQueue.main.async {
                if let location = placemarks?.first?.location {
                    self.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 15)
                    )
                    isLoading = false
                } else {
                    print("❌ Error fetching coordinates: \(error?.localizedDescription ?? "Unknown error")")
                    isLoading = false
                }
            }
        }
    }
    
}



#Preview {
    PlantDetailView(plant: PlantInfo(name: "Aloe Vera", scientificName: "Aloe barbadensis miller", commonUses: "Soothes burns, aids digestion, supports skin health", region: "Africa, India, Middle East", overview: "Used for centuries for its cooling and healing properties in skincare and gut health.",trditionalUses: "Applied to wounds and burns in traditional medicine."  , poisn: "Oral consumption of latex form may cause digestive irritation.", image: "Avoid these 8 common mistakes to keep your aloe vera plants thriving.jpg"),
                    
    plantImage: UIImage(named: "nomiCircle2") ?? UIImage() // ✅ Placeholder image for preview
    )
}



