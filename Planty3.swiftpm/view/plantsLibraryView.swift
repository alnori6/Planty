//
//  PlantsLibraryView.swift
//  Planty
//
//  Created by Noori on 23/02/2025.
//

import SwiftUI

struct plantsLibraryView: View {
    
    @EnvironmentObject var plantyVM: PlantViewModel
    @State var showsheet: Bool = false
    
    // Define a grid layout with adaptive columns
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(PlantType.allCases, id: \.self) { plant in
                        Button(action: {
                            showsheet = true
                        }) {
                            VStack {
                                Image("\(plant.rawValue) happy 5") // ✅ Display final stage image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(radius: 3)
                                
                                Text(plant.rawValue) // ✅ Display plant name
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            .padding()
                        }
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
            .toolbar{
                ToolbarItem(placement: .principal){
                    Text("Plants Library")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color("darkGreen"))
                }
                
            }.navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .background(Color("lightGreen"))
        }
    }
}

#Preview {
    plantsLibraryView()
        .environmentObject(PlantViewModel()) // ✅ Pass ViewModel for preview
}
