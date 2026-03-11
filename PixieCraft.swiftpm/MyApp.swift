import SwiftUI

@main
struct MyApp: App {
    @StateObject private var store = PatternStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
