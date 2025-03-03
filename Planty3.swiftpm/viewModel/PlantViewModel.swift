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
    @Published var selectedPlant = PlantType .pothos // Default plant, can be "Pothos"
    
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
        checkMissedWatering()
        requestNotificationPermissions()
        scheduleWateringNotifications()
        requestNotificationPermissions()
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
                    print("⚠️ Second watering is not allowed yet! Wait for \(formattedTimeRemaining()).")
                    return
                }
            } else {
                print("❌ You've already watered the plant twice today!")
                return
            }

            print("🌱 Watering done! Current growth stage: \(growthStage), State: \(plantState)")
        }
    
    // MARK: - Start Watering Timer
        private func startWateringTimer() {
            timeRemaining = wateringInterval
            timerActive = true
            scheduleWateringNotification()
        }

        // MARK: - Update Countdown for Second Watering
        func checkWateringStatus() {
            if waterCount == 1, let lastWatered = lastWatered {
                let elapsedTime = Date().timeIntervalSince(lastWatered)
                timeRemaining = max(wateringInterval - elapsedTime, 0)

                if timeRemaining == 0 {
                    timerActive = false
                }
            }
        }
    
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
    
    func scheduleWateringNotifications() {
        let notificationTimes = ["09:00", "21:00"] // 9 AM and 9 PM (24-hour format)
        
        for time in notificationTimes {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            if let scheduledTime = formatter.date(from: time) {
                let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: scheduledTime)
                
                let content = UNMutableNotificationContent()
                content.title = "Time to Water Your Plant! 🌱"
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
        return "\(selectedPlant.rawValue) \(plantState) \(growthStage)" // Example: "Anthurium happy 3", "Pothos thirsty 5"
    }
    
    
    
    
    // MARK: - CSV Data Handling
    @Published var plantInfoList: [PlantInfo] = []
    
    // ✅ Load CSV Data in Playgrounds
    func loadPlantData() {
        guard let csvPath = getCSVPath() else {
            print("❌ Error: CSV file not found!")
            return
        }
        
        do {
            let data = try String(contentsOf: csvPath)
            let rows = data.components(separatedBy: "\n").dropFirst() // ✅ Skip headers
            
            for row in rows {
                let columns = row.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                
                if columns.count >= 8, columns[0].lowercased() != "folder name" { // ✅ Skip invalid rows
                    let plant = PlantInfo(
                        name: columns[0],
                        scientificName: columns[1],
                        commonUses: columns[2],
                        region: columns[3],
                        overview: columns[4],
                        trditionalUses: columns[5],
                        poisn: columns[6],
                        image: columns[8]
                    )
                    plantInfoList.append(plant)
                }
            }
            
            print("✅ Loaded \(plantInfoList.count) plants successfully!")
            
        } catch {
            print("❌ Error loading CSV: \(error.localizedDescription)")
        }
    }
    
    // ✅ Get CSV File Path
    func getCSVPath() -> URL? {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let csvPath = documentDirectory.appendingPathComponent("plantyINFO.csv")
        
        if !FileManager.default.fileExists(atPath: csvPath.path) {
            print("⚠️ CSV not found in Documents, trying to copy from Resources...")
            if let bundleCSV = Bundle.main.url(forResource: "plantyINFO", withExtension: "csv") {
                do {
                    try FileManager.default.copyItem(at: bundleCSV, to: csvPath)
                    print("✅ CSV copied to Documents successfully!")
                } catch {
                    print("❌ Failed to copy CSV to Documents: \(error.localizedDescription)")
                    return nil
                }
            } else {
                print("❌ No CSV found in Bundle!")
                return nil
            }
        }
        
        return csvPath
    }
    
    // ✅ Plant Search
    func searchPlant(by name: String) -> PlantInfo? {
        let lowercasedName = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return plantInfoList.first { $0.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == lowercasedName }
    }
    
    
    
}

//MARK: - image extension

extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let width = 360
        let height = 360
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         kCVPixelFormatType_32BGRA, attrs,
                                         &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let context = CGContext(data: pixelData, width: width, height: height,
                                bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return buffer
    }
}

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
