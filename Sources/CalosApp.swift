import SwiftUI

@main
struct CalosApp: App {
    @StateObject private var store = CalorieStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
