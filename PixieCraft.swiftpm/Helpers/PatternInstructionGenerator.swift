import SwiftUI

struct PatternInstructionGenerator {
   
    static func generateRowInstructions(from pattern: CrochetPattern) -> [RowInstruction] {
        let grid = pattern.grid
        let palette = pattern.palette
        
        guard !grid.isEmpty else { return [] }
        
        var rowInstructions: [RowInstruction] = []
        let totalRows = grid.count
        
        for (gridRowIndex, row) in grid.enumerated() {
            let displayRowNumber = totalRows - gridRowIndex
            
            let stitches = encodeRow(row, palette: palette)
            let rowInstruction = RowInstruction(
                rowNumber: displayRowNumber,
                stitches: stitches
            )
            rowInstructions.append(rowInstruction)
        }
        
        return rowInstructions.reversed()
    }
    
    private static func encodeRow(_ row: [Int], palette: [ColorData]) -> [StitchInstruction] {
        guard !row.isEmpty, !palette.isEmpty else { return [] }
        
        var stitches: [StitchInstruction] = []
        var currentColorIndex = row[0]
        var currentCount = 1
        
        for i in 1..<row.count {
            let colorIndex = row[i]
            if colorIndex == currentColorIndex {
                currentCount += 1
            } else {
                stitches.append(createStitchInstruction(
                    colorIndex: currentColorIndex,
                    count: currentCount,
                    palette: palette
                ))
                currentColorIndex = colorIndex
                currentCount = 1
            }
        }
        
        stitches.append(createStitchInstruction(
            colorIndex: currentColorIndex,
            count: currentCount,
            palette: palette
        ))
        
        return stitches
    }
    
    private static func createStitchInstruction(
        colorIndex: Int,
        count: Int,
        palette: [ColorData]
    ) -> StitchInstruction {
        let safeIndex = max(0, min(colorIndex, palette.count - 1))
        let colorData = palette[safeIndex]
        
        let friendlyName = ColorNamer.name(for: colorData)
        
        return StitchInstruction(
            color: colorData.color,
            colorHex: colorData.hex,
            colorName: friendlyName,
            count: count
        )
    }
}
