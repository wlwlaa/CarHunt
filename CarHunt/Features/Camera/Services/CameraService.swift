import Foundation
import AVFoundation

final class CameraService: NSObject {
    enum CaptureMode {
        case live
        case mock
    }

    let previewSession = AVCaptureSession()
    var captureMode: CaptureMode = {
#if targetEnvironment(simulator)
        .mock
#else
        .live
#endif
    }()

    private let sessionQueue = DispatchQueue(label: "CameraService.sessionQueue", qos: .userInitiated)
    private var videoDevice: AVCaptureDevice?
    private let photoOutput = AVCapturePhotoOutput()
    private var photoCaptureDelegate: PhotoCaptureDelegate?
    private var isConfigured = false

    func configureIfNeeded() {
        sessionQueue.async { [weak self] in
            self?.configureSessionIfNeeded()
        }
    }

    func start() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.configureSessionIfNeeded()
            guard !self.previewSession.isRunning else { return }
            self.previewSession.startRunning()
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, self.previewSession.isRunning else { return }
            self.previewSession.stopRunning()
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

    func capturePhoto() async throws -> Data {
        if captureMode == .mock {
            return try mockPhotoData()
        }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            sessionQueue.async { [weak self] in
                guard let self else {
                    continuation.resume(throwing: CameraCaptureError.invalidPhotoData)
                    return
                }

                self.configureSessionIfNeeded()

                if !self.isConfigured {
                    continuation.resume(throwing: CameraCaptureError.sessionNotConfigured)
                    return
                }

                if !self.previewSession.isRunning {
                    self.previewSession.startRunning()
                }

                guard let connection = self.photoOutput.connection(with: .video), connection.isEnabled, connection.isActive else {
                    continuation.resume(throwing: CameraCaptureError.videoConnectionUnavailable)
                    return
                }

                let settings = AVCapturePhotoSettings()
                settings.flashMode = .off
                settings.maxPhotoDimensions = .init()

                let delegate = PhotoCaptureDelegate { result in
                    self.photoCaptureDelegate = nil
                    continuation.resume(with: result)
                }

                self.photoCaptureDelegate = delegate
                self.photoOutput.capturePhoto(with: settings, delegate: delegate)
            }
        }
    }

    private func configureSessionIfNeeded() {
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

        if previewSession.canAddOutput(photoOutput), photoOutput.connection(with: .video) == nil {
            previewSession.addOutput(photoOutput)
            photoOutput.maxPhotoDimensions = .init()
        }

        previewSession.commitConfiguration()
        isConfigured = true
    }

    private func mockPhotoData() throws -> Data {
        let mockBase64Images = ["bmw", "alfa", "ford", "lotus", "porsche", "ram"]
            .compactMap(loadMockBase64(named:))

        guard
            let selectedBase64 = mockBase64Images.randomElement(),
            let data = Data(base64Encoded: normalizedBase64(selectedBase64), options: [.ignoreUnknownCharacters])
        else {
            throw CameraCaptureError.mockPhotoUnavailable
        }

        return data
    }

    private func loadMockBase64(named resourceName: String) -> String? {
        let url =
            Bundle.main.url(forResource: resourceName, withExtension: "base64", subdirectory: "MockBase64")
            ?? Bundle.main.url(forResource: resourceName, withExtension: "base64", subdirectory: "Resources/MockBase64")
            ?? Bundle.main.url(forResource: resourceName, withExtension: "base64")

        guard let url,
              let value = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }

        return value.components(separatedBy: .whitespacesAndNewlines).joined()
    }

    private func normalizedBase64(_ base64: String) -> String {
        if base64.starts(with: "data:image"),
           let commaIndex = base64.firstIndex(of: ",") {
            return String(base64[base64.index(after: commaIndex)...])
        }

        return base64
    }
}

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (Result<Data, Error>) -> Void

    init(completion: @escaping (Result<Data, Error>) -> Void) {
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
            let data = photo.fileDataRepresentation()
        else {
            completion(.failure(CameraCaptureError.invalidPhotoData))
            return
        }

        completion(.success(data))
    }
}

private enum CameraCaptureError: LocalizedError {
    case invalidPhotoData
    case sessionNotConfigured
    case videoConnectionUnavailable
    case mockPhotoUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidPhotoData:
            return "Failed to create image from captured photo."
        case .sessionNotConfigured:
            return "Camera session is not configured yet."
        case .videoConnectionUnavailable:
            return "Camera video connection is unavailable."
        case .mockPhotoUnavailable:
            return "Mock photo data is unavailable."
        }
    }
}
