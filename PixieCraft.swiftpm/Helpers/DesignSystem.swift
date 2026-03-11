import SwiftUI

enum DS {
    static let appBG         = Color(red: 248/255, green: 238/255, blue: 230/255)
    static let appMainColor  = Color(red: 219/255, green: 148/255, blue: 167/255)
    static let cardBg        = Color.white.opacity(0.85)
    
    static let primaryCraft  = Color(red: 212/255, green: 165/255, blue: 165/255) 
    static let mainText      = Color(red: 74/255,  green: 68/255,  blue: 63/255)  
    static let secondaryText = Color(red: 142/255, green: 142/255, blue: 147/255)
    
    enum Grid {
        static let minZoom: CGFloat = 0.25
        static let maxZoom: CGFloat = 6.0
        static let baseCellSize: CGFloat = 20
        static let majorGridInterval = 5
    }
    enum Session {
        static let totalDuration: Double = 3600
        static let checkpoint20Min: Double = 1200
        static let checkpoint40Min: Double = 2400
        static let checkpoint60Min: Double = 3600
    }
    
    static func heading(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    
    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    
    
    static func formatted(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    struct CardStyle: ViewModifier {
        var color: Color = cardBg
        
        func body(content: Content) -> some View {
            content
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(color)
                        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                )
        }
    }
    
    struct PrimaryButton: ViewModifier {
        var color: Color = appMainColor
        
        func body(content: Content) -> some View {
            content
                .font(DS.body(17))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(Capsule().fill(color))
                .shadow(color: color.opacity(0.3), radius: 8, y: 4)
        }
    }
}
struct MiniGridCanvas: View {
    let pattern: CrochetPattern
    
    var body: some View {
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
                        width: cellSize,
                        height: cellSize
                    )
                    ctx.fill(Path(rect), with: .color(pattern.palette[safeIdx].color))
                }
            }
        }
        .drawingGroup()
    }
}
struct EmptyStateView: View {
    let icon: String
    let title: String
    var message: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(DS.secondaryText.opacity(0.3))
            
            Text(title)
                .font(DS.body(15))
                .foregroundColor(DS.secondaryText.opacity(0.5))
            
            if !message.isEmpty {
                Text(message)
                    .font(DS.caption(13))
                    .foregroundColor(DS.secondaryText.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 40)
    }
}
extension View {
    func cardStyle(color: Color = DS.cardBg) -> some View {
        modifier(DS.CardStyle(color: color))
    }
    
    func primaryButton(color: Color = DS.appMainColor) -> some View {
        modifier(DS.PrimaryButton(color: color))
    }
}
