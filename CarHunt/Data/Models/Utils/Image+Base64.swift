import Foundation
import SwiftUI
import ImageIO

private enum ImageMemoryPolicy {
    static let cacheCostLimit = 48 * 1024 * 1024
    static let cacheCountLimit = 120
    static let defaultMaxPixelSize: CGFloat = 1_280
}

private final class DecodedImageCache {
    static let shared = DecodedImageCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.totalCostLimit = ImageMemoryPolicy.cacheCostLimit
        cache.countLimit = ImageMemoryPolicy.cacheCountLimit
    }

    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func store(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString, cost: image.memoryCost)
    }
}

extension Image {
    static func fromData(
        _ data: Data,
        fallbackSystemName: String = "car.fill",
        maxPixelSize: CGFloat = ImageMemoryPolicy.defaultMaxPixelSize
    ) -> Image {
        let cacheKey = "data:\(data.count):\(data.hashValue):\(Int(maxPixelSize))"

        if let cached = DecodedImageCache.shared.image(forKey: cacheKey) {
            return Image(uiImage: cached)
        }

        guard let image = downsampledImage(from: data, maxPixelSize: maxPixelSize) else {
            return Image(systemName: fallbackSystemName)
        }

        DecodedImageCache.shared.store(image, forKey: cacheKey)
        return Image(uiImage: image)
    }

    static func fromBase64(
        _ base64: String,
        fallbackSystemName: String = "car.fill",
        maxPixelSize: CGFloat = ImageMemoryPolicy.defaultMaxPixelSize
    ) -> Image {
        let normalizedBase64 = normalized(base64)
        let cacheKey = "base64:\(normalizedBase64.count):\(normalizedBase64.hashValue):\(Int(maxPixelSize))"

        if let cached = DecodedImageCache.shared.image(forKey: cacheKey) {
            return Image(uiImage: cached)
        }

        guard
            let data = Data(base64Encoded: normalizedBase64, options: [.ignoreUnknownCharacters]),
            let image = downsampledImage(from: data, maxPixelSize: maxPixelSize)
        else {
            return Image(systemName: fallbackSystemName)
        }

        DecodedImageCache.shared.store(image, forKey: cacheKey)
        return Image(uiImage: image)
    }

    private static func downsampledImage(from data: Data, maxPixelSize: CGFloat) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCache: false,
            kCGImageSourceShouldCacheImmediately: false,
            kCGImageSourceThumbnailMaxPixelSize: max(1, Int(maxPixelSize))
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    private static func normalized(_ base64: String) -> String {
        if base64.starts(with: "data:image"),
           let commaIndex = base64.firstIndex(of: ",") {
            return String(base64[base64.index(after: commaIndex)...])
        }

        return base64
    }
}

extension Data {
    func asImage() -> Image {
        Image.fromData(self)
    }
}

private extension UIImage {
    var memoryCost: Int {
        if let cgImage {
            return cgImage.bytesPerRow * cgImage.height
        }

        let pixelWidth = size.width * scale
        let pixelHeight = size.height * scale
        return Int(pixelWidth * pixelHeight * 4)
    }
}
