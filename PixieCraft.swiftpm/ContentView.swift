import SwiftUI

struct ContentView: View {
    @State private var showHome = false
    
    var body: some View {
        ZStack {
            if showHome {
                HomeView()
                    .transition(.opacity)
            } else {
                WelcomeView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showHome = true
                    }
                }
                .transition(.opacity)
            }
        }
    }
}
