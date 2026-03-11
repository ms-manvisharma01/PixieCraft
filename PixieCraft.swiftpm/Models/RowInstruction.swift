import SwiftUI

struct RowInstruction: Identifiable {
    let id = UUID()
    let rowNumber: Int  // 1-based for display
    var stitches: [StitchInstruction]
    
    var totalStitches: Int {
        stitches.reduce(0) { $0 + $1.count }
    }
    
    var completedGroups: Int {
        stitches.filter { $0.isCompleted }.count
    }
    
    var isCompleted: Bool {
        !stitches.isEmpty && stitches.allSatisfy { $0.isCompleted }
    }
    
    var progress: Double {
        guard !stitches.isEmpty else { return 0 }
        return Double(completedGroups) / Double(stitches.count)
    }
    
    func explain() -> String {
        guard !stitches.isEmpty else { return "This row is empty." }
        
        var parts: [String] = []
        for (index, stitch) in stitches.enumerated() {
            let stitchWord = stitch.count == 1 ? "stitch" : "stitches"
            if index == 0 {
                parts.append("Start with \(stitch.count) \(stitchWord) of \(stitch.colorName)")
            } else if index == stitches.count - 1 {
                parts.append("finish with \(stitch.count) \(stitchWord) of \(stitch.colorName)")
            } else {
                parts.append("then \(stitch.count) \(stitchWord) of \(stitch.colorName)")
            }
        }
        
        if parts.count == 1 {
            return parts[0] + "."
        } else if parts.count == 2 {
            return parts[0] + ", " + parts[1] + "."
        } else {
            let allButLast = parts.dropLast().joined(separator: ", ")
            return allButLast + ", " + parts.last! + "."
        }
    }
}
