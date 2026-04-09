import Foundation
import AVFoundation
import Combine

@MainActor
final class CameraViewModel: ObservableObject {
    let cameraService: any CameraServiceProtocol
    private let router: any AppRouting

    @Published var isTorchOn = false

    private var didSetupCamera = false
    
    init(router: any AppRouting) {
        self.router = router

#if targetEnvironment(simulator)
        self.cameraService = MockCameraService()
#else
        self.cameraService = CameraService()
#endif
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
        Task {
            do {
                let photoData = try await cameraService.capturePhoto()
                router.presentCardSettings(
                    with: .draft(withPhotoData: photoData),
                    draftDataModel: .draft(withPhotoData: photoData),
                    photoData: photoData
                )
            } catch {
                print("Photo capture error: \(error.localizedDescription)")
            }
        }
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
        guard cameraService.requiresCameraAuthorization else {
            cameraService.configureIfNeeded()
            cameraService.start()
            return
        }

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
