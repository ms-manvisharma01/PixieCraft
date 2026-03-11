import SwiftUI

struct GuidedMakeView: View {
    
    @EnvironmentObject var store: PatternStore
    
    var initialPattern: CrochetPattern? = nil
    
    @State private var selectedPattern: CrochetPattern? = nil
    
    var body: some View {
        ZStack {
            DS.appBG.ignoresSafeArea()
            
            if let pattern = selectedPattern {
                GuidedSessionView(
                    pattern: pattern,
                    onExit: { withAnimation { selectedPattern = nil } }
                )
            } else {
                patternPicker
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedPattern == nil, let initial = initialPattern {
                selectedPattern = initial
            }
        }
    }
    
    private var patternPicker: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "list.bullet.clipboard.fill")
                    .font(.system(size: 44))
                    .foregroundColor(DS.appMainColor)
                    .padding(.top, 32)
                
                Text("Guided Make")
                    .font(DS.heading(34))
                    .foregroundColor(DS.mainText)
                    .multilineTextAlignment(.center)
                
                Text("Follow row-by-row stitch instructions")
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
                    GuidedPickerCard(pattern: pattern)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    GuidedMakeView()
        .environmentObject(PatternStore())
}
