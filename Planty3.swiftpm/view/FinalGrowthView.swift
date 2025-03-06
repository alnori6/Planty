//
//  FinalGrowthView.swift
//  Planty0.2
//
//  Created by Noori on 24/02/2025.
//


import SwiftUI

struct FinalGrowthView: View {
    @EnvironmentObject var plantyVM: PlantViewModel
    @State var library : Bool = false
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                VStack {
                    Spacer()
                    
                    // Celebration Message
                    Text("🎉 Congrats, you grew your plant! 🎉")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    
                    Spacer()
                    
                    Image("\(plantyVM.selectedPlant!.rawValue) happy 5") // Final grown plant image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                    
                    
                    Spacer()
                    
                    
                    
                    NavigationLink(destination: plantsLibraryView().environmentObject(plantyVM)) {
                        HStack(spacing: 8) {
                            Image(systemName: "books.vertical.fill")
                            
                            Text("Plants Library")
                        }
                        .padding()
                    }
                    .buttonStyle(interfaceButton())
                    
                    
                    Button(action: {
                        library.toggle()
                    }){
                        HStack(spacing: 8) {
                            Image(systemName: "books.vertical.fill")
    
                            Text("Plants Library")
                        }
                        .padding()
                    }
                    .buttonStyle(primaryButton())
                    .fullScreenCover(isPresented: $library) {
                        home().environmentObject(plantyVM)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .background(
                Image("Blur_Day")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            )
        }
        
        
    }
}

#Preview {
    FinalGrowthView()
        .environmentObject(PlantViewModel())
}
