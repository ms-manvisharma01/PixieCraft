import SwiftUI

enum RowStatus {
    case complete, inProgress, pending
}

struct RowListItem: View {
    
    @Binding var row: RowInstruction
    let isCurrent: Bool
    let onExplain: () -> Void
    
    private var status: RowStatus {
        if row.isCompleted { return .complete }
        if isCurrent { return .inProgress }
        return .pending
    }
    
    var body: some View {
        HStack(spacing: 12) {
            statusIcon
            
            Text("Row \(row.rowNumber)")
                .font(DS.body(14))
                .fontWeight(isCurrent ? .semibold : .regular)
                .foregroundColor(isCurrent ? DS.mainText : DS.secondaryText)
            
            Spacer()
            
            statusBadge
            
            if status != .pending {
                Button(action: onExplain) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 13))
                        .foregroundColor(DS.appMainColor.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isCurrent ? DS.appMainColor.opacity(0.08) : Color.white.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    isCurrent ? DS.appMainColor.opacity(0.35) : Color.clear,
                    lineWidth: 1.5
                )
        )
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch status {
        case .complete:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(DS.appMainColor)
        case .inProgress:
            Image(systemName: "play.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(DS.appMainColor)
        case .pending:
            Image(systemName: "lock.circle")
                .font(.system(size: 20))
                .foregroundColor(DS.secondaryText.opacity(0.35))
        }
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .complete:
            Text("COMPLETE")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(DS.appMainColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(DS.appMainColor.opacity(0.12)))
        case .inProgress:
            Text("IN PROGRESS")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(DS.appMainColor))
        case .pending:
            Text("PENDING")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(DS.secondaryText.opacity(0.5))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(DS.secondaryText.opacity(0.08)))
        }
    }
}

struct StitchChecklistRow: View {
    
    @Binding var stitch: StitchInstruction
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                stitch.isCompleted.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(
                            stitch.isCompleted ? DS.appMainColor : DS.secondaryText.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                    
                    if stitch.isCompleted {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(DS.appMainColor)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Circle()
                    .fill(stitch.color)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Text(stitch.description)
                    .font(DS.body(15))
                    .foregroundColor(stitch.isCompleted ? DS.secondaryText : DS.mainText)
                    .strikethrough(stitch.isCompleted, color: DS.secondaryText.opacity(0.5))
                
                Spacer()
                
                Text(stitch.colorHex)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(DS.secondaryText.opacity(0.6))
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct ExplanationSheet: View {
    let explanation: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
            
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 40))
                .foregroundColor(DS.appMainColor)
            
            Text("Row Instructions")
                .font(DS.heading(22))
                .foregroundColor(DS.mainText)
            
            Text(explanation)
                .font(DS.body(17))
                .foregroundColor(DS.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Button(action: onDismiss) {
                Text("Got it!")
                    .primaryButton()
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(DS.appBG.ignoresSafeArea())
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}

extension String: Identifiable {
    public var id: String { self }
}
