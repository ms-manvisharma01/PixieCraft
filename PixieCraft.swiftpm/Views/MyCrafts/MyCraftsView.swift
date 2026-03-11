import SwiftUI

struct MyCraftsView: View {
    
    @EnvironmentObject var store: PatternStore
    @State private var showingCreateFlow = false
    
    private let columns = [
        GridItem(.flexible(minimum: 100), spacing: 14),
        GridItem(.flexible(minimum: 100), spacing: 14),
        GridItem(.flexible(minimum: 100), spacing: 14)
    ]
    
    var body: some View {
        ZStack {
            DS.appBG.ignoresSafeArea()
            
            if store.completedCrafts.isEmpty {
                emptyState
            } else {
                craftsGrid
            }
        }
        .navigationTitle("My Crafts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingCreateFlow = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DS.appMainColor)
                }
            }
        }
        .sheet(isPresented: $showingCreateFlow) {
            CreateCraftFlowView()
                .environmentObject(store)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles.square.filled.on.square")
                .font(.system(size: 60))
                .foregroundColor(DS.appMainColor.opacity(0.5))
            
            Text("No Finished Projects Yet")
                .font(DS.heading(22))
                .foregroundColor(DS.mainText)
            
            Text("Tap + to add your first\nfinished project.")
                .font(DS.body(15))
                .foregroundColor(DS.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    private var craftsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(store.completedCrafts) { craft in
                    NavigationLink(destination: CraftDetailView(craft: craft)) {
                        CraftGridCard(craft: craft)
                    }
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    NavigationStack {
        MyCraftsView()
            .environmentObject(PatternStore())
    }
}
