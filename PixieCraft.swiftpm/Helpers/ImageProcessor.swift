import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ImageProcessor {
    
    static func process(
        image: UIImage,
        gridSize: Int,
        maxColors: Int
    ) throws -> CrochetPattern {
        return try processSync(image: image, gridSize: gridSize, maxColors: maxColors)
    }
    
    private static func processSync(
        image: UIImage,
        gridSize: Int,
        maxColors: Int
    ) throws -> CrochetPattern {
        guard var ciImage = CIImage(image: image) else {
            throw ProcessingError.invalidImage
        }
        
        let extent = ciImage.extent
        if extent.width > 3000 || extent.height > 3000 {
            let safeScale = Float(min(3000 / extent.width, 3000 / extent.height))
            ciImage = applyLanczosScale(to: ciImage, scale: safeScale)
        }
        
        let imgW = ciImage.extent.width
        let imgH = ciImage.extent.height
        let aspectRatio = imgW / imgH
        
        let cols: Int
        let rows: Int
        if imgW >= imgH {
            cols = gridSize
            rows = max(1, Int(round(Double(gridSize) / aspectRatio)))
        } else {
            rows = gridSize
            cols = max(1, Int(round(Double(gridSize) * aspectRatio)))
        }
        
        let scaleX = Double(cols) / imgW
        let scaleY = Double(rows) / imgH
        let baseScale = Float(scaleY)
        let arParam = Float(scaleX / scaleY)
        let resized = applyLanczosScale(to: ciImage, scale: baseScale, aspectRatio: arParam)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(resized, from: CGRect(
            x: 0, y: 0,
            width: cols,
            height: rows
        )) else {
            throw ProcessingError.renderFailed
        }
        
        let pixels = extractPixels(from: cgImage, width: cols, height: rows)
        
        let (palette, assignments) = KMeans.run(
            pixels: pixels,
            k: maxColors,
            iterations: 6
        )
        
        let grid = buildGrid(assignments: assignments, width: cols, height: rows)
        
        return CrochetPattern(
            name: "My Pattern",
            grid: grid,
            palette: palette
        )
    }
    
    
    private static func applyLanczosScale(
        to image: CIImage,
        scale: Float,
        aspectRatio: Float = 1.0
    ) -> CIImage {
        guard let filter = CIFilter(name: "CILanczosScaleTransform") else {
            return image
        }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(NSNumber(value: scale), forKey: kCIInputScaleKey)
        filter.setValue(NSNumber(value: aspectRatio), forKey: kCIInputAspectRatioKey)
        return filter.outputImage ?? image
    }
    
    
    private static func extractPixels(
        from cgImage: CGImage,
        width: Int,
        height: Int
    ) -> [(r: Double, g: Double, b: Double)] {
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var rawData = [UInt8](repeating: 0, count: height * bytesPerRow)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return []
        }
        
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var pixels = [(r: Double, g: Double, b: Double)]()
        pixels.reserveCapacity(width * height)
        
        for i in 0..<(width * height) {
            let offset = i * bytesPerPixel
            let r = Double(rawData[offset])
            let g = Double(rawData[offset + 1])
            let b = Double(rawData[offset + 2])
            pixels.append((r: r, g: g, b: b))
        }
        
        return pixels
    }
    
    
    private static func buildGrid(assignments: [Int], width: Int, height: Int) -> [[Int]] {
        var grid = [[Int]]()
        grid.reserveCapacity(height)
        for row in 0..<height {
            let start = row * width
            let end = min(start + width, assignments.count)
            if start < assignments.count {
                grid.append(Array(assignments[start..<end]))
            }
        }
        return grid
    }
    
    
    enum ProcessingError: LocalizedError {
        case invalidImage
        case renderFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "Oops! That didn't work. Let's try another image "
            case .renderFailed:
                return "Something went wrong during processing. Let's try again!"
            }
        }
    }
}
