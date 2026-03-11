import SwiftUI
import PhotosUI

struct CreateCraftFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: PatternStore
    
    @State private var currentStep: CreateStep = .selectPattern
    @State private var selectedPattern: CrochetPattern? = nil
    
    @State private var projectName: String = ""
    @State private var madeBy: String = ""
    @State private var journalNote: String = ""
    @State private var startDate: Date = Date()
    @State private var completionDate: Date = Date()
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var finishedImage: UIImage? = nil
    
    @State private var isGenerating = false
    @State private var showSavedOverlay = false
    
    private let noteCharacterLimit = 200
    
    enum CreateStep {
        case selectPattern
        case customize
        case generating
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DS.appBG.ignoresSafeArea()
                
                switch currentStep {
                case .selectPattern:
                    selectPatternView
                case .customize:
                    customizeView
                case .generating:
                    generatingView
                }
                
                if showSavedOverlay {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("Craft Saved!")
                            .font(DS.heading(24))
                            .foregroundColor(.white)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(DS.appMainColor)
                }
            }
        }
    }
    
    private var navigationTitle: String {
        switch currentStep {
        case .selectPattern: return "Select Pattern"
        case .customize: return "Customize"
        case .generating: return "Generating..."
        }
    }
    
    private var selectPatternView: some View {
        ScrollView {
            if store.patterns.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "square.stack.3d.up.slash")
                        .font(.system(size: 50))
                        .foregroundColor(DS.secondaryText.opacity(0.4))
                    
                    Text("No Patterns Available")
                        .font(DS.heading(18))
                        .foregroundColor(DS.mainText)
                    
                    Text("Create a pattern first using\n\"Create from Photo\"")
                        .font(DS.body(14))
                        .foregroundColor(DS.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 100)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 100), spacing: 14),
                    GridItem(.flexible(minimum: 100), spacing: 14),
                    GridItem(.flexible(minimum: 100), spacing: 14)
                ], spacing: 14) {
                    ForEach(store.patterns) { pattern in
                        Button {
                            selectedPattern = pattern
                            projectName = pattern.name
                            startDate = pattern.createdDate
                            withAnimation {
                                currentStep = .customize
                            }
                        } label: {
                            PatternSelectCard(pattern: pattern)
                        }
                    }
                }
                .padding(16)
            }
        }
    }
    
    private var customizeView: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let pattern = selectedPattern {
                    HStack(spacing: 16) {
                        MiniGridCanvas(pattern: pattern)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pattern.name)
                                .font(DS.heading(16))
                                .foregroundColor(DS.mainText)
                            
                            Text("\(pattern.width) × \(pattern.height) stitches")
                                .font(DS.caption(12))
                                .foregroundColor(DS.secondaryText)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                currentStep = .selectPattern
                            }
                        } label: {
                            Text("Change")
                                .font(DS.caption(13))
                                .foregroundColor(DS.appMainColor)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.8))
                    )
                }
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Project Name")
                            .font(DS.caption(13))
                            .foregroundColor(DS.secondaryText)
                        
                        TextField("My Cozy Blanket", text: $projectName)
                            .font(DS.body(16))
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Signature")
                            .font(DS.caption(13))
                            .foregroundColor(DS.secondaryText)
                        
                        TextField("Your Name", text: $madeBy)
                            .font(DS.body(16))
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                    }
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start Date")
                                .font(DS.caption(13))
                                .foregroundColor(DS.secondaryText)
                            
                            DatePicker("", selection: $startDate, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Completion Date")
                                .font(DS.caption(13))
                                .foregroundColor(DS.secondaryText)
                            
                            DatePicker("", selection: $completionDate, in: startDate..., displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Finished Product Photo")
                            .font(DS.caption(13))
                            .foregroundColor(DS.secondaryText)
                        
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            if let image = finishedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 180)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(DS.appMainColor.opacity(0.5), lineWidth: 2)
                                    )
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(DS.appMainColor.opacity(0.6))
                                    
                                    Text("Tap to upload photo")
                                        .font(DS.body(14))
                                        .foregroundColor(DS.secondaryText)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 180)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(DS.appMainColor.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                                        )
                                )
                            }
                        }
                        .onChange(of: selectedPhotoItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    finishedImage = uiImage
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Journal Note")
                                .font(DS.caption(13))
                                .foregroundColor(DS.secondaryText)
                            
                            Spacer()
                            
                            Text("\(journalNote.count)/\(noteCharacterLimit)")
                                .font(DS.caption(11))
                                .foregroundColor(journalNote.count > noteCharacterLimit ? .red : DS.secondaryText.opacity(0.6))
                        }
                        
                        TextEditor(text: $journalNote)
                            .font(DS.body(15))
                            .frame(height: 120)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(DS.appMainColor.opacity(0.2), lineWidth: 1)
                            )
                            .onChange(of: journalNote) { newValue in
                                if newValue.count > noteCharacterLimit {
                                    journalNote = String(newValue.prefix(noteCharacterLimit))
                                }
                            }
                        
                        Text("Write about what you made, who it's for, or how you feel about this project")
                            .font(DS.caption(12))
                            .foregroundColor(DS.secondaryText.opacity(0.6))
                            .italic()
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.8))
                )
                
                Button {
                    generateSheet()
                } label: {
                    Text("Generate Journal Sheet")
                        .font(DS.body(17))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule().fill(isFormValid ? DS.appMainColor : DS.secondaryText.opacity(0.3))
                        )
                }
                .disabled(!isFormValid)
                
                Spacer().frame(height: 40)
            }
            .padding(16)
        }
    }
    
    private var isFormValid: Bool {
        !projectName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !journalNote.trimmingCharacters(in: .whitespaces).isEmpty &&
        finishedImage != nil &&
        completionDate >= startDate
    }
    
    private var generatingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Creating your finish sheet...")
                .font(DS.body(16))
                .foregroundColor(DS.secondaryText)
        }
    }
    
    private func generateSheet() {
        guard let pattern = selectedPattern,
              let finishedImg = finishedImage else { return }
        
        withAnimation {
            currentStep = .generating
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let patternPreviewImg = FinishSheetRenderer.renderPatternPreview(pattern: pattern)
            
            let sheetImg = FinishSheetRenderer.renderJournalFinishSheet(
                projectName: projectName,
                madeBy: madeBy,
                journalNote: journalNote,
                startDate: startDate,
                completionDate: completionDate,
                finishedImage: finishedImg,
                patternPreview: patternPreviewImg
            )
            
            let finishedData = finishedImg.jpegData(compressionQuality: 0.8) ?? Data()
            let patternData = patternPreviewImg.pngData() ?? Data()
            let sheetData = sheetImg.pngData() ?? Data()
            
            let craft = CompletedCraft(
                patternId: pattern.id,
                patternName: pattern.name,
                projectName: projectName,
                madeBy: madeBy.isEmpty ? "Anonymous" : madeBy,
                startDate: startDate,
                completionDate: completionDate,
                journalNote: journalNote,
                finishedImageData: finishedData,
                patternPreviewData: patternData,
                finishSheetData: sheetData
            )
            
            DispatchQueue.main.async {
                store.addCraft(craft)
                
                withAnimation(.easeInOut(duration: 0.4)) {
                    showSavedOverlay = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation {
                        showSavedOverlay = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PatternSelectCard: View {
    let pattern: CrochetPattern
    
    var body: some View {
        VStack(spacing: 10) {
            MiniGridCanvas(pattern: pattern)
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(pattern.name)
                .font(DS.heading(13))
                .foregroundColor(DS.mainText)
                .lineLimit(1)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.85))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
}
