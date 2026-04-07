import Foundation
import AVFoundation
import Combine
import SwiftUI

final class CameraViewModel: ObservableObject {
    let cameraService = CameraService()

    @Published var isTorchOn = false

    private var didSetupCamera = false
    private let router: any AppRouting

    init(router: any AppRouting) {
        self.router = router
    }

    func setupCameraIfNeeded() {
        guard !didSetupCamera else { return }
        didSetupCamera = true
        checkPermissionAndConfigure()
    }

    func startCamera() {
        cameraService.start()
    }

    func stopCamera() {
        cameraService.stop()
    }

    func capturePhoto() {
        router.present(.cardSettings)
    }

    func toggleTorch() {
        isTorchOn.toggle()
        cameraService.setTorch(isOn: isTorchOn)
    }

    func turnTorchOff() {
        isTorchOn = false
        cameraService.setTorch(isOn: false)
    }

    private func checkPermissionAndConfigure() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraService.configureIfNeeded()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }

                DispatchQueue.main.async {
                    self?.cameraService.configureIfNeeded()
                    self?.cameraService.start()
                }
            }

        case .denied, .restricted:
            print("Camera access denied")

        @unknown default:
            break
        }
    }
}
