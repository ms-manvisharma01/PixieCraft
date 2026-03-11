import SwiftUI

struct ProgressBarView: View {
    let progress: Double  // 0.0 to 1.0
    let height: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let showPercentage: Bool
    
    init(
        progress: Double,
        height: CGFloat = 8,
        backgroundColor: Color = DS.appMainColor.opacity(0.2),
        foregroundColor: Color = DS.appMainColor,
        showPercentage: Bool = false
    ) {
        self.progress = min(max(progress, 0), 1) // Clamp to 0-1
        self.height = height
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(backgroundColor)
                    .frame(height: height)
                
                Capsule()
                    .fill(foregroundColor)
                    .frame(width: max(0, geo.size.width * progress), height: height)
                    .animation(.easeOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
        .overlay(alignment: .trailing) {
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(DS.caption(11))
                    .foregroundColor(DS.secondaryText)
                    .padding(.trailing, 4)
            }
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    
    init(
        progress: Double,
        size: CGFloat = 40,
        lineWidth: CGFloat = 4,
        backgroundColor: Color = DS.appMainColor.opacity(0.2),
        foregroundColor: Color = DS.appMainColor
    ) {
        self.progress = min(max(progress, 0), 1)
        self.size = size
        self.lineWidth = lineWidth
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(foregroundColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.3), value: progress)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBarView(progress: 0.6)
            .padding()
        
        ProgressBarView(progress: 0.3, showPercentage: true)
            .padding()
        
        CircularProgressView(progress: 0.75)
    }
    .padding()
    .background(DS.appBG)
}
