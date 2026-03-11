import SwiftUI

struct MakeTogetherSession: View {
    
    let pattern: CrochetPattern
    let store: PatternStore
    let onEnd: () -> Void
    
    private let totalDuration: Double = 3600
    private let checkpoints: [Double] = [1200, 2400, 3600]
    
    private let leftMargin: CGFloat = 28
    private let rightMargin: CGFloat = 28
    private let baseCellSize: CGFloat = 20
    
    @State private var markedRow: Int? = nil
    @State private var markedCol: Int? = nil
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    @State private var hasSetInitialView = false
    
    @State private var scrollOffset: CGPoint = .zero
    
    @State private var sessionStart: Date? = nil
    @State private var elapsed: Double = 0
    @State private var pauseOffset: Double = 0
    @State private var pauseStart: Date? = nil
    @State private var isPaused = false
    @State private var showReminder = false
    @State private var nextCheckpointIdx = 0
    @State private var reminderMessage = ""
    @State private var reminderButton = ""
    @State private var isFinalReminder = false
    @State private var posturePulse = false
    @State private var timer: Timer? = nil
    
    private var stitchCounts: [Int] {
        GridRenderer.stitchCounts(for: pattern)
    }
    
    var body: some View {
        ZStack {
            DS.appBG.ignoresSafeArea()
            
            VStack(spacing: 0) {
                patternDisplay
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Text(timeString(elapsed))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(DS.secondaryText)
                    .padding(.bottom, 8)
                
                if !showReminder {
                    yarnTimeSlider
                        .padding(.horizontal, 32)
                        .padding(.bottom, 12)
                }
                
                if !showReminder {
                    sessionColorLegend
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
            }
            
            if showReminder {
                reminderOverlay
            }
        }
        .onAppear {
            markedRow = pattern.lastMarkedRow
            markedCol = pattern.lastMarkedColumn
            startSession()
        }
        .onDisappear { stopTimer() }
    }
    
    
    
    private var patternDisplay: some View {
        GeometryReader { geo in
            let cols = pattern.width
            let rows = pattern.height
            let scaledCell = baseCellSize * scale
            let scaledGridW = scaledCell * CGFloat(cols)
            let scaledGridH = scaledCell * CGFloat(rows)
            
            let viewportW = geo.size.width
            let viewportH = geo.size.height
            
            let bottomBarHeight: CGFloat = 32
            
            let gridViewW = viewportW - leftMargin - rightMargin
            let gridViewH = viewportH - bottomBarHeight
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    DynamicRowNumbersView(
                        side: .left,
                        scrollOffsetY: scrollOffset.y,
                        scaledCellSize: scaledCell,
                        totalRows: rows,
                        viewportHeight: gridViewH,
                        stripWidth: leftMargin
                    )
                    .background(DS.appBG.opacity(0.85))
                    
                    ScrollViewReader { proxy in
                        ScrollView([.horizontal, .vertical], showsIndicators: false) {
                            ZStack(alignment: .topLeading) {
                                GeometryReader { inner in
                                    Color.clear
                                        .preference(
                                            key: ScrollOffsetPreferenceKey.self,
                                            value: CGPoint(
                                                x: -inner.frame(in: .named("gridScroll")).origin.x,
                                                y: -inner.frame(in: .named("gridScroll")).origin.y
                                            )
                                        )
                                }
                                .frame(width: 0, height: 0)
                                
                                sessionGridCanvas(cellSize: scaledCell, cols: cols, rows: rows)
                                    .frame(width: scaledGridW, height: scaledGridH)
                                    .id("gridCanvas")
                                
                                if let mRow = markedRow, let mCol = markedCol,
                                   mRow >= 0, mRow < rows, mCol >= 0, mCol < cols {
                                    let pinSize: CGFloat = max(16, min(28, scaledCell * 0.8))
                                    Text("📍")
                                        .font(.system(size: pinSize))
                                        .offset(
                                            x: CGFloat(mCol) * scaledCell + scaledCell / 2 - pinSize / 2,
                                            y: CGFloat(mRow) * scaledCell + scaledCell / 2 - pinSize / 2
                                        )
                                        .allowsHitTesting(false)
                                }
                                
                                Color.clear
                                    .frame(width: 1, height: 1)
                                    .offset(x: 0, y: scaledGridH - gridViewH)
                                    .id("bottomLeft")
                                
                                Color.clear
                                    .frame(width: scaledGridW, height: scaledGridH)
                                    .contentShape(Rectangle())
                                    .onTapGesture { location in
                                        let col = Int(location.x / scaledCell)
                                        let row = Int(location.y / scaledCell)
                                        guard col >= 0, col < cols, row >= 0, row < rows else { return }
                                        markedRow = row
                                        markedCol = col
                                        persistMarker(row: row, col: col)
                                    }
                            }
                            .frame(width: scaledGridW, height: scaledGridH)
                            .contentShape(Rectangle())
                        }
                        .coordinateSpace(name: "gridScroll")
                        .frame(width: gridViewW, height: gridViewH)
                        .clipped()
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            scrollOffset = value
                        }
                        .simultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale = max(0.25, min(6.0, scale * delta))
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                }
                        )
                        .onAppear {
                            guard !hasSetInitialView else { return }
                            
                            let scaleToFitWidth = gridViewW / (baseCellSize * CGFloat(cols))
                            let scaleToFitHeight = gridViewH / (baseCellSize * CGFloat(rows))
                            let fitScale = min(scaleToFitWidth, scaleToFitHeight, 1.0)
                            
                            scale = fitScale * 0.95
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo("bottomLeft", anchor: .topLeading)
                                }
                                hasSetInitialView = true
                            }
                        }
                    }
                    
                    DynamicRowNumbersView(
                        side: .right,
                        scrollOffsetY: scrollOffset.y,
                        scaledCellSize: scaledCell,
                        totalRows: rows,
                        viewportHeight: gridViewH,
                        stripWidth: rightMargin
                    )
                    .background(DS.appBG.opacity(0.85))
                }
                
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: leftMargin)
                    
                    DynamicColumnNumbersView(
                        scrollOffsetX: scrollOffset.x,
                        scaledCellSize: scaledCell,
                        totalColumns: cols,
                        viewportWidth: gridViewW,
                        stripHeight: bottomBarHeight
                    )
                    .background(DS.appBG.opacity(0.85))
                    
                    Spacer()
                        .frame(width: rightMargin)
                }
                .frame(height: bottomBarHeight)
            }
            .frame(width: viewportW, height: viewportH)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
    
    private func persistMarker(row: Int, col: Int) {
        var updated = pattern
        updated.lastMarkedRow = row
        updated.lastMarkedColumn = col
        store.update(updated)
    }
    
    private func removeMarker() {
        markedRow = nil
        markedCol = nil
        var updated = pattern
        updated.lastMarkedRow = nil
        updated.lastMarkedColumn = nil
        store.update(updated)
    }
    
    private func sessionGridCanvas(cellSize: CGFloat, cols: Int, rows: Int) -> some View {
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
    
    private var sessionColorLegend: some View {
        let counts = stitchCounts
        
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Color Legend")
                    .font(DS.heading(13))
                    .foregroundColor(DS.secondaryText)
                
                Spacer()
                
                if markedRow != nil && markedCol != nil {
                    Button {
                        removeMarker()
                    } label: {
                        Label("Remove Pin", systemImage: "pin.slash.fill")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(DS.appMainColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(DS.appMainColor.opacity(0.12))
                            )
                    }
                }
            }
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 145), spacing: 8)
            ], spacing: 6) {
                ForEach(Array(pattern.palette.enumerated()), id: \.offset) { index, color in
                    HStack(spacing: 5) {
                        Circle()
                            .fill(color.color)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.gray.opacity(0.35), lineWidth: 0.6)
                            )
                        
                        Text("\(color.hex) (\(DS.formatted(counts[index])))")
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .foregroundColor(DS.secondaryText.opacity(0.75))
                            .lineLimit(1)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.55))
        )
    }
    
    private var yarnTimeSlider: some View {
        GeometryReader { geo in
            let trackWidth = geo.size.width
            let progress = min(elapsed / totalDuration, 1.0)
            let postureX = trackWidth * CGFloat(progress)
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DS.appMainColor.opacity(0.2))
                    .frame(height: 6)
                
                Capsule()
                    .fill(DS.appMainColor.opacity(0.5))
                    .frame(width: max(0, postureX), height: 6)
                
                Text("🧶")
                    .font(.system(size: 28))
                    .offset(x: postureX - 14)
            }
        }
        .frame(height: 36)
    }
    
    private var reminderOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("🧘🏽‍♀️")
                    .font(.system(size: 72))
                    .scaleEffect(posturePulse ? 1.1 : 0.9)
                    .animation(
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: posturePulse
                    )
                
                Text(reminderMessage)
                    .font(DS.heading(28))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Button {
                    dismissReminder()
                } label: {
                    Text(reminderButton)
                        .primaryButton(color: DS.appMainColor)
                }
            }
            .padding(40)
        }
        .onAppear { posturePulse = true }
        .onDisappear { posturePulse = false }
    }
    
    private func startSession() {
        sessionStart = Date()
        elapsed = 0
        pauseOffset = 0
        nextCheckpointIdx = 0
        isPaused = false
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard !isPaused, let start = sessionStart else { return }
            elapsed = Date().timeIntervalSince(start) - pauseOffset
            
            if nextCheckpointIdx < checkpoints.count && elapsed >= checkpoints[nextCheckpointIdx] {
                triggerReminder()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func triggerReminder() {
        isPaused = true
        pauseStart = Date()
        
        if nextCheckpointIdx == 2 {
            reminderMessage = "Time to stand\nand go for a walk 🧚🏼‍♀️"
            reminderButton = "End Session"
            isFinalReminder = true
        } else {
            reminderMessage = "Correct your posture"
            reminderButton = "Continue"
            isFinalReminder = false
        }
        
        nextCheckpointIdx += 1
        withAnimation { showReminder = true }
    }
    
    private func dismissReminder() {
        if isFinalReminder {
            stopTimer()
            withAnimation { showReminder = false }
            onEnd()
        } else {
            if let ps = pauseStart {
                pauseOffset += Date().timeIntervalSince(ps)
            }
            pauseStart = nil
            isPaused = false
            withAnimation { showReminder = false }
        }
    }
    
    private func timeString(_ seconds: Double) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
