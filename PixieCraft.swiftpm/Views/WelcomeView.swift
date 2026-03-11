import SwiftUI

struct WelcomeView: View {
    let onStart: () -> Void
    
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            DS.appBG.ignoresSafeArea()
            
            VStack(spacing: 58) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(DS.primaryCraft.opacity(0.10))
                        .frame(width: 150, height: 150)
                    
                    Image("PixieWelcome")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())          
                        .overlay(
                            Circle()
                                .stroke(DS.appMainColor.opacity(0.25), lineWidth: 2)
                        )
                        .shadow(color: DS.appMainColor.opacity(0.25), radius: 10, x: 0, y: 10)
                }
                .scaleEffect(appeared ? 1 : 0.8)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5), value: appeared)
                
                VStack(spacing: 12) {
                    Text("PixieCraft")
                        .font(DS.heading(54))
                        .foregroundColor(DS.mainText)
                    
                    Text("Ready to create something today?")
                        .font(DS.body(15))
                        .foregroundColor(DS.secondaryText)
                        .multilineTextAlignment(.center)
                    
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                
                Spacer()
                
                Button(action: onStart) {
                    Text("Start Creating")
                        .primaryButton()
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.9)
                
                Spacer()
                    .frame(height: 100)
            }
            .padding(.horizontal, 35)
            .padding(.vertical, 35)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }
}
