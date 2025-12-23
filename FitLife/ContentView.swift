import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            authViewModel.checkAuthenticationStatus()
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var messageStore: MessageStore
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            ExerciseView()
                .tabItem {
                    Image(systemName: "figure.strengthtraining.traditional")
                    Text("Ejercicios")
                }
                .tag(1)
            
            NutritionView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Nutrición")
                }
                .tag(2)
            
            SocialView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Social")
                }
                .tag(3)
            
            MessagesView()
                .tabItem {
                    Image(systemName: messageStore.unreadCount > 0 ? "message.badge.fill" : "message.fill")
                    Text("Mensajes")
                }
                .badge(messageStore.unreadCount > 0 ? messageStore.unreadCount : nil)
                .tag(4)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Perfil")
                }
                .tag(5)
        }
        .accentColor(.blue)
    }
}

struct AuthenticationView: View {
    @State private var showingRegister = false
    
    var body: some View {
        NavigationView {
            if showingRegister {
                RegisterView(showingRegister: $showingRegister)
            } else {
                LoginView(showingRegister: $showingRegister)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(UserStore())
        .environmentObject(ExerciseStore())
        .environmentObject(NutritionStore())
        .environmentObject(SocialStore())
        .environmentObject(MessageStore())
}