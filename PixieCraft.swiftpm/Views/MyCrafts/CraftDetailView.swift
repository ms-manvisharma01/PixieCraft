import SwiftUI

struct CraftDetailView: View {
    let craft: CompletedCraft
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: PatternStore
    @State private var showingSaveSuccess = false
    @State private var showingDeleteConfirmation = false
    @State private var showingEditNote = false
    @State private var editedNote: String = ""
    
    private let noteCharacterLimit = 200
    
    var body: some View {
        ZStack {
            DS.appBG.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    if let image = craft.finishSheet {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
                            .padding(.horizontal, 16)
                    }
                    
                    HStack(spacing: 16) {
                        if let image = craft.finishSheet {
                            ShareLink(item: Image(uiImage: image), preview: SharePreview(craft.projectName, image: Image(uiImage: image))) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share")
                                }
                                .font(DS.body(15))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Capsule().fill(DS.appMainColor))
                            }
                        }
                        
                        Button {
                            saveToPhotos()
                        } label: {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("Save to Photos")
                            }
                            .font(DS.body(15))
                            .fontWeight(.semibold)
                            .foregroundColor(DS.appMainColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .strokeBorder(DS.appMainColor, lineWidth: 2)
                            )
                        }
                    }
                    .padding(.top, 8)
                    
                    if !craft.journalNote.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(DS.appMainColor)
                                Text("Note")
                                    .font(DS.heading(15))
                                    .foregroundColor(DS.mainText)
                                
                                Spacer()
                                
                                Button {
                                    editedNote = craft.journalNote
                                    showingEditNote = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pencil")
                                        Text("Edit")
                                    }
                                    .font(DS.body(13))
                                    .foregroundColor(DS.appMainColor)
                                }
                            }
                            
                            Text(craft.journalNote)
                                .font(DS.body(15))
                                .foregroundColor(DS.mainText.opacity(0.85))
                                .lineSpacing(4)
                            
                            HStack {
                                Spacer()
                                Text("~ \(craft.madeBy)")
                                    .font(DS.body(14))
                                    .italic()
                                    .foregroundColor(DS.secondaryText)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.85))
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.top, 20)
            }
            
            if showingSaveSuccess {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Saved to Photos")
                    }
                    .font(DS.body(15))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.green))
                    .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle(craft.projectName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .alert("Delete Craft?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                store.deleteCraft(id: craft.id)
                dismiss()
            }
        } message: {
            Text("This will permanently delete \"\(craft.projectName)\". This action cannot be undone.")
        }
        .sheet(isPresented: $showingEditNote) {
            editNoteSheet
        }
    }
    
    private var editNoteSheet: some View {
        NavigationStack {
            ZStack {
                DS.appBG.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Edit Journal Note")
                            .font(DS.heading(18))
                            .foregroundColor(DS.mainText)
                        Spacer()
                        Text("\(editedNote.count)/\(noteCharacterLimit)")
                            .font(DS.body(12))
                            .foregroundColor(editedNote.count > noteCharacterLimit ? .red : DS.secondaryText.opacity(0.6))
                    }
                    
                    TextEditor(text: $editedNote)
                        .font(DS.body(15))
                        .foregroundColor(DS.mainText)
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .frame(minHeight: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.9))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(DS.appMainColor.opacity(0.3), lineWidth: 1)
                        )
                        .onChange(of: editedNote) { newValue in
                            if newValue.count > noteCharacterLimit {
                                editedNote = String(newValue.prefix(noteCharacterLimit))
                            }
                        }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingEditNote = false
                    }
                    .foregroundColor(DS.secondaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEditedNote()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(DS.appMainColor)
                    .disabled(editedNote.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func saveEditedNote() {
        var updatedCraft = craft
        updatedCraft.journalNote = editedNote.trimmingCharacters(in: .whitespaces)
        store.updateCraft(updatedCraft)
        showingEditNote = false
    }
    
    private func saveToPhotos() {
        guard let image = craft.finishSheet else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showingSaveSuccess = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingSaveSuccess = false
            }
        }
    }
}
