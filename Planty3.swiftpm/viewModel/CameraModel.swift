//
//  CameraModel.swift
//  Planty
//
//  Created by Noori on 24/02/2025.
//

import AVFoundation
import UIKit
import Photos



@MainActor
class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var capturedImage: UIImage?
    private var session: AVCaptureSession?
    private var output = AVCapturePhotoOutput()
    @Published var isCameraAuthorized: Bool = false // 🔐 Track camera permission state
    
    @Published var sourceType: UIImagePickerController.SourceType? // ✅ Moved from View

    func selectSource(_ type: UIImagePickerController.SourceType) {
        self.sourceType = type
    }
    
    
    override init() {
        super.init()
        checkCameraAuthorization()
    }
    
    // ✅ Check Camera Authorization Status
    func checkCameraAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            isCameraAuthorized = true
            setupCamera()
        case .notDetermined:
            requestCameraPermissions()
        case .denied, .restricted:
            isCameraAuthorized = false
            print("❌ Camera access denied! Go to Settings > Privacy > Camera to enable access.")
        @unknown default:
            isCameraAuthorized = false
        }
    }
    
    // ✅ Request Camera Access
    func requestCameraPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.isCameraAuthorized = true
                    self.setupCamera()
                } else {
                    self.isCameraAuthorized = false
                    print("❌ Camera access denied! User must enable access in Settings.")
                }
            }
        }
    }
    
    // ✅ Setup Camera
    private func setupCamera() {
        guard isCameraAuthorized else {
            print("❌ Camera access is not authorized!")
            return
        }

        session = AVCaptureSession()
        guard let session = session,
              let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("❌ Camera setup failed!")
            return
        }

        session.beginConfiguration()
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
        session.commitConfiguration()
        session.startRunning()
    }

    // ✅ Capture Photo
    func capturePhoto() {
        guard let session = session, session.isRunning else {
            print("❌ Camera session is not running!")
            return
        }
        
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }

        DispatchQueue.main.async {
            self.capturedImage = image // ✅ Runs UI update on the main thread!
        }
    }
}
