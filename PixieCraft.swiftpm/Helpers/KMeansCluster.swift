import Foundation

struct KMeans {
    
    static func run(
        pixels: [(r: Double, g: Double, b: Double)],
        k: Int,
        iterations: Int = 6
    ) -> (palette: [ColorData], assignments: [Int]) {
        guard !pixels.isEmpty else {
            return ([], [])
        }
        
        let clampedK = min(k, pixels.count)
        
        var centroids = initializeCentroids(from: pixels, k: clampedK)
        var assignments = [Int](repeating: 0, count: pixels.count)
        
        for _ in 0..<iterations {
            for i in 0..<pixels.count {
                var bestDist = Double.greatestFiniteMagnitude
                var bestIdx = 0
                for j in 0..<centroids.count {
                    let d = distance(pixels[i], centroids[j])
                    if d < bestDist {
                        bestDist = d
                        bestIdx = j
                    }
                }
                assignments[i] = bestIdx
            }
            
            var sums = [(r: Double, g: Double, b: Double)](repeating: (0, 0, 0), count: centroids.count)
            var counts = [Int](repeating: 0, count: centroids.count)
            
            for i in 0..<pixels.count {
                let c = assignments[i]
                sums[c].r += pixels[i].r
                sums[c].g += pixels[i].g
                sums[c].b += pixels[i].b
                counts[c] += 1
            }
            
            for j in 0..<centroids.count {
                if counts[j] > 0 {
                    centroids[j] = (
                        r: sums[j].r / Double(counts[j]),
                        g: sums[j].g / Double(counts[j]),
                        b: sums[j].b / Double(counts[j])
                    )
                }
            }
        }
        
        let merged = mergeCentroids(centroids, assignments: &assignments)
        
        let (finalPalette, finalAssignments) = reindex(centroids: merged, assignments: assignments)
        
        return (finalPalette, finalAssignments)
    }
    
    
    private static func initializeCentroids(
        from pixels: [(r: Double, g: Double, b: Double)],
        k: Int
    ) -> [(r: Double, g: Double, b: Double)] {
        var result = [(r: Double, g: Double, b: Double)]()
        let step = max(1, pixels.count / k)
        for i in 0..<k {
            let index = min(i * step, pixels.count - 1)
            result.append(pixels[index])
        }
        return result
    }
    
    private static func distance(
        _ a: (r: Double, g: Double, b: Double),
        _ b: (r: Double, g: Double, b: Double)
    ) -> Double {
        let dr = a.r - b.r
        let dg = a.g - b.g
        let db = a.b - b.b
        return (dr * dr + dg * dg + db * db).squareRoot()
    }
    
    private static func mergeCentroids(
        _ centroids: [(r: Double, g: Double, b: Double)],
        assignments: inout [Int]
    ) -> [(r: Double, g: Double, b: Double)] {
        var merged = centroids
        let threshold: Double = 15.0
        
        var i = 0
        while i < merged.count {
            var j = i + 1
            while j < merged.count {
                if distance(merged[i], merged[j]) < threshold {
                    merged[i] = (
                        r: (merged[i].r + merged[j].r) / 2,
                        g: (merged[i].g + merged[j].g) / 2,
                        b: (merged[i].b + merged[j].b) / 2
                    )
                    for p in 0..<assignments.count {
                        if assignments[p] == j {
                            assignments[p] = i
                        } else if assignments[p] > j {
                            assignments[p] -= 1
                        }
                    }
                    merged.remove(at: j)
                } else {
                    j += 1
                }
            }
            i += 1
        }
        
        return merged
    }
    
    private static func reindex(
        centroids: [(r: Double, g: Double, b: Double)],
        assignments: [Int]
    ) -> (palette: [ColorData], assignments: [Int]) {
        let palette = centroids.map { ColorData(r: $0.r, g: $0.g, b: $0.b) }
        return (palette, assignments)
    }
}
