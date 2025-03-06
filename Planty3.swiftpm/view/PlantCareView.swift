//
//  PlantCareView 2.swift
//  Planty
//
//  Created by Noori on 24/02/2025.
//


import SwiftUI

struct PlantCareView: View {
    
    @EnvironmentObject var plantyVM: PlantViewModel
    @State private var isWatering: Bool = false // Animation state
    @Environment(\.presentationMode) var presentationMode
    @State private var waterCanOffset: CGFloat = 0 // Offset for watering animation
    @State private var waterCanRotation: Double = 0 // Rotation for watering animation
    @State private var navigateToFinalGrowth = false
    
 
    var body: some View {
        NavigationStack{
            ZStack {
                if plantyVM.growthStage == plantyVM.maxGrowthStage && plantyVM.plantState == "happy" {
                    // Show Final Congratulatory View
                    FinalGrowthView().environmentObject(plantyVM)
                }else {
                    
                    VStack {
                        
                        // Digital Clock Display
                        Text(plantyVM.formattedTime)
                            .font(.custom("Digital-7", size: 40)) //Ensure you have a digital-style font
                            .foregroundColor(.white)
                            .padding(.top, -24)
                        
                        Spacer()
                        
                        
                        // **Dynamic Plant Image Based on Growth & State**
                        Image(plantyVM.getPlantImage()) // Example: "Plant_2_happy"
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                            .padding(.bottom, -30)
                            .padding(.leading, 150)
                            .padding(.bottom, 10)
                        
                        
                        
                        
                        // **Watering Button (Only Works Twice Per Day)**
                        Button(action: {
                            if plantyVM.waterCount < 2 {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    isWatering = true
                                    waterCanOffset = -250 // Move up
                                    waterCanRotation = 15 // Rotate right
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        waterCanOffset = 0 // Reset position
                                        waterCanRotation = 0 // Reset rotation
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                    isWatering = false
                                    plantyVM.waterPlant() // Apply watering logic
                                }
                            }
                        }) {
                            // Watering Pot
                            Image("waterPot")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150)
                                .offset(y: waterCanOffset) // Move up when watering
                                .rotationEffect(.degrees(waterCanRotation)) // Rotate slightly
                                .padding(.bottom, 10)
                                .padding(.trailing, 230)
                        }
                        .disabled(plantyVM.waterCount >= 2)
                        
                        
                        
                        Text(plantyVM.waterCount < 2 ? "Tap to Water the Plant" : "You've watered enough today!")
                            .padding(4)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                        
                        
                       
                        
                    }//end vstack
                    .padding()
                    
                }// end else
                
            }//end zstack
            .background(
                Image(plantyVM.isNightTime ? "Blur_Night" : "Blur_Day")
                    .resizable()
                    .scaledToFill()
                    .padding(.top, -24)
                    .edgesIgnoringSafeArea(.all)
            )
            .overlay(
                // Notification Message Box
                Group {
                        if !plantyVM.notifications.isEmpty {
                            NotificationBoxView()
                                .frame(width: 300, height: 200)
                                .padding()
                        }
                    }, alignment: .top
                
            )
            .toolbar{
                ToolbarItem(placement: .principal){
                    Text(plantyVM.selectedPlant!.rawValue)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color("darkGreen"))
                }
                ToolbarItem(placement: .topBarLeading){
                    
                    NavigationLink(destination: home().environmentObject(plantyVM)) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.backward")
                                .foregroundColor(.accentColor)
                            Text("Home")
                        }
                    }
                    
                }
            }//end tool bar
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .background(.ultraThinMaterial)
            .onAppear{
                plantyVM.updateTime()
                
                if let savedPlant = UserDefaults.standard.string(forKey: "SelectedPlant") {
                    plantyVM.selectedPlant = PlantType(rawValue: savedPlant) ?? .pothos
                }
                
            }
            .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
                plantyVM.updateTime()
            }
            
        }
        
        
    }
}

// MARK: - Notification Box
struct NotificationBoxView: View {
    @EnvironmentObject var plantyVM: PlantViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let message = plantyVM.notifications.first {
                Text(message)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Button(action: {
                    plantyVM.removeNotification() // ✅ Dismiss notification
                }) {
                    Text("OK")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.leading, 200)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 3)
        .frame(width: 300)
    }
}


#Preview {
    PlantCareView()
        .environmentObject(PlantViewModel())
}
