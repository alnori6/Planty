//
//  PlantViewModel.swift
//  Planty
//
//  Created by Noori on 23/02/2025.
//

import SwiftUI
import Foundation
import UserNotifications
import MapKit
import CoreLocation



enum PlantType: String, CaseIterable, Identifiable {
    case pothos = "Pothos"
    case anthurium = "Anthurium"
    
    var id: String { self.rawValue }
}

//@MainActor
class PlantViewModel: ObservableObject {
    
    
    //MARK: - the game func
    @Published var currentTime = Date()
    @Published var formattedTime: String = ""
    @Published var isNightTime: Bool = false
    @Published var waterCount: Int = 0 // Tracks daily watering
    @Published var lastWatered: Date? = nil
    @Published var missedWatering: Int = 0 // Tracks missed waterings
    @Published var growthStage: Int = 1 // Starts from stage 1 to 5
    @Published var plantState: String = "happy" // happy, thirsty, dead
    @Published var selectedPlant: PlantType? = nil  // Default plant, can be "Pothos"
    
    @Published var canWaterAgain: Bool = true // Controls second watering
    @Published var timeRemaining: TimeInterval = 0 // Tracks countdown time
    @Published var timerActive = false // If countdown is running
    
    let maxGrowthStage = 5
    let wateringInterval: TimeInterval = 3 * 3600 // 3 hours in seconds
    
    //  Store in-app notification messages
    @Published var notifications: [String] = []
    
    init() {
        addInitialNotification()
        updateTime()
        requestNotificationPermissions()
        checkMissedWatering()
        loadSavedPlant()
        scheduleDailyWateringReminders()
        loadPlantData()
        checkWateringStatus()
    }
    
    func addInitialNotification() {
        if notifications.isEmpty {
            notifications.append("Welcome to the plant space! 🌱 \n\n Lets plant together!  ")
            notifications.append("I think you should water your plant! 🌱 \n\nHINT: Use the watering pot.")
        }
    }
    
    //MARK: - Updates the current time and determines if it's day or night
    func updateTime() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formattedTime = formatter.string(from: Date())
        
        let hour = Calendar.current.component(.hour, from: Date())
        isNightTime = (hour >= 18 && hour <= 23) // 6 PM - 6 AM = Night
    }
    
    
    // MARK: - Watering Logic with 3-Hour Delay
    func waterPlant() {
        let now = Date()
        
        if waterCount == 0 {
            // First watering
            waterCount += 1
            lastWatered = now
            plantState = "happy"
            startWateringTimer()
        } else if waterCount == 1, let lastWatered = lastWatered {
            let elapsedTime = now.timeIntervalSince(lastWatered)
            
            if elapsedTime >= wateringInterval {
                // Second watering allowed
                waterCount += 1
                plantState = "happy"
                timerActive = false
                
                if growthStage < maxGrowthStage {
                    growthStage += 1
                }
                
                if growthStage == maxGrowthStage {
                    addNotification("🎉 Congrats, you grew your plant! 🎉")
                }
                
            } else {
                
                addNotification("⚠️ Second watering is not allowed yet! Wait for \(formattedTimeRemaining()).")
                print("⚠️ Second watering is not allowed yet! Wait for \(formattedTimeRemaining()).")
                return
            }
        } else {
            addNotification("You've already watered the plant twice today!")
            print("❌ You've already watered the plant twice today!")
            return
        }
        
        addNotification("Next watering in: \(formattedTimeRemaining()) \n🌱 Current growth stage: \(growthStage), State: \(plantState)")
        print("🌱 Watering done! Current growth stage: \(growthStage), State: \(plantState)")
    }
    
    // MARK: - Start Watering Timer (With Countdown)
    private func startWateringTimer() {
        timeRemaining = wateringInterval
        timerActive = true

        // ✅ Schedule Notification for when watering is allowed again
        scheduleWateringNotification()

        // ✅ Start real-time countdown
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1  // ⏳ Decrease time by 1 second
            } else {
                timer.invalidate()  // ⏹ Stop when countdown finishes
                self.timerActive = false
            }
        }
    }
//    private func startWateringTimer() {
//        timeRemaining = wateringInterval
//        timerActive = true
//        scheduleWateringNotification()
//    }
    
    // MARK: - Update Countdown for Second Watering
    // MARK: - Sync Countdown on App Reopen
    func checkWateringStatus() {
        if waterCount == 1, let lastWatered = lastWatered {
            let elapsedTime = Date().timeIntervalSince(lastWatered)
            timeRemaining = max(wateringInterval - elapsedTime, 0)

            if timeRemaining > 0 {
                timerActive = true
                startWateringTimer()  // ✅ Restart countdown if app was closed
            } else {
                timerActive = false
            }
        }
    }
    
//    func checkWateringStatus() {
//        if waterCount == 1, let lastWatered = lastWatered {
//            let elapsedTime = Date().timeIntervalSince(lastWatered)
//            timeRemaining = max(wateringInterval - elapsedTime, 0)
//            
//            if timeRemaining == 0 {
//                timerActive = false
//            }
//        }
//    }
    
    // MARK: - Format Time Remaining
    private func formattedTimeRemaining() -> String {
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    // MARK: - Missed Watering Handling
    func checkMissedWatering() {
        guard let last = lastWatered else {
            missedWatering += 1
            updatePlantState()
            return
        }
        
        let calendar = Calendar.current
        if !calendar.isDateInToday(last) {
            missedWatering += 1
        }
        
        updatePlantState()
    }
    
    
    func updatePlantState() {
        if missedWatering == 1 {
            plantState = "thirsty"
        } else if missedWatering == 2 {
            sendMissedWateringAlert()
        } else if missedWatering >= 3 {
            plantState = "dead"
        }
    }
    
    // MARK: - Load Selected Plant
    func loadSavedPlant() {
        if let savedPlant = UserDefaults.standard.string(forKey: "SelectedPlant"),
           let plantType = PlantType(rawValue: savedPlant) {
            selectedPlant = plantType
        } else {
            selectedPlant = nil // Ensure it remains nil if no plant is saved
        }
    }
    
    
    // MARK: - Skip Plant Guide If Plant Already Selected
    func shouldSkipPlantGuide() -> Bool {
        return selectedPlant != nil
    }
    
    
    // MARK: - Notification Scheduling
    private func scheduleWateringNotification() {
        let content = UNMutableNotificationContent()
        content.title = "💧 Time for the Second Watering!"
        content.body = "3 hours have passed! Water your plant again to keep it growing!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: wateringInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "secondWaterReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleDailyWateringReminders() {
        let notificationTimes = ["09:00", "21:00"]
        
        for time in notificationTimes {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            if let scheduledTime = formatter.date(from: time) {
                let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: scheduledTime)
                
                let content = UNMutableNotificationContent()
                content.title = "🌱 Time to Water Your Plant!"
                content.body = "Your plant needs care! Don't forget to water it."
                content.sound = .default
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                let request = UNNotificationRequest(identifier: "waterReminder_\(time)", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    
    func addNotification(_ message: String) {
        notifications.append(message)
    }
    
    func removeNotification() {
        if !notifications.isEmpty {
            notifications.removeFirst()
        }
    }
    
    func sendMissedWateringAlert() {
        let content = UNMutableNotificationContent()
        content.title = "Your Plant is Thirsty! 💧"
        content.body = "You’ve missed two waterings! One more and it might wilt!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // Immediate reminder
        
        let request = UNNotificationRequest(identifier: "missedWatering", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notifications allowed")
            } else {
                print("Notifications denied")
            }
        }
    }
    
    func getPlantImage() -> String {
        guard let selectedPlant = selectedPlant else {
            return "nonPlant" // placeholder if no plant is selected
        }
        return "\(selectedPlant.rawValue) \(plantState) \(growthStage)"
    }
    
    
    func selectPlant(_ plant: PlantType) {
        selectedPlant = plant
        UserDefaults.standard.set(plant.rawValue, forKey: "SelectedPlant") // Save selection
    }
    
    
    
    
    
    // MARK: - CSV Data Handling
    @Published var plantInfoList: [PlantInfo] = []

    func loadPlantData() {
        guard let csvPath = getCSVPath() else {
            print("❌ Error: CSV file not found!")
            return
        }

        do {
            // ✅ Read CSV File Contents
            let data = try String(contentsOf: csvPath, encoding: .utf8)
            let rows = data.components(separatedBy: "\n").dropFirst() // ✅ Skip headers
            
            for row in rows {
                print("📄 CSV Row: \(row)")  // ✅ Debug print for each row
                
                let columns = parseCSVRow(row)
                print("🔍 Parsed Columns: \(columns)")  // ✅ Debug print for parsed values
                
                // ✅ Ensure exactly 9 fields per row
                if columns.count == 9 {
                    let plant = PlantInfo(
                        name: cleanValue(columns[0]),
                        scientificName: cleanValue(columns[1]),
                        commonNames: parseList(cleanValue(columns[2])),
                        commonUses: parseList(cleanValue(columns[3])),
                        region: parseList(cleanValue(columns[4])),
                        overview: cleanValue(columns[5]),
                        traditionalUses: cleanValue(columns[6]),
                        poison: cleanValue(columns[7]).isEmpty ? "No toxic effects reported." : cleanValue(columns[7]),
                        image: UIImage(named: cleanValue(columns[8])) ?? UIImage()
                    )
                    plantInfoList.append(plant)
                    
                    print("✅ Loaded Plant: \(plant.name)")
                } else {
                    print("⚠️ Skipping row due to incorrect column count: \(columns.count) -> \(row)")
                }
            }

            print("✅ Successfully loaded \(plantInfoList.count) plants!")

        } catch {
            print("❌ Error loading CSV: \(error.localizedDescription)")
        }
    }

    // MARK: - Helper Functions

    /// ✅ Cleans CSV values by trimming spaces and removing quotes
    func cleanValue(_ value: String?) -> String {
        guard let value = value else { return "Unknown" }
        return value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }

    /// ✅ Parses a comma-separated string into a **list of strings** (handles spaces properly)
    func parseList(_ value: String) -> [String] {
        return value
            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }

    /// ✅ Parses a CSV row while handling commas inside quotes
    func parseCSVRow(_ row: String) -> [String] {
        var result: [String] = []
        var insideQuotes = false
        var value = ""

        for char in row {
            if char == "\"" {
                insideQuotes.toggle()  // ✅ Toggle insideQuotes when encountering quotes
            } else if char == "," && !insideQuotes {
                result.append(value.trimmingCharacters(in: .whitespaces))  // ✅ Split only if outside quotes
                value = ""
            } else {
                value.append(char)
            }
        }

        if !value.isEmpty {
            result.append(value.trimmingCharacters(in: .whitespaces))
        }

        // ✅ Ensure exactly 9 columns (fill missing fields if necessary)
        while result.count < 9 {
            result.append("")
        }

        return result
    }

    /// ✅ Retrieves CSV file path from `Resources` in Playgrounds
    func getCSVPath() -> URL? {
        if let bundleCSV = Bundle.main.url(forResource: "plantyINFO", withExtension: "csv") {
            return bundleCSV
        } else {
            print("❌ No CSV found in Resources!")
            return nil
        }
    }
    
    // ✅ Search Plant by Name
    func searchPlant(by name: String) -> PlantInfo? {
        let lowercasedName = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return plantInfoList.first { $0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == lowercasedName }
    }
    
    
    //MARK: - search for location
    @Published var region: MKCoordinateRegion?
    @Published var isLoading = false
    
    func fetchCoordinates(for region: String) {
        guard !region.isEmpty else {
            print("❌ Error: Region string is empty.")
            return
        }
        
        print("🔍 Fetching coordinates for region: \(region)") // Debug print
        
        isLoading = true
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(region) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Geocoder error: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                
                if let location = placemarks?.first?.location {
                    self.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 15)
                    )
                    print("✅ Location found: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                } else {
                    print("⚠️ No location found for \(region)")
                }
                
                self.isLoading = false
            }
        }
    }
    
    //MARK: - to update the plant library
    @Published var savedPlants: [PlantLibraryItem] = []
    
    // MARK: - Plant Library Management
        func toggleSavePlant(_ plant: PlantInfo, image: UIImage) {
            if let index = savedPlants.firstIndex(where: { $0.plant.name == plant.name }) {
                savedPlants.remove(at: index) // ✅ Remove if already saved
            } else {
                let savedPlant = PlantLibraryItem(plant: plant, image: image) // ✅ Store with image
                savedPlants.append(savedPlant)
            }
        }

        func isPlantSaved(_ plant: PlantInfo) -> Bool {
            return savedPlants.contains(where: { $0.plant.name == plant.name })
        }
    
    
} // end of the vm


// MARK: - Text Box View (Reused Component)
struct TextBoxView: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("darkGreen"))
            
            Divider()
            
            Text(text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color("yellow"))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}





struct primaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Color("darkBlue")
            configuration.label
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .cornerRadius(16)
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .opacity(configuration.isPressed ? 0.8 : 1.0)
        .animation(.easeInOut, value: configuration.isPressed)
    }
}


struct secondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Color("lightGreen")
            configuration.label
                .font(.custom("Dosis-Bold", size: 20))
                .foregroundColor(Color("darkBlue"))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .cornerRadius(16)
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .opacity(configuration.isPressed ? 0.8 : 1.0)
        .animation(.easeInOut, value: configuration.isPressed)
    }
}



struct interfaceButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Color("lightGreen")
            configuration.label
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color("darkBlue"))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .cornerRadius(16)
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .opacity(configuration.isPressed ? 0.8 : 1.0)
        .animation(.easeInOut, value: configuration.isPressed)
    }
}


struct interface2Button: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Color("darkBlue")
            configuration.label
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .cornerRadius(16)
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .opacity(configuration.isPressed ? 0.8 : 1.0)
        .animation(.easeInOut, value: configuration.isPressed)
    }
}

struct interface3Button: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Color("yellow")
            configuration.label
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color("darkBlue"))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .cornerRadius(16)
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .opacity(configuration.isPressed ? 0.8 : 1.0)
        .animation(.easeInOut, value: configuration.isPressed)
    }
}
