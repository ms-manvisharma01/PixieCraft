import SwiftUI

struct MakeTogetherView: View {
    
    @EnvironmentObject var store: PatternStore
    @State private var selectedPattern: CrochetPattern? = nil
    
    var body: some View {
        ZStack {
            DS.appBG.ignoresSafeArea()
            
            if let pattern = selectedPattern {
                MakeTogetherSession(pattern: pattern, store: store, onEnd: {
                    withAnimation { selectedPattern = nil }
                })
            } else {
                patternPicker
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var patternPicker: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 44))
                    .foregroundColor(DS.appMainColor)
                    .padding(.top, 32)
                
                Text("Let's make something together")
                    .font(DS.heading(34))
                    .foregroundColor(DS.mainText)
                    .multilineTextAlignment(.center)
                
                Text("Choose a pattern and start your session")
                    .font(DS.body(16))
                    .foregroundColor(DS.secondaryText.opacity(0.6))
                    .padding(.bottom, 25)
                
                if store.patterns.isEmpty {
                    emptyState
                } else {
                    patternGrid
                }
                
                Spacer().frame(height: 40)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 36))
                .foregroundColor(DS.secondaryText.opacity(0.3))
            
            Text("No saved patterns yet")
                .font(DS.body(15))
                .foregroundColor(DS.secondaryText.opacity(0.5))
            
            Text("Create one using \"Create from Photo\" first!")
                .font(DS.caption(13))
                .foregroundColor(DS.secondaryText.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }
    
    private var patternGrid: some View {
        let columns = [
            GridItem(.flexible(minimum: 120), spacing: 14),
            GridItem(.flexible(minimum: 120), spacing: 14),
            GridItem(.flexible(minimum: 120), spacing: 14)
        ]
        
        return LazyVGrid(columns: columns, spacing: 14) {
            ForEach(store.patterns) { pattern in
                Button {
                    withAnimation { selectedPattern = pattern }
                } label: {
                    MakeTogetherPickerCard(pattern: pattern)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}


private struct MakeTogetherPickerCard: View {
    let pattern: CrochetPattern
    
    var body: some View {
        VStack(spacing: 16) {
            miniGrid
                .frame(maxWidth: .infinity)
                .aspectRatio(
                    CGFloat(pattern.width) / CGFloat(max(1, pattern.height)),
                    contentMode: .fit
                )
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(pattern.name)
                .font(DS.heading(16))
                .foregroundColor(DS.secondaryText)
                .lineLimit(1)
        }
        .padding(14)
        .cardStyle(color: Color.white.opacity(0.7))
    }
    
    private var miniGrid: some View {
        Canvas { ctx, size in
            let cols = pattern.width
            let rows = pattern.height
            guard cols > 0, rows > 0 else { return }
            let cellSize = min(size.width / CGFloat(cols), size.height / CGFloat(rows))
            let totalW = cellSize * CGFloat(cols)
            let totalH = cellSize * CGFloat(rows)
            let ox = (size.width - totalW) / 2
            let oy = (size.height - totalH) / 2
            for row in 0..<rows {
                for col in 0..<cols {
                    let idx = pattern.grid[row][col]
                    let safeIdx = max(0, min(idx, pattern.palette.count - 1))
                    let rect = CGRect(
                        x: ox + CGFloat(col) * cellSize,
                        y: oy + CGFloat(row) * cellSize,
                        width: cellSize, height: cellSize
                    )
                    ctx.fill(Path(rect), with: .color(pattern.palette[safeIdx].color))
                }
            }
        }
        .drawingGroup()
    }
}

#Preview {
    MakeTogetherView()
        .environmentObject(PatternStore())
}
