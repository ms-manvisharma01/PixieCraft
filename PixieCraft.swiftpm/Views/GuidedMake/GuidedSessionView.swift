import SwiftUI

struct GuidedSessionView: View {
    
    let pattern: CrochetPattern
    let onExit: () -> Void
    
    @EnvironmentObject var store: PatternStore
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var rowInstructions: [RowInstruction] = []
    @State private var showExplanation: String? = nil
    @State private var gridZoom: CGFloat = 1.0
    @State private var gridOffset: CGSize = .zero
    @State private var lastDragOffset: CGSize = .zero
    @State private var isBreakdownExpanded: Bool = false
    
    private var completedRows: Int {
        rowInstructions.filter { $0.isCompleted }.count
    }
    
    private var totalRows: Int {
        rowInstructions.count
    }
    
    private var overallProgress: Double {
        guard totalRows > 0 else { return 0 }
        return Double(completedRows) / Double(totalRows)
    }
    
    private var currentRowNumber: Int {
        if let firstIncomplete = rowInstructions.first(where: { !$0.isCompleted }) {
            return firstIncomplete.rowNumber
        }
        return totalRows
    }
    
    private var currentGridRowIndex: Int {
        guard pattern.height > 0 else { return 0 }
        return pattern.height - currentRowNumber
    }
    
    private var currentInstruction: RowInstruction? {
        rowInstructions.first(where: { !$0.isCompleted }) ?? rowInstructions.last
    }
    
    private var allComplete: Bool {
        !rowInstructions.isEmpty && rowInstructions.allSatisfy { $0.isCompleted }
    }
    
    private var completedRowNumbers: Set<Int> {
        Set(rowInstructions.filter { $0.isCompleted }.map { $0.rowNumber })
    }
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            
            if isLandscape {
                HStack(spacing: 0) {
                    leftPanel
                        .frame(width: geo.size.width * 0.5)
                    
                    Divider()
                    
                    rightPanel
                        .frame(width: geo.size.width * 0.5)
                }
            } else {
                VStack(spacing: 0) {
                    leftPanel
                        .frame(height: geo.size.height * 0.45)
                    
                    Divider()
                    
                    rightPanel
                }
            }
        }
        .background(DS.appBG.ignoresSafeArea())
        .navigationTitle(pattern.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    saveProgress()
                    onExit()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(DS.body(16))
                    }
                    .foregroundColor(DS.appMainColor)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadProgressAndInstructions()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .inactive || newPhase == .background {
                saveProgress()
            }
        }
        .sheet(item: $showExplanation) { explanation in
            ExplanationSheet(explanation: explanation, onDismiss: { showExplanation = nil })
        }
    }
    
    private func loadProgressAndInstructions() {
        rowInstructions = PatternInstructionGenerator.generateRowInstructions(from: pattern)
        
        guard let savedProgress = pattern.guidedProgress else { return }
        
        for rowNum in savedProgress.completedRows {
            if let idx = rowInstructions.firstIndex(where: { $0.rowNumber == rowNum }) {
                for stitchIdx in rowInstructions[idx].stitches.indices {
                    rowInstructions[idx].stitches[stitchIdx].isCompleted = true
                }
            }
        }
    }
    
    private func saveProgress() {
        var updatedPattern = pattern
        var progress = GuidedProgressState(
            completedRows: completedRowNumbers,
            currentRow: currentRowNumber,
            totalRows: totalRows
        )
        progress.validateAndCorrect()
        updatedPattern.guidedProgress = progress
        store.update(updatedPattern)
    }
    
    private var leftPanel: some View {
        ZStack {
            Color.white.opacity(0.5)
            
            patternCanvas
                .scaleEffect(gridZoom)
                .offset(gridOffset)
                .gesture(dragGesture)
                .gesture(magnificationGesture)
                .clipped()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                gridZoom = min(gridZoom + 0.5, 6.0)
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color.white.opacity(0.9)))
                                .foregroundColor(DS.mainText)
                                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        }
                        
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                gridZoom = max(gridZoom - 0.5, 0.25)
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color.white.opacity(0.9)))
                                .foregroundColor(DS.mainText)
                                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        }
                        
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                gridZoom = 1.0
                                gridOffset = .zero
                            }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 14, weight: .bold))
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color.white.opacity(0.9)))
                                .foregroundColor(DS.mainText)
                                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        }
                    }
                    .padding(12)
                }
            }
            
            VStack {
                HStack {
                    Image(systemName: "arrowtriangle.right.fill")
                        .font(.system(size: 10))
                    Text("CURRENT ROW \(currentRowNumber)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(DS.appMainColor))
                .padding(.top, 8)
                
                Spacer()
            }
        }
    }
    
    private var patternCanvas: some View {
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
                    
                    if cellSize >= 4 {
                        let inset: CGFloat = 0.5
                        let innerRect = rect.insetBy(dx: inset, dy: inset)
                        ctx.stroke(Path(innerRect), with: .color(Color.black.opacity(0.10)), lineWidth: 0.5)
                    }
                }
            }
            
            if cellSize >= 3 {
                let minorColor = Color(white: 0.25).opacity(0.35)
                var minorPath = Path()
                for col in 0...cols {
                    let x = ox + CGFloat(col) * cellSize
                    minorPath.move(to: CGPoint(x: x, y: oy))
                    minorPath.addLine(to: CGPoint(x: x, y: oy + totalH))
                }
                for row in 0...rows {
                    let y = oy + CGFloat(row) * cellSize
                    minorPath.move(to: CGPoint(x: ox, y: y))
                    minorPath.addLine(to: CGPoint(x: ox + totalW, y: y))
                }
                ctx.stroke(minorPath, with: .color(minorColor), lineWidth: 0.5)
                
                let majorColor = Color(white: 0.15).opacity(0.50)
                var majorPath = Path()
                for col in stride(from: 0, through: cols, by: 5) {
                    let x = ox + CGFloat(col) * cellSize
                    majorPath.move(to: CGPoint(x: x, y: oy))
                    majorPath.addLine(to: CGPoint(x: x, y: oy + totalH))
                }
                for row in stride(from: 0, through: rows, by: 5) {
                    let y = oy + CGFloat(row) * cellSize
                    majorPath.move(to: CGPoint(x: ox, y: y))
                    majorPath.addLine(to: CGPoint(x: ox + totalW, y: y))
                }
                ctx.stroke(majorPath, with: .color(majorColor), lineWidth: 1.0)
            }
            
            let highlightRow = currentGridRowIndex
            if highlightRow >= 0 && highlightRow < rows {
                if highlightRow > 0 {
                    let aboveRect = CGRect(
                        x: ox, y: oy,
                        width: totalW, height: CGFloat(highlightRow) * cellSize
                    )
                    ctx.fill(Path(aboveRect), with: .color(Color.white.opacity(0.5)))
                }
                if highlightRow < rows - 1 {
                    let belowY = oy + CGFloat(highlightRow + 1) * cellSize
                    let belowRect = CGRect(
                        x: ox, y: belowY,
                        width: totalW, height: CGFloat(rows - highlightRow - 1) * cellSize
                    )
                    ctx.fill(Path(belowRect), with: .color(Color.white.opacity(0.5)))
                }
                
                let rowRect = CGRect(
                    x: ox, y: oy + CGFloat(highlightRow) * cellSize,
                    width: totalW, height: cellSize
                )
                let borderPath = Path(rowRect)
                ctx.stroke(borderPath, with: .color(DS.appMainColor), lineWidth: max(2, cellSize * 0.08))
            }
        }
        .drawingGroup()
        .aspectRatio(CGFloat(pattern.width) / CGFloat(max(1, pattern.height)), contentMode: .fit)
        .padding(12)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                gridOffset = CGSize(
                    width: lastDragOffset.width + value.translation.width,
                    height: lastDragOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastDragOffset = gridOffset
            }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                let newZoom = max(0.25, min(gridZoom * scale, 6.0))
                gridZoom = newZoom
            }
    }
    
    private var rightPanel: some View {
        VStack(spacing: 0) {
            currentRowHeader
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            Divider().padding(.horizontal, 16)
            
            ScrollView {
                VStack(spacing: 16) {
                    if let instruction = currentInstruction, !allComplete {
                        currentRowCard(instruction)
                    } else if allComplete {
                        completionCard
                    }
                    
                    rowListSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background(DS.appBG)
    }
    
    private var currentRowHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(allComplete ? "All Done!" : "Current Row")
                    .font(DS.caption(12))
                    .foregroundColor(DS.secondaryText.opacity(0.7))
                
                Text(allComplete ? "🎉 Complete" : "Row \(currentRowNumber)")
                    .font(DS.heading(26))
                    .foregroundColor(DS.appMainColor)
            }
            
            Spacer()
            
            ZStack {
                CircularProgressView(progress: overallProgress, size: 50, lineWidth: 5)
                
                VStack(spacing: 0) {
                    Text("\(completedRows)")
                        .font(DS.heading(14))
                        .foregroundColor(DS.mainText)
                    Text("of \(totalRows)")
                        .font(DS.caption(9))
                        .foregroundColor(DS.secondaryText)
                }
            }
        }
    }
    
    private func currentRowCard(_ instruction: RowInstruction) -> some View {
        VStack(spacing: 14) {
            Text(instruction.explain())
                .font(DS.body(15))
                .foregroundColor(DS.mainText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(4)
            
            VStack(spacing: 0) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isBreakdownExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .rotationEffect(.degrees(isBreakdownExpanded ? 90 : 0))
                        
                        Text(isBreakdownExpanded ? "Hide Color Breakdown" : "Show Color Breakdown")
                            .font(DS.caption(13))
                        
                        Spacer()
                    }
                    .foregroundColor(DS.appMainColor)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                
                if isBreakdownExpanded {
                    VStack(spacing: 0) {
                        Divider()
                            .padding(.bottom, 10)
                        
                        VStack(spacing: 8) {
                            ForEach(instruction.stitches) { stitch in
                                HStack(spacing: 10) {
                                    Circle()
                                        .fill(stitch.color)
                                        .frame(width: 14, height: 14)
                                        .overlay(Circle().strokeBorder(Color.gray.opacity(0.3), lineWidth: 0.5))
                                    
                                    Text("\(stitch.colorName) — \(stitch.count) \(stitch.count == 1 ? "stitch" : "stitches")")
                                        .font(DS.body(13))
                                        .foregroundColor(DS.mainText)
                                    
                                    Spacer()
                                    
                                    Text(stitch.colorHex)
                                        .font(.system(size: 9, weight: .regular, design: .monospaced))
                                        .foregroundColor(DS.secondaryText.opacity(0.45))
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(DS.appMainColor.opacity(0.06))
            )
            .clipped()
            
            Button {
                markCurrentRowComplete()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                    Text("Mark as Complete")
                        .font(DS.body(15))
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Capsule().fill(DS.appMainColor))
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.9))
                .shadow(color: DS.appMainColor.opacity(0.12), radius: 8, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DS.appMainColor.opacity(0.3), lineWidth: 1.5)
        )
    }
    
    private var completionCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 40))
                .foregroundColor(DS.appMainColor)
            
            Text("Pattern Complete!")
                .font(DS.heading(20))
                .foregroundColor(DS.mainText)
            
            Text("You've finished all \(totalRows) rows. Amazing work! 🧶")
                .font(DS.body(14))
                .foregroundColor(DS.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.9))
                .shadow(color: DS.appMainColor.opacity(0.12), radius: 8, y: 3)
        )
    }
    
    private var rowListSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("All Rows")
                .font(DS.heading(16))
                .foregroundColor(DS.mainText)
                .padding(.top, 4)
            
            ForEach($rowInstructions) { $row in
                RowListItem(
                    row: $row,
                    isCurrent: row.rowNumber == currentRowNumber && !allComplete,
                    onExplain: { showExplanation = row.explain() }
                )
            }
        }
    }
    
    private func markCurrentRowComplete() {
        guard let idx = rowInstructions.firstIndex(where: { $0.rowNumber == currentRowNumber && !$0.isCompleted }) else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            for i in rowInstructions[idx].stitches.indices {
                rowInstructions[idx].stitches[i].isCompleted = true
            }
        }
        saveProgress()
    }
}
