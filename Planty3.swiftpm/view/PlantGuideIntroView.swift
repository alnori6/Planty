//
//  PlantGuideIntroView.swift
//  Planty
//
//  Created by Noori on 23/02/2025.
//


import SwiftUI



struct PlantGuideIntroView: View {
    @State private var selectedPlant: PlantType?
    @State private var navigateToGame = false
    
    @EnvironmentObject var plantyVM: PlantViewModel
    @State private var currentStep = 0  // Tracks the current step

    let steps: [(title: String, text: String, plantImage: String)] = [
        ("Nomi the Farmer", "There are rules to take care of your plant! \n\nTo help, I'll be taking care of the plant vitamins, and you water them.", "Anthurium happy 1"),
        ("Nomi the Farmer", "First of all, you need to water them twice a day! I will remind you to do so at 9 AM and 9 PM; don't forget.", "Anthurium happy 1"),
        ("Nomi the Farmer", "If you miss 1 time to water the plant, it will become thirsty.", "Anthurium thirsty 1"),
        ("Nomi the Farmer", "If you miss 3 times to water the plant, it will die.", "Anthurium dead 1"),
        ("Nomi the Farmer", "Choose the plant you want to grow!", "Anthurium dead 1")
    ]
    
    var body: some View {
        
        NavigationStack{
            VStack {
                Spacer()

                HStack(){
                    
                    TextBoxView(title: steps[currentStep].title, text: steps[currentStep].text)
                        .frame(width: 200)
                        .lineLimit(nil)  
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    Image("nomiCircle2")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 160)
                    
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
               
                if currentStep == steps.count - 1 {
                    // Plant Selection Picker
                    Picker("Select Plant", selection: $selectedPlant) {
                        ForEach(PlantType.allCases) { plant in
                            Text(plant.rawValue)
                                .tag(plant)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(8)
                    .cornerRadius(12)
                    
                    

                    Spacer().frame(height: 8)

                    // Plant Image Preview
                    switch selectedPlant {
                    case .anthurium:
                        Image("Anthurium happy 1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                    case .pothos:
                        Image("Pothos happy 1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                    default:
                        Image("nonPlant")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                    }
                   

                    
                }else{
                    Image(steps[currentStep].plantImage) // Plant state image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                }
                    
                
                Spacer()
                
                Button(action: {
                    if currentStep < steps.count - 1 {
                        currentStep += 1
                    }
                    else if currentStep == steps.count - 1 {
                        if let selectedPlant = selectedPlant {
                            plantyVM.selectedPlant = selectedPlant
                            UserDefaults.standard.set(true, forKey: "HasSeenInstructions") // Mark guide as seen
                            UserDefaults.standard.set(selectedPlant.rawValue, forKey: "SelectedPlant") // mark the sleceted plant
                            navigateToGame = true
                        }
                    }
                   
                }) {
                    Text(currentStep == steps.count - 1 ? "Lets Go!" : "Next")
                        .padding()
                        .frame(width: 200)
                    
                }
                .buttonStyle(primaryButton())
                .fullScreenCover(isPresented: $navigateToGame) {
                    PlantCareView().environmentObject(plantyVM)
                }
                .disabled(currentStep == steps.count - 1 && selectedPlant == nil)
                Spacer()
                
            }
            .padding(.horizontal)
            .toolbar {
                
                ToolbarItem(placement: .principal){
                    Text("Plant Guide")
                       .font(.system(size: 32, weight: .bold))
                       .foregroundColor(Color("darkBlue"))
                }
                
                if currentStep < steps.count - 1 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            currentStep = steps.count - 1
                        }) {
                            Text("Skip")
                                .foregroundColor(Color.gray)
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                }
                
            } //end toolbar
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .onAppear {
                if UserDefaults.standard.bool(forKey: "HasSeenInstructions") {
                    currentStep = steps.count - 1 
                }
            }
        }
    }
}




#Preview {
    PlantGuideIntroView()
        .environmentObject(PlantViewModel())
}
