import SwiftUI

struct StitchInstruction: Identifiable {
    let id = UUID()
    let color: Color
    let colorHex: String
    let colorName: String
    let count: Int
    var isCompleted: Bool = false
    
    var description: String {
        let stitchWord = count == 1 ? "stitch" : "stitches"
        return "\(count) \(stitchWord) of \(colorName)"
    }
}
