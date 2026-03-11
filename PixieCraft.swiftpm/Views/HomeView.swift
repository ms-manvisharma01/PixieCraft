import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: PatternStore
    @State private var appeared = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DS.appBG.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 36) {
                        
                        heroSection
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 12)
                        
                        quickActionsSection
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                        
                        myProgressSection
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                        
                        myCraftJournalSection
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                        
                        Spacer().frame(height: 50)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                appeared = true
            }
        }
    }
    
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ready to create something Pixie?")
                .font(.system(size: 42, weight: .medium, design: .rounded))
                .foregroundColor(DS.mainText)
            
            Text("Welcome back,your unfinished projects are waiting for your touch!")
                .font(DS.body(20))
                .foregroundColor(DS.secondaryText)
                .padding(.top, 6)
        }
        .padding(.horizontal, 24)
    }
    
    private var quickActionsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                NavigationLink(destination: PhotoFlowView()) {
                    QuickActionCard(
                        icon: "camera.fill",
                        title: "Craft Pattern",
                        subtitle: "Create a custom alpha pattern from your gallery"
                    )
                }
                
                NavigationLink(destination: GuidedMakeView()) {
                    QuickActionCard(
                        icon: "list.bullet.clipboard.fill",
                        title: "Guided Make",
                        subtitle: "Follow along row by row with clear stitch guidance."
                    )
                }
                
                NavigationLink(destination: MakeTogetherView()) {
                    QuickActionCard(
                        icon: "person.2.fill",
                        title: "Crafting Session",
                        subtitle: "Craft alongside your pattern with mindful reminders."
                    )
                }
                
                NavigationLink(destination: PatternLibraryView()) {
                    QuickActionCard(
                        icon: "square.grid.2x2.fill",
                        title: "Pattern Vault",
                        subtitle: "Your collection of ready-to-make designs"
                    )
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var myProgressSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("My Progress")
                    .font(DS.heading(22))
                    .foregroundColor(DS.mainText)
                Spacer()
                NavigationLink(destination: PatternLibraryView()) {
                    Text("View")
                        .font(DS.body(15))
                        .foregroundColor(DS.appMainColor)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DS.appMainColor)
                }
            }
            .padding(.horizontal, 24)
            
            if patternsInProgress.isEmpty {
                emptyProgressState
                    .padding(.horizontal, 24)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        ForEach(patternsInProgress) { pattern in
                            NavigationLink(destination: GuidedMakeView(initialPattern: pattern)) {
                                ProgressCard(pattern: pattern)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    
    private var patternsInProgress: [CrochetPattern] {
        store.patterns.filter { $0.isInProgress || $0.hasGuidedProgress }
    }
    
    private var emptyProgressState: some View {
        VStack(spacing: 14) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 32))
                .foregroundColor(DS.secondaryText.opacity(0.4))
            
            Text("No projects in progress")
                .font(DS.body(15))
                .foregroundColor(DS.secondaryText.opacity(0.6))
            
            Text("Start crafting to see your progress here!")
                .font(DS.caption(13))
                .foregroundColor(DS.secondaryText.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .cardStyle(color: Color.white.opacity(0.7))
    }
    
    
    private var myCraftJournalSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("My Craft Journals")
                    .font(DS.heading(22))
                    .foregroundColor(DS.mainText)
                
                Spacer()
                
                NavigationLink(destination: MyCraftsView()) {
                    Text("View")
                        .font(DS.body(15))
                        .foregroundColor(DS.appMainColor)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DS.appMainColor)
                }
            }
            .padding(.horizontal, 24)
            
            if store.completedCrafts.isEmpty {
                emptyJournalState
                    .padding(.horizontal, 24)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        ForEach(store.completedCrafts.prefix(6)) { craft in
                            NavigationLink(destination: MyCraftsView()) {
                                JournalCard(craft: craft)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    
    private var emptyJournalState: some View {
        VStack(spacing: 14) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 32))
                .foregroundColor(DS.secondaryText.opacity(0.4))
            
            Text("No finished projects yet")
                .font(DS.body(15))
                .foregroundColor(DS.secondaryText.opacity(0.6))
            
            Text("Complete a project to add it to your journal!")
                .font(DS.caption(13))
                .foregroundColor(DS.secondaryText.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .cardStyle(color: Color.white.opacity(0.7))
    }
}


private struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(DS.appMainColor.opacity(0.15))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(DS.appMainColor)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(DS.mainText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Text(subtitle)
                .font(DS.caption(12))
                .foregroundColor(DS.secondaryText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 200)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DS.cardBg)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }
}


private struct ProgressCard: View {
    let pattern: CrochetPattern
    
    private var progressPercent: Double {
        if let guided = pattern.guidedProgress {
            return guided.progressFraction
        } else if pattern.isInProgress {
            let totalCells = pattern.width * pattern.height
            guard totalCells > 0, let row = pattern.lastMarkedRow, let col = pattern.lastMarkedColumn else {
                return 0
            }
            let completedCells = row * pattern.width + col + 1
            return Double(completedCells) / Double(totalCells)
        }
        return 0
    }
    
    private var progressPercentInt: Int {
        Int(progressPercent * 100)
    }
    
    private var startedText: String {
        let days = Calendar.current.dateComponents([.day], from: pattern.createdDate, to: Date()).day ?? 0
        if days == 0 {
            return "Started today"
        } else if days == 1 {
            return "Started yesterday"
        } else if days < 7 {
            return "Started \(days) days ago"
        } else {
            return "Started \(days / 7) week\(days / 7 == 1 ? "" : "s") ago"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .topTrailing) {
                patternPreview
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(pattern.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(DS.mainText)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Text("\(progressPercentInt)%")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(DS.appMainColor)
                    
                    Text("completed")
                        .font(DS.caption(12))
                        .foregroundColor(DS.appMainColor.opacity(0.8))
                }
                
                Text(startedText)
                    .font(DS.caption(12))
                    .foregroundColor(DS.secondaryText)
                
                ProgressBarView(progress: progressPercent, height: 7)
                    .padding(.top, 6)
                
                HStack {
                    Spacer()
                    Text("Resume Crafting")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(DS.mainText)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                        )
                    Spacer()
                }
                .padding(.top, 10)
            }
        }
        .frame(width: 220)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DS.cardBg)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }
    
    private var patternPreview: some View {
        MiniGridCanvas(pattern: pattern)
    }
}


private struct JournalCard: View {
    let craft: CompletedCraft
    
    private var completionDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "Finished \(formatter.string(from: craft.completionDate))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let image = craft.finishedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else if let preview = craft.patternPreview {
                Image(uiImage: preview)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(DS.secondaryText.opacity(0.1))
                    .frame(height: 140)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundColor(DS.secondaryText.opacity(0.3))
                    )
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(craft.projectName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(DS.mainText)
                    .lineLimit(1)
                
                Text(completionDateText)
                    .font(DS.caption(12))
                    .foregroundColor(DS.secondaryText)
            }
        }
        .frame(width: 180)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DS.cardBg)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }
}


private struct HomeGridCard: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 38, weight: .medium))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(height: 160)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(DS.appMainColor.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 3)
        )
        .shadow(color: .pink.opacity(0.20), radius: 10, x: 0, y: 4)
    }
}
