import SwiftUI

@main
struct MyApp: App {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @StateObject private var plantyVM = PlantViewModel()
    @StateObject private var cameraModel = CameraModel()
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                home() // Replace with your actual main app view
                    .environmentObject(plantyVM)
                    .environmentObject(cameraModel)
                    .preferredColorScheme(.light)
                    
            } else {
                OnboardingView()
                    .environmentObject(plantyVM)
                    .environmentObject(cameraModel)
                    .preferredColorScheme(.light)
            }
            
        }
        
    }
}
