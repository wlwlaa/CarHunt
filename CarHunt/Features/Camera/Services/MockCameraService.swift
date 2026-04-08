import Foundation
import AVFoundation

final class MockCameraService: CameraServiceProtocol {
    let previewSession = AVCaptureSession()
    let requiresCameraAuthorization = false

    func configureIfNeeded() {}

    func start() {}

    func stop() {}

    func setTorch(isOn: Bool) {}

    func capturePhoto() async throws -> Data {
        try mockPhotoData()
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
