import SwiftUI

struct PatternPreviewView: View {
    
    @State var pattern: CrochetPattern
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private var stitchCounts: [Int] {
        GridRenderer.stitchCounts(for: pattern)
    }
    
    private let leftMargin: CGFloat = 30
    private let rightMargin: CGFloat = 30
    private let bottomMargin: CGFloat = 20
    
    var body: some View {
        ZStack {
            DS.appBG.ignoresSafeArea()
            
            GeometryReader { geo in
                let totalPad: CGFloat = 16  
                let coordWidth = leftMargin + rightMargin
                let availableWidth = geo.size.width - totalPad * 2 - coordWidth
                let availableHeight = geo.size.height * 0.62
                let patternAspect = CGFloat(pattern.width) / CGFloat(max(1, pattern.height))
                let gridW: CGFloat = min(availableWidth, (availableHeight - bottomMargin) * patternAspect)
                let gridH: CGFloat = gridW / patternAspect
                let finalW = min(gridW, availableWidth)
                let finalH = min(gridH, availableHeight - bottomMargin)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        Text(pattern.name)
                            .font(DS.heading(20))
                            .foregroundColor(DS.secondaryText)
                            .padding(.top, 6)
                        
                        HStack(spacing: 16) {
                            Label(pattern.sizeText, systemImage: "squareshape.split.3x3")
                                .font(DS.caption(13))
                                .foregroundColor(DS.secondaryText.opacity(0.7))
                            
                            Label(pattern.estimatedTimeText, systemImage: "clock")
                                .font(DS.caption(13))
                                .foregroundColor(DS.secondaryText.opacity(0.7))
                        }
                        .padding(.bottom, 2)
                        
                        gridWithCoordinates(gridW: finalW, gridH: finalH)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Text("Pinch to zoom | Rotate as per your image")
                            .font(DS.caption(11))
                            .foregroundColor(DS.secondaryText.opacity(0.35))
                            .padding(.top, 2)
                        
                        colorLegend
                            .padding(.top, 4)
                        
                        exportButton
                            .padding(.bottom, 16)
                            .padding(.top, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, totalPad)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func gridWithCoordinates(gridW: CGFloat, gridH: CGFloat) -> some View {
        let cols = pattern.width
        let rows = pattern.height
        let cellSize = cols > 0 && rows > 0
            ? min(gridW / CGFloat(cols), gridH / CGFloat(rows))
            : 1.0
        let actualW = cellSize * CGFloat(cols)
        let actualH = cellSize * CGFloat(rows)
        
        let totalW = leftMargin + actualW + rightMargin
        let totalH = actualH + bottomMargin
        
        return ZStack(alignment: .topLeading) {
            Canvas { ctx, size in
                guard rows > 0, cols > 0 else { return }
                let labelFont = Font.system(size: max(7, min(10, cellSize * 0.55)), weight: .regular, design: .monospaced)
                let labelColor = Color(white: 0.40)
                
                for rowIndex in 0..<rows {
                    let displayedRow = rows - rowIndex  // bottom-left origin
                    let cellY = CGFloat(rowIndex) * cellSize + cellSize / 2
                    
                    if displayedRow % 2 == 1 {
                        let txt = Text("\(displayedRow)")
                            .font(labelFont)
                            .foregroundColor(labelColor)
                        ctx.draw(
                            ctx.resolve(txt),
                            at: CGPoint(x: leftMargin - 5, y: cellY),
                            anchor: .trailing
                        )
                    } else {
                        let txt = Text("\(displayedRow)")
                            .font(labelFont)
                            .foregroundColor(labelColor)
                        ctx.draw(
                            ctx.resolve(txt),
                            at: CGPoint(x: leftMargin + actualW + 5, y: cellY),
                            anchor: .leading
                        )
                    }
                }
                
                for col in 0..<cols {
                    let displayedCol = col + 1  
                    let show = displayedCol == 1
                        || displayedCol == cols
                        || displayedCol % 5 == 0
                    guard show else { continue }
                    
                    let cellX = leftMargin + CGFloat(col) * cellSize + cellSize / 2
                    let txt = Text("\(displayedCol)")
                        .font(labelFont)
                        .foregroundColor(labelColor)
                    ctx.draw(
                        ctx.resolve(txt),
                        at: CGPoint(x: cellX, y: actualH + 4),
                        anchor: .top
                    )
                }
            }
            .frame(width: totalW, height: totalH)
            .allowsHitTesting(false)
            
            alphaGridCanvas(cellSize: cellSize, cols: cols, rows: rows)
                .frame(width: actualW, height: actualH)
                .offset(x: leftMargin, y: 0)
        }
        .frame(width: totalW, height: totalH)
        .scaleEffect(scale)
        .offset(offset)
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    scale = lastScale * value
                }
                .onEnded { _ in
                    lastScale = scale
                    scale = max(0.5, min(scale, 10.0))
                    lastScale = scale
                }
                .simultaneously(with:
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
        )
    }
    
    private func alphaGridCanvas(cellSize: CGFloat, cols: Int, rows: Int) -> some View {
        Canvas { ctx, size in
            guard cols > 0, rows > 0 else { return }
            
            for row in 0..<rows {
                for col in 0..<cols {
                    let idx = pattern.grid[row][col]
                    let safeIdx = max(0, min(idx, pattern.palette.count - 1))
                    let color = pattern.palette[safeIdx].color
                    let rect = CGRect(
                        x: CGFloat(col) * cellSize,
                        y: CGFloat(row) * cellSize,
                        width: cellSize,
                        height: cellSize
                    )
                    ctx.fill(Path(rect), with: .color(color))
                    
                    if cellSize >= 4 {
                        let inset: CGFloat = 0.5
                        let innerRect = rect.insetBy(dx: inset, dy: inset)
                        ctx.stroke(Path(innerRect), with: .color(Color.black.opacity(0.10)), lineWidth: 0.5)
                    }
                }
            }
            
            let minorColor = Color(white: 0.25).opacity(0.40)
            var minorPath = Path()
            for col in 0...cols {
                let x = CGFloat(col) * cellSize
                minorPath.move(to: CGPoint(x: x, y: 0))
                minorPath.addLine(to: CGPoint(x: x, y: CGFloat(rows) * cellSize))
            }
            for row in 0...rows {
                let y = CGFloat(row) * cellSize
                minorPath.move(to: CGPoint(x: 0, y: y))
                minorPath.addLine(to: CGPoint(x: CGFloat(cols) * cellSize, y: y))
            }
            ctx.stroke(minorPath, with: .color(minorColor), lineWidth: 0.75)
            
            let majorColor = Color(white: 0.15).opacity(0.55)
            var majorPath = Path()
            for col in stride(from: 0, through: cols, by: 5) {
                let x = CGFloat(col) * cellSize
                majorPath.move(to: CGPoint(x: x, y: 0))
                majorPath.addLine(to: CGPoint(x: x, y: CGFloat(rows) * cellSize))
            }
            for row in stride(from: 0, through: rows, by: 5) {
                let y = CGFloat(row) * cellSize
                majorPath.move(to: CGPoint(x: 0, y: y))
                majorPath.addLine(to: CGPoint(x: CGFloat(cols) * cellSize, y: y))
            }
            ctx.stroke(majorPath, with: .color(majorColor), lineWidth: 1.25)
        }
        .drawingGroup()
    }
    
    
    private var colorLegend: some View {
        let counts = stitchCounts
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Color Legend")
                .font(DS.heading(15))
                .foregroundColor(DS.secondaryText)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 155), spacing: 10)
            ], spacing: 8) {
                ForEach(Array(pattern.palette.enumerated()), id: \.offset) { index, color in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(color.color)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.gray.opacity(0.35), lineWidth: 0.8)
                            )
                        
                        Text("\(color.hex) (\(formattedCount(counts[index])))")
                            .font(.system(size: 11, weight: .regular, design: .monospaced))
                            .foregroundColor(DS.secondaryText.opacity(0.75))
                            .lineLimit(1)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.55))
        )
    }
    
    private func formattedCount(_ value: Int) -> String {
        DS.formatted(value)
    }
    
    
    private var exportButton: some View {
        Group {
            if let data = GridRenderer.renderPNGData(from: pattern),
               let uiImage = UIImage(data: data) {
                ShareLink(
                    item: Image(uiImage: uiImage),
                    preview: SharePreview(
                        pattern.name,
                        image: Image(uiImage: uiImage)
                    )
                ) {
                    Label("Export Pattern", systemImage: "square.and.arrow.up")
                        .primaryButton(color: DS.primaryCraft)
                }
            } else {
                Text("Export unavailable")
                    .font(DS.caption())
                    .foregroundColor(DS.secondaryText.opacity(0.5))
            }
        }
    }
}
