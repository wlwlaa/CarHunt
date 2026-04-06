import Foundation
import AVFoundation
import SwiftUI
import ImageIO

final class CameraService: NSObject {
    let previewSession = AVCaptureSession()

    private var videoDevice: AVCaptureDevice?
    private let photoOutput = AVCapturePhotoOutput()
    private var photoCaptureDelegate: PhotoCaptureDelegate?
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

        if previewSession.canAddOutput(photoOutput), previewSession.outputs.isEmpty {
            previewSession.addOutput(photoOutput)
            photoOutput.maxPhotoDimensions = .init(width: 3000, height: 4000)
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

    func capturePhoto() async throws -> Image {
        try await withCheckedThrowingContinuation { continuation in
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .off
            settings.maxPhotoDimensions = .init(width: 3000, height: 4000)

            let delegate = PhotoCaptureDelegate { result in
                self.photoCaptureDelegate = nil
                continuation.resume(with: result)
            }

            photoCaptureDelegate = delegate
            photoOutput.capturePhoto(with: settings, delegate: delegate)
        }
    }
}

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (Result<Image, Error>) -> Void

    init(completion: @escaping (Result<Image, Error>) -> Void) {
        self.completion = completion
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            completion(.failure(error))
            return
        }

        guard
            let data = photo.fileDataRepresentation(),
            let source = CGImageSourceCreateWithData(data as CFData, nil),
            let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else {
            completion(.failure(CameraCaptureError.invalidPhotoData))
            return
        }

        completion(.success(Image(decorative: cgImage, scale: 1)))
    }
}

private enum CameraCaptureError: LocalizedError {
    case invalidPhotoData

    var errorDescription: String? {
        switch self {
        case .invalidPhotoData:
            return "Failed to create image from captured photo."
        }
    }
}
