import UIKit
import SwiftUI

struct GridRenderer {
    
    static let pixelsPerStitch: CGFloat = 20
    
    static func stitchCounts(for pattern: CrochetPattern) -> [Int] {
        var counts = Array(repeating: 0, count: pattern.palette.count)
        for row in pattern.grid {
            for idx in row {
                let safe = max(0, min(idx, pattern.palette.count - 1))
                counts[safe] += 1
            }
        }
        return counts
    }
    
    static func renderExportImage(from pattern: CrochetPattern) -> UIImage? {
        let cellSize = pixelsPerStitch
        let cols = pattern.width
        let rows = pattern.height
        let gridWidth = CGFloat(cols) * cellSize
        let gridHeight = CGFloat(rows) * cellSize
        
        let padding: CGFloat = 40
        let coordMarginLeft: CGFloat = 36
        let coordMarginRight: CGFloat = 36
        let coordMarginBottom: CGFloat = 22
        let legendRowHeight: CGFloat = 44
        let legendSpacing: CGFloat = 20
        let infoHeight: CGFloat = 50
        
        let swatchSize: CGFloat = 24
        let swatchGap: CGFloat = 8
        let labelWidth: CGFloat = 140
        let itemWidth = swatchSize + swatchGap + labelWidth + 16
        let maxPerRow = max(1, Int(gridWidth / itemWidth))
        let legendRows = (pattern.palette.count + maxPerRow - 1) / maxPerRow
        let totalLegendHeight = CGFloat(legendRows) * legendRowHeight
        
        let totalWidth = gridWidth + coordMarginLeft + coordMarginRight + 2 * padding
        let totalHeight = gridHeight + coordMarginBottom + legendSpacing + totalLegendHeight + legendSpacing + infoHeight + 2 * padding
        
        let counts = stitchCounts(for: pattern)
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalWidth, height: totalHeight))
        
        return renderer.image { ctx in
            let cgCtx = ctx.cgContext
            
            UIColor(red: 255/255, green: 245/255, blue: 238/255, alpha: 1).setFill()
            cgCtx.fill(CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight))
            
            let gridOriginX = padding + coordMarginLeft
            let gridOriginY = padding
            
            for row in 0..<rows {
                for col in 0..<cols {
                    let colorIdx = pattern.grid[row][col]
                    let safeIdx = min(colorIdx, pattern.palette.count - 1)
                    let colorData = pattern.palette[max(0, safeIdx)]
                    
                    let rect = CGRect(
                        x: gridOriginX + CGFloat(col) * cellSize,
                        y: gridOriginY + CGFloat(row) * cellSize,
                        width: cellSize,
                        height: cellSize
                    )
                    
                    cgCtx.setFillColor(colorData.cgColor)
                    cgCtx.fill(rect)
                    
                    let inset: CGFloat = 0.5
                    let innerRect = rect.insetBy(dx: inset, dy: inset)
                    cgCtx.setStrokeColor(UIColor(white: 0, alpha: 0.12).cgColor)
                    cgCtx.setLineWidth(0.5)
                    cgCtx.stroke(innerRect)
                }
            }
            
            cgCtx.setStrokeColor(UIColor(white: 0.25, alpha: 0.40).cgColor)
            cgCtx.setLineWidth(0.75)
            for col in 0...cols {
                let x = gridOriginX + CGFloat(col) * cellSize
                cgCtx.move(to: CGPoint(x: x, y: gridOriginY))
                cgCtx.addLine(to: CGPoint(x: x, y: gridOriginY + gridHeight))
            }
            for row in 0...rows {
                let y = gridOriginY + CGFloat(row) * cellSize
                cgCtx.move(to: CGPoint(x: gridOriginX, y: y))
                cgCtx.addLine(to: CGPoint(x: gridOriginX + gridWidth, y: y))
            }
            cgCtx.strokePath()
            
            cgCtx.setStrokeColor(UIColor(white: 0.15, alpha: 0.55).cgColor)
            cgCtx.setLineWidth(1.25)
            for col in stride(from: 0, through: cols, by: 5) {
                let x = gridOriginX + CGFloat(col) * cellSize
                cgCtx.move(to: CGPoint(x: x, y: gridOriginY))
                cgCtx.addLine(to: CGPoint(x: x, y: gridOriginY + gridHeight))
            }
            for row in stride(from: 0, through: rows, by: 5) {
                let y = gridOriginY + CGFloat(row) * cellSize
                cgCtx.move(to: CGPoint(x: gridOriginX, y: y))
                cgCtx.addLine(to: CGPoint(x: gridOriginX + gridWidth, y: y))
            }
            cgCtx.strokePath()
            
            let labelFont = UIFont.monospacedSystemFont(ofSize: max(7, min(10, cellSize * 0.55)), weight: .regular)
            let labelColor = UIColor(white: 0.40, alpha: 1)
            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font: labelFont,
                .foregroundColor: labelColor
            ]
            
            for rowIndex in 0..<rows {
                let displayedRow = rows - rowIndex
                let centerY = gridOriginY + CGFloat(rowIndex) * cellSize + cellSize / 2
                let text = "\(displayedRow)" as NSString
                let sz = text.size(withAttributes: labelAttrs)
                
                if displayedRow % 2 == 1 {
                    
                    text.draw(
                        at: CGPoint(x: gridOriginX - sz.width - 4, y: centerY - sz.height / 2),
                        withAttributes: labelAttrs
                    )
                } else {
                    
                    text.draw(
                        at: CGPoint(x: gridOriginX + gridWidth + 4, y: centerY - sz.height / 2),
                        withAttributes: labelAttrs
                    )
                }
            }
            
            for col in 0..<cols {
                let displayedCol = col + 1
                let show = displayedCol == 1 || displayedCol == cols || displayedCol % 5 == 0
                guard show else { continue }
                
                let centerX = gridOriginX + CGFloat(col) * cellSize + cellSize / 2
                let text = "\(displayedCol)" as NSString
                let sz = text.size(withAttributes: labelAttrs)
                text.draw(
                    at: CGPoint(x: centerX - sz.width / 2, y: gridOriginY + gridHeight + 4),
                    withAttributes: labelAttrs
                )
            }
            
            let legendY = gridOriginY + gridHeight + coordMarginBottom + legendSpacing
            
            for (i, color) in pattern.palette.enumerated() {
                let rowIdx = i / maxPerRow
                let colIdx = i % maxPerRow
                
                let x = padding + CGFloat(colIdx) * itemWidth
                let y = legendY + CGFloat(rowIdx) * legendRowHeight
                
                let circleRect = CGRect(x: x, y: y + 8, width: swatchSize, height: swatchSize)
                cgCtx.setFillColor(color.cgColor)
                cgCtx.fillEllipse(in: circleRect)
                cgCtx.setStrokeColor(UIColor(white: 0.6, alpha: 0.5).cgColor)
                cgCtx.setLineWidth(0.8)
                cgCtx.strokeEllipse(in: circleRect)
                
                let count = i < counts.count ? counts[i] : 0
                let hexStr = "\(color.hex) (\(DS.formatted(count)))" as NSString
                let hexAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: UIColor(white: 0.3, alpha: 1)
                ]
                hexStr.draw(
                    at: CGPoint(x: x + swatchSize + swatchGap, y: y + 12),
                    withAttributes: hexAttrs
                )
            }
            
            let infoY = legendY + totalLegendHeight + legendSpacing
            let infoText = "\(pattern.sizeText)   \(pattern.estimatedTimeText)" as NSString
            let infoAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                .foregroundColor: UIColor(white: 0.35, alpha: 1)
            ]
            infoText.draw(at: CGPoint(x: padding, y: infoY), withAttributes: infoAttrs)
        }
    }
    
    static func renderPNGData(from pattern: CrochetPattern) -> Data? {
        guard let image = renderExportImage(from: pattern) else { return nil }
        return image.pngData()
    }
}
