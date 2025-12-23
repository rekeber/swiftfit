import SwiftUI

@main
struct FitLifeApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userStore = UserStore()
    @StateObject private var exerciseStore = ExerciseStore()
    @StateObject private var nutritionStore = NutritionStore()
    @StateObject private var socialStore = SocialStore()
    @StateObject private var messageStore = MessageStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(userStore)
                .environmentObject(exerciseStore)
                .environmentObject(nutritionStore)
                .environmentObject(socialStore)
                .environmentObject(messageStore)
                .preferredColorScheme(.light) // Can be changed to support dark mode
        }
    }
}