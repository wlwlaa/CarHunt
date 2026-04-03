import Foundation
import AVFoundation

final class CameraService: NSObject {
    let previewSession = AVCaptureSession()

    private var videoDevice: AVCaptureDevice?
    private var isConfigured = false

    func configureIfNeeded() {
        guard !isConfigured else { return }

        previewSession.beginConfiguration()
        previewSession.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ),
            let input = try? AVCaptureDeviceInput(device: device),
            previewSession.canAddInput(input)
        else {
            previewSession.commitConfiguration()
            return
        }

        videoDevice = device

        if previewSession.inputs.isEmpty {
            previewSession.addInput(input)
        }

        previewSession.commitConfiguration()
        isConfigured = true
    }

    func start() {
        guard !previewSession.isRunning else { return }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.previewSession.startRunning()
        }
    }

    func stop() {
        guard previewSession.isRunning else { return }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.previewSession.stopRunning()
        }
    }

    func setTorch(isOn: Bool) {
        guard let device = videoDevice, device.hasTorch else { return }

        do {
            try device.lockForConfiguration()

            if isOn {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            } else {
                device.torchMode = .off
            }

            device.unlockForConfiguration()
        } catch {
            print("Torch error: \(error.localizedDescription)")
        }
    }
}
