import Foundation
import AVFoundation
import CoreLocation
import ImageIO

protocol CameraServiceProtocol: AnyObject {
    var previewSession: AVCaptureSession { get }
    var requiresCameraAuthorization: Bool { get }

    func configureIfNeeded()
    func start()
    func stop()
    func setTorch(isOn: Bool)
    func capturePhoto() async throws -> Data
}

final class CameraService: NSObject, CameraServiceProtocol {
    let requiresCameraAuthorization = true

    let previewSession = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "CameraService.sessionQueue", qos: .userInitiated)
    private var videoDevice: AVCaptureDevice?
    private let photoOutput = AVCapturePhotoOutput()
    private var photoCaptureDelegate: PhotoCaptureDelegate?
    private let locationManager = CLLocationManager()
    private let locationLock = NSLock()
    private var latestLocation: CLLocation?
    private var isConfigured = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 25
    }

    func configureIfNeeded() {
        sessionQueue.async { [weak self] in
            self?.configureSessionIfNeeded()
        }
    }

    func start() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.configureSessionIfNeeded()
            self.configureLocationIfNeeded()
            guard !self.previewSession.isRunning else { return }
            self.previewSession.startRunning()
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.previewSession.isRunning {
                self.previewSession.stopRunning()
            }
            DispatchQueue.main.async { [weak self] in
                self?.locationManager.stopUpdatingLocation()
            }
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

                self.configureLocationIfNeeded()
                self.requestSingleLocationIfPossible()

                guard let connection = self.photoOutput.connection(with: .video), connection.isEnabled, connection.isActive else {
                    continuation.resume(throwing: CameraCaptureError.videoConnectionUnavailable)
                    return
                }

                let settings = AVCapturePhotoSettings()
                settings.flashMode = .off
                
                // settings.maxPhotoDimensions = .init()

                let delegate = PhotoCaptureDelegate { result in
                    self.photoCaptureDelegate = nil
                    switch result {
                    case .success(let data):
                        let photoDataWithLocation = self.photoDataByAppendingGPSMetadata(
                            to: data,
                            location: self.currentLocation
                        )
                        continuation.resume(returning: photoDataWithLocation)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
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
            
            // photoOutput.maxPhotoDimensions = .init()
        }

        previewSession.commitConfiguration()
        isConfigured = true
    }

    private var currentLocation: CLLocation? {
        locationLock.lock()
        defer { locationLock.unlock() }
        return latestLocation
    }

    private func setLatestLocation(_ location: CLLocation) {
        locationLock.lock()
        latestLocation = location
        locationLock.unlock()
    }

    private func configureLocationIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard CLLocationManager.locationServicesEnabled() else { return }

            switch self.locationManager.authorizationStatus {
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.startUpdatingLocation()
            case .denied, .restricted:
                break
            @unknown default:
                break
            }
        }
    }

    private func requestSingleLocationIfPossible() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch self.locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.requestLocation()
            default:
                break
            }
        }
    }

    private func photoDataByAppendingGPSMetadata(to photoData: Data, location: CLLocation?) -> Data {
        guard let location else { return photoData }
        guard
            let source = CGImageSourceCreateWithData(photoData as CFData, nil),
            let sourceType = CGImageSourceGetType(source),
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        else {
            return photoData
        }

        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(mutableData, sourceType, 1, nil) else {
            return photoData
        }

        var updatedProperties = imageProperties
        var gpsDictionary = (imageProperties[kCGImagePropertyGPSDictionary] as? [CFString: Any]) ?? [:]
        let coordinate = location.coordinate

        gpsDictionary[kCGImagePropertyGPSLatitude] = abs(coordinate.latitude)
        gpsDictionary[kCGImagePropertyGPSLatitudeRef] = coordinate.latitude >= 0 ? "N" : "S"
        gpsDictionary[kCGImagePropertyGPSLongitude] = abs(coordinate.longitude)
        gpsDictionary[kCGImagePropertyGPSLongitudeRef] = coordinate.longitude >= 0 ? "E" : "W"
        gpsDictionary[kCGImagePropertyGPSAltitude] = abs(location.altitude)
        gpsDictionary[kCGImagePropertyGPSAltitudeRef] = location.altitude < 0 ? 1 : 0

        updatedProperties[kCGImagePropertyGPSDictionary] = gpsDictionary

        CGImageDestinationAddImageFromSource(destination, source, 0, updatedProperties as CFDictionary)
        guard CGImageDestinationFinalize(destination) else {
            return photoData
        }

        return mutableData as Data
    }
}

extension CameraService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            manager.stopUpdatingLocation()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        setLatestLocation(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
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

enum CameraCaptureError: LocalizedError {
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
