import SwiftUI

struct ProcessingView: View {
    
    @State private var rotation: Double = 0
    @State private var pulse: Bool = false
    
    var body: some View {
        ZStack {
            DS.appBG.ignoresSafeArea()
            
            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(DS.appMainColor.opacity(0.15))
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulse ? 1.15 : 0.95)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 44))
                        .foregroundStyle(DS.appMainColor)
                        .rotationEffect(.degrees(rotation))
                }
                
                Text("Crafting your pattern\nwith a little pixie dust...✨")
                    .font(DS.body(17))
                    .foregroundColor(DS.secondaryText)
                    .multilineTextAlignment(.center)
                    .opacity(0.85)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
