import SwiftUI

struct PatternLibraryView: View {
    
    @EnvironmentObject var store: PatternStore
    @State private var patternToDelete: CrochetPattern? = nil
    @State private var showDeleteAlert = false
    @State private var patternToRename: CrochetPattern? = nil
    @State private var newPatternName: String = ""
    @State private var showRenameAlert = false
    
    private let columns = [
        GridItem(.flexible(minimum: 120), spacing: 14),
        GridItem(.flexible(minimum: 120), spacing: 14),
        GridItem(.flexible(minimum: 120), spacing: 14)
    ]
    
    var body: some View {
        ZStack {
            DS.appBG.ignoresSafeArea()
            
            if store.patterns.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Pattern Vault")
                            .font(DS.heading(44))
                            .foregroundColor(DS.mainText)
                            .padding(.top, 16)
                        
                        Text("Your saved alpha patterns")
                            .font(DS.body(16))
                            .foregroundColor(DS.secondaryText.opacity(0.6))
                            .padding(.bottom, 25)
                        
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(store.patterns) { pattern in
                                NavigationLink(destination: PatternPreviewView(pattern: pattern)) {
                                    SavedPatternCard(
                                        pattern: pattern,
                                        onDelete: {
                                            patternToDelete = pattern
                                            showDeleteAlert = true
                                        },
                                        onRename: {
                                            patternToRename = pattern
                                            newPatternName = pattern.name
                                            showRenameAlert = true
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Pattern?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { patternToDelete = nil }
            Button("Delete", role: .destructive) {
                if let p = patternToDelete {
                    withAnimation { store.delete(id: p.id) }
                    patternToDelete = nil
                }
            }
        } message: {
            Text("This pattern will be permanently removed.")
        }
        .alert("Rename Pattern", isPresented: $showRenameAlert) {
            TextField("Pattern Name", text: $newPatternName)
            Button("Cancel", role: .cancel) {
                patternToRename = nil
                newPatternName = ""
            }
            Button("Save") {
                if let pattern = patternToRename, !newPatternName.trimmingCharacters(in: .whitespaces).isEmpty {
                    var updated = pattern
                    updated.name = newPatternName.trimmingCharacters(in: .whitespaces)
                    store.update(updated)
                }
                patternToRename = nil
                newPatternName = ""
            }
        } message: {
            Text("Enter a new name for this pattern.")
        }
    }
    
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 44))
                .foregroundColor(DS.appMainColor.opacity(0.5))
            
            Text("No patterns yet")
                .font(DS.heading(20))
                .foregroundColor(DS.secondaryText)
            
            Text("Create one using\n\"Create from Photo\"")
                .font(DS.body(15))
                .foregroundColor(DS.secondaryText.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }
}


private struct SavedPatternCard: View {
    let pattern: CrochetPattern
    let onDelete: () -> Void
    let onRename: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topTrailing) {
                miniGrid
                    .frame(maxWidth: .infinity)
                    .aspectRatio(
                        CGFloat(pattern.width) / CGFloat(max(1, pattern.height)),
                        contentMode: .fit
                    )
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                if pattern.isInProgress {
                    Text("📍")
                        .font(.system(size: 16))
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                        .offset(x: 4, y: -4)
                }
            }
            
            Text(pattern.name)
                .font(DS.heading(16))
                .foregroundColor(DS.secondaryText)
                .lineLimit(1)
            
            Text(pattern.createdDate, style: .date)
                .font(DS.caption(11))
                .foregroundColor(DS.secondaryText.opacity(0.5))
        }
        .padding(10)
        .cardStyle(color: Color.white.opacity(0.7))
        .contextMenu {
            Button {
                onRename()
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var miniGrid: some View {
        MiniGridCanvas(pattern: pattern)
    }
}
