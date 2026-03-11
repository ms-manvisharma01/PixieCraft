import SwiftUI


struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}


struct DynamicRowNumbersView: View {
    enum Side { case left, right }
    
    let side: Side
    let scrollOffsetY: CGFloat
    let scaledCellSize: CGFloat
    let totalRows: Int
    let viewportHeight: CGFloat
    let stripWidth: CGFloat
    
    var body: some View {
        Canvas { ctx, size in
            guard totalRows > 0, scaledCellSize > 0 else { return }
            
            let firstVisible = max(0, Int(scrollOffsetY / scaledCellSize))
            let visibleCount = Int(viewportHeight / scaledCellSize) + 2
            let lastVisible = min(totalRows - 1, firstVisible + visibleCount)
            
            guard firstVisible <= lastVisible else { return }
            
            let step: Int
            if scaledCellSize < 4 {
                step = 20
            } else if scaledCellSize < 8 {
                step = 10
            } else {
                step = 1
            }
            
            let fontSize = max(6, min(11, scaledCellSize * 0.45))
            let labelFont = Font.system(size: fontSize, weight: .regular, design: .monospaced)
            let labelColor = Color(white: 0.40)
            
            for rowIndex in firstVisible...lastVisible {
                let displayedRow = totalRows - rowIndex
                
                let isOdd = displayedRow % 2 == 1
                let isEven = displayedRow % 2 == 0
                let isFirst = rowIndex == firstVisible
                let isLast = rowIndex == lastVisible
                
                let shouldShow: Bool
                switch side {
                case .left:
                    shouldShow = (isFirst || isLast || (isOdd && rowIndex % step == 0))
                case .right:
                    shouldShow = (isFirst || isLast || (isEven && rowIndex % step == 0))
                }
                
                guard shouldShow else { continue }
                
                let cellY = CGFloat(rowIndex) * scaledCellSize - scrollOffsetY + scaledCellSize / 2
                
                let txt = Text("\(displayedRow)")
                    .font(labelFont)
                    .foregroundColor(labelColor)
                
                switch side {
                case .left:
                    ctx.draw(
                        ctx.resolve(txt),
                        at: CGPoint(x: stripWidth - 4, y: cellY),
                        anchor: .trailing
                    )
                case .right:
                    ctx.draw(
                        ctx.resolve(txt),
                        at: CGPoint(x: 4, y: cellY),
                        anchor: .leading
                    )
                }
            }
        }
        .frame(
            width: stripWidth,
            height: viewportHeight
        )
        .allowsHitTesting(false)
    }
}


struct DynamicColumnNumbersView: View {
    let scrollOffsetX: CGFloat
    let scaledCellSize: CGFloat
    let totalColumns: Int
    let viewportWidth: CGFloat
    let stripHeight: CGFloat
    
    var body: some View {
        Canvas { ctx, size in
            guard totalColumns > 0, scaledCellSize > 0 else { return }
            
            let firstVisible = max(0, Int(scrollOffsetX / scaledCellSize))
            let visibleCount = Int(viewportWidth / scaledCellSize) + 2
            let lastVisible = min(totalColumns - 1, firstVisible + visibleCount)
            
            guard firstVisible <= lastVisible else { return }
            
            let step: Int
            if scaledCellSize < 4 {
                step = 20
            } else if scaledCellSize < 8 {
                step = 10
            } else {
                step = 5
            }
            
            let fontSize = max(6, min(11, scaledCellSize * 0.45))
            let labelFont = Font.system(size: fontSize, weight: .regular, design: .monospaced)
            let labelColor = Color(white: 0.40)
            
            for colIndex in firstVisible...lastVisible {
                let displayedCol = colIndex + 1
                
                let isFirst = colIndex == firstVisible
                let isLast = colIndex == lastVisible
                let isStep = displayedCol % step == 0
                
                guard isFirst || isLast || isStep else { continue }
                
                let cellX = CGFloat(colIndex) * scaledCellSize - scrollOffsetX + scaledCellSize / 2
                
                let txt = Text("\(displayedCol)")
                    .font(labelFont)
                    .foregroundColor(labelColor)
                
                ctx.draw(
                    ctx.resolve(txt),
                    at: CGPoint(x: cellX, y: 3),
                    anchor: .top
                )
            }
        }
        .frame(
            width: viewportWidth,
            height: stripHeight
        )
        .allowsHitTesting(false)
    }
}
