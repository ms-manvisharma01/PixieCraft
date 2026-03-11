import SwiftUI

struct GuidedPickerCard: View {
    let pattern: CrochetPattern
    
    private var progressPercent: Int {
        guard let progress = pattern.guidedProgress else { return 0 }
        return Int(progress.progressPercentage)
    }
    
    private var hasProgress: Bool {
        pattern.hasGuidedProgress
    }
    
    private var isComplete: Bool {
        pattern.guidedProgress?.isComplete ?? false
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topTrailing) {
                MiniGridCanvas(pattern: pattern)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(
                        CGFloat(pattern.width) / CGFloat(max(1, pattern.height)),
                        contentMode: .fit
                    )
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                if hasProgress {
                    progressBadge
                        .padding(6)
                }
            }
            
            Text(pattern.name)
                .font(DS.heading(16))
                .foregroundColor(DS.secondaryText)
                .lineLimit(1)
        }
        .padding(14)
        .cardStyle(color: Color.white.opacity(0.7))
    }
    
    @ViewBuilder
    private var progressBadge: some View {
        if isComplete {
            HStack(spacing: 3) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                Text("Done")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color.green))
        } else {
            HStack(spacing: 3) {
                Image(systemName: "play.fill")
                    .font(.system(size: 8))
                Text("\(progressPercent)%")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Capsule().fill(DS.appMainColor))
        }
    }
}
