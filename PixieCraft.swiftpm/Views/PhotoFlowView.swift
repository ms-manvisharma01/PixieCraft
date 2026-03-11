import SwiftUI
import PhotosUI

struct PhotoFlowView: View {
    
    enum Step {
        case pick
        case detail
        case colors
        case processing
        case preview
    }
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: PatternStore
    
    @State private var step: Step = .pick
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var loadedImage: UIImage? = nil
    @State private var gridSize: Double = 50
    @State private var maxColors: Int = 8
    @State private var pattern: CrochetPattern? = nil
    @State private var errorMessage: String? = nil
    @State private var showError = false
    
    var body: some View {
        ZStack {
            DS.appBG.ignoresSafeArea()
            
            switch step {
            case .pick:
                pickStep
            case .detail:
                detailStep
            case .colors:
                colorStep
            case .processing:
                ProcessingView()
            case .preview:
                if let pattern {
                    PatternPreviewView(pattern: pattern)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Oops!", isPresented: $showError) {
            Button("OK") {
                step = .pick
                selectedItem = nil
                loadedImage = nil
            }
        } message: {
            Text(errorMessage ?? "Something went wrong. Let's try another image")
        }
    }
    
    
    private var pickStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 52))
                .foregroundStyle(DS.appMainColor)
                .padding(30)
            
            Text("Pick an Illustration")
                .font(DS.heading(42))
                .foregroundColor(DS.mainText)
            
            Text("Simple illustrations work best 🎨")
                .font(DS.body(25))
                .foregroundColor(DS.secondaryText.opacity(0.7))
                .padding(0)
            
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Choose Photo")
                    .primaryButton(color: DS.appMainColor)
                    .padding(50)
            }
            
            Spacer()
        }
        .padding(.horizontal, 42)
        .padding(.vertical, 42)
        .onChange(of: selectedItem) { _, newValue in
            guard let item = newValue else { return }
            Task {
                await loadImage(from: item)
            }
        }
    }
    
    private var proportionalDimensions: (cols: Int, rows: Int) {
        guard let img = loadedImage else { return (Int(gridSize), Int(gridSize)) }
        let imgW = Double(img.size.width)
        let imgH = Double(img.size.height)
        guard imgW > 0, imgH > 0 else { return (Int(gridSize), Int(gridSize)) }
        let aspect = imgW / imgH
        if aspect >= 1 {
            return (Int(gridSize), max(1, Int(round(gridSize / aspect))))
        } else {
            return (max(1, Int(round(gridSize * aspect))), Int(gridSize))
        }
    }
    
    private var detailStep: some View {
        VStack(spacing: 28) {
            Spacer()
            
            if let img = loadedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.08), radius: 8)
            }
            
            VStack(spacing: 8) {
                Text("Grid Detail Level")
                    .font(DS.heading(20))
                    .foregroundColor(DS.secondaryText)
                
                Text("\(proportionalDimensions.cols) × \(proportionalDimensions.rows) stitches")
                    .font(DS.body(15))
                    .foregroundColor(DS.appMainColor)
            }
            
            Slider(value: $gridSize, in: 50...160, step: 1)
                .tint(DS.appMainColor)
                .padding(.horizontal, 20)
            
            HStack {
                Text("Simple")
                    .font(DS.caption())
                    .foregroundColor(DS.secondaryText.opacity(0.5))
                Spacer()
                Text("Detailed")
                    .font(DS.caption())
                    .foregroundColor(DS.secondaryText.opacity(0.5))
            }
            .padding(.horizontal, 24)
            
            Button(action: { withAnimation { step = .colors } }) {
                Text("Next →")
                    .primaryButton()
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    
    private var colorStep: some View {
        VStack(spacing: 28) {
            Spacer()
            
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 48))
                .foregroundStyle(DS.appMainColor)
            
            Text("How many colors?")
                .font(DS.heading(22))
                .foregroundColor(DS.secondaryText)
            
            Text("Fewer colors = simpler pattern")
                .font(DS.body(14))
                .foregroundColor(DS.secondaryText.opacity(0.6))
            
            HStack(spacing: 16) {
                colorOption(count: 5)
                colorOption(count: 8)
                colorOption(count: 12)
            }
            
            Button(action: { startProcessing() }) {
                Text("Create Pattern")
                    .primaryButton(color: DS.appMainColor)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private func colorOption(count: Int) -> some View {
        Button(action: { maxColors = count }) {
            VStack(spacing: 6) {
                Text("\(count)")
                    .font(DS.heading(24))
                    .foregroundColor(maxColors == count ? .white : DS.secondaryText)
                Text("colors")
                    .font(DS.caption(12))
                    .foregroundColor(maxColors == count ? .white.opacity(0.8) : DS.secondaryText.opacity(0.5))
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(maxColors == count ? DS.appMainColor : DS.appMainColor.opacity(0.15))
            )
        }
    }
    
    
    private func loadImage(from item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                loadedImage = uiImage
                withAnimation { step = .detail }
            } else {
                errorMessage = "Oops! That didn't work. Let's try another image."
                showError = true
            }
        } catch {
            errorMessage = "Oops! That didn't work. Let's try another image."
            showError = true
        }
    }
    
    private func startProcessing() {
        guard let image = loadedImage else { return }
        
        withAnimation { step = .processing }
        
        let size = Int(gridSize)
        let colors = maxColors
        let startTime = Date()
        
        Task {
            do {
                let result = try ImageProcessor.process(
                    image: image,
                    gridSize: size,
                    maxColors: colors
                )
                
                let elapsed = Date().timeIntervalSince(startTime)
                if elapsed < 1.0 {
                    try await Task.sleep(for: .seconds(1.0 - elapsed))
                }
                
                await MainActor.run {
                    pattern = result
                    store.add(result)
                    withAnimation { step = .preview }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}
