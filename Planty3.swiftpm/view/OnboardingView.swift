//
//  OnboardingView.swift
//  Planty0.2
//
//  Created by Noori on 24/02/2025.
//


import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State var starting: Bool = false
    
    let onboardingSteps: [(title: String, description: String, image: String)] = [
        ("Welcome to Planty", "Hi, I am Nomi, and I am here to revive herbal medicine that has been used in the past in many cultures.", "nomiCircle1"),
        ("Why Herbal Medicine?", "Growing up, my grandmother used to make me herbal remedies whenever I was sick. Now I want to share this knowledge with you!", "nomiCircle2"),
        ("Take Care of Your Plant", "Your plant needs watering twice a day! If you miss watering, it will start to wither.", "nomiCircle2")
    ]
    
    var body: some View {
        TabView(selection: $currentStep) {
            ForEach(0..<onboardingSteps.count, id: \.self) { index in
                VStack {
                    
                    VStack{
                        Text(onboardingSteps[index].title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color("darkBlue"))
                            .padding(.top, 20)
                        
                        Spacer().frame(height: 56)
                        
                        Image(onboardingSteps[index].image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .padding(.bottom)
                        
                        Text(onboardingSteps[index].description)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(height: 600)
                    
                    Spacer()
                    
                    if index == onboardingSteps.count - 1 {
                        Button(action: {
                            hasSeenOnboarding = true
                            starting = true
                        }) {
                            Text("Get Started")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .fullScreenCover(isPresented: $starting) {
                            home().environmentObject(PlantViewModel())
                                .preferredColorScheme(.light)
                        }
                        .buttonStyle(primaryButton())
                    } else {
                        Button(action: {
                            currentStep += 1
                        }) {
                            Text("Next")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .buttonStyle(primaryButton())
                    }
                    
                    Spacer().frame(height: 50)
                }
            }
        }
        .padding()
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.tintColor  // Change active dot color
                UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray5  // Change inactive dot color
            }
    }
}

#Preview {
    OnboardingView( hasSeenOnboarding: true, starting: false)
}
