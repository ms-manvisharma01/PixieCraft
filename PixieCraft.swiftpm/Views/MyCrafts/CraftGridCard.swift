import SwiftUI

struct CraftGridCard: View {
    let craft: CompletedCraft
    
    var body: some View {
        VStack(spacing: 10) {
            if let image = craft.finishSheet {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(DS.secondaryText.opacity(0.1))
                    .frame(height: 140)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(DS.secondaryText.opacity(0.3))
                    )
            }
            
            Text(craft.projectName)
                .font(DS.heading(14))
                .foregroundColor(DS.mainText)
                .lineLimit(1)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.85))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
    }
}
