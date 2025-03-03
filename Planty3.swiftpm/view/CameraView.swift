//
//  CameraView.swift
//  Planty3
//
//  Created by Noori on 25/02/2025.
//


//
//  CameraView.swift
//  Planty3
//
//  Created by Noori on 24/02/2025.
//

import SwiftUI
import UIKit
import Vision

struct CameraView: View {
    @EnvironmentObject private var cameraModel: CameraModel
    @EnvironmentObject var plantyVM: PlantViewModel
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType? = .camera
    @State private var classificationResult: String = "Waiting for classification..."
    @State private var classificationResult2: String = ""
    @State private var selectedPlant: PlantInfo?
    @State private var navigateToDetail = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                    
                // 📸 Display Selected Image
                if let image = cameraModel.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(16)
                    
                    Text(classificationResult)
                        .font(.title3)
                        .foregroundColor(.green)
                        .padding()
                } else {
                    Image("nomiCircle2") // Placeholder image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                }
                
                Spacer()
                
                Button(action: {
                    sourceType = .photoLibrary
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isImagePickerPresented = true
                        }
                }) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(interface2Button())
                
                
                Button(action: {
                    sourceType = .camera
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isImagePickerPresented = true
                        }
                }) {
                    Label("Open Camera", systemImage: "camera")
                }
                .buttonStyle(interface2Button())
                
                
                // ⚡ Classify Image Button
                if cameraModel.capturedImage != nil {
                    Button(action: {
                        classifyImage(image: cameraModel.capturedImage)
                    }) {
                        Text("Classify Image")
                    }
                    .buttonStyle(interface3Button())
                    .padding(.top, 10)
                    
                }
                
                Spacer()
            }
            .padding()
            .fullScreenCover(isPresented: $isImagePickerPresented) {
                if let selectedSourceType = sourceType {
                    ImagePicker(image: $cameraModel.capturedImage, sourceType: selectedSourceType)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Text("⚠️ Error: No source type selected!")
                        .foregroundColor(.red)
                        .font(.headline)
                }
            }
            .navigationDestination(isPresented: $navigateToDetail) { // ✅ Fix: Use `navigationDestination`
                if let plant = selectedPlant, let capturedImage = cameraModel.capturedImage {
                   PlantDetailView(plant: plant, plantImage: capturedImage)
                       .environmentObject(plantyVM)
                       .environmentObject(cameraModel)
               }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Choose a Photo")
                        .font(.system(size: 29, weight: .bold))
                        .foregroundColor(Color("darkGreen"))
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
    }
    
    // 🧠 CoreML Classification
    private func classifyImage(image: UIImage?) {
        guard let image = image, let ciImage = CIImage(image: image) else {
            classificationResult = "❌ No valid image found!"
            return
        }

        // ✅ Locate ML model in the Resources folder
        guard let modelURL = Bundle.main.url(forResource: "PlantyClassification", withExtension: "mlmodelc") else {
            classificationResult = "❌ ERROR: Model file not found in bundle!"
            return
        }

        do {
            let compiledModel = try MLModel(contentsOf: modelURL)
            let visionModel = try VNCoreMLModel(for: compiledModel)

            let request = VNCoreMLRequest(model: visionModel) { request, error in
                if let results = request.results as? [VNClassificationObservation], let topResult = results.first {
                    let classifiedPlantName = topResult.identifier
                    classificationResult = "🌱 Plant: \(classifiedPlantName)"
                    classificationResult2 =  "🌱 Plant: \(classifiedPlantName) (\(Int(topResult.confidence * 100))%)"
                    print("✅ Classified Plant: \(classificationResult2)")

                    // 🔍 Search for plant in CSV
                    if let plant = plantyVM.searchPlant(by: classifiedPlantName) {
                        DispatchQueue.main.async {
                            self.selectedPlant = plant
                            self.navigateToDetail = true // ✅ Fix: Ensure Navigation Works
                            print("✅ Navigation set to TRUE")
                        }
                    } else {
                        print("⚠️ No matching plant found in CSV")
                    }
                } else {
                    classificationResult = "⚠️ No classification found"
                }
            }

            let handler = VNImageRequestHandler(ciImage: ciImage)
            try handler.perform([request])

        } catch {
            classificationResult = "⚠️ Error running classification: \(error.localizedDescription)"
        }
    }
}

#Preview {
    CameraView()
        .environmentObject(CameraModel())
        .environmentObject(PlantViewModel())
}
