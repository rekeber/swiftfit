import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared
    private let tokenManager = TokenManager.shared
    
    init() {
        checkLoginStatus()
    }
    
    private func checkLoginStatus() {
        isLoggedIn = tokenManager.isLoggedIn()
        
        if isLoggedIn {
            // Load user profile if logged in
            loadUserProfile()
        }
    }
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        apiService.login(email: email, password: password)
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        
                        if case .failure(let error) = completion {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] authResponse in
                    DispatchQueue.main.async {
                        self?.handleAuthSuccess(authResponse)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func register(
        email: String,
        password: String,
        name: String,
        age: Int,
        height: Double,
        currentWeight: Double,
        targetWeight: Double,
        goal: String,
        activityLevel: String
    ) {
        isLoading = true
        errorMessage = nil
        
        let request = RegisterRequest(
            email: email,
            password: password,
            name: name,
            age: age,
            height: height,
            currentWeight: currentWeight,
            targetWeight: targetWeight,
            goal: goal,
            activityLevel: activityLevel
        )
        
        apiService.register(request: request)
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        
                        if case .failure(let error) = completion {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                },
                receiveValue: { [weak self] authResponse in
                    DispatchQueue.main.async {
                        self?.handleAuthSuccess(authResponse)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func logout() {
        isLoading = true
        
        apiService.logout()
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        self?.handleLogout()
                        
                        if case .failure(let error) = completion {
                            print("Logout error: \(error.localizedDescription)")
                            // Still logout locally even if API call fails
                        }
                    }
                },
                receiveValue: { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.handleLogout()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshToken() {
        guard let refreshToken = tokenManager.getRefreshToken() else {
            handleLogout()
            return
        }
        
        apiService.refreshToken(refreshToken: refreshToken)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(_) = completion {
                        DispatchQueue.main.async {
                            self?.handleLogout()
                        }
                    }
                },
                receiveValue: { [weak self] authResponse in
                    DispatchQueue.main.async {
                        self?.handleAuthSuccess(authResponse)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadUserProfile() {
        apiService.getUserProfile()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(_) = completion {
                        // If profile loading fails, try to refresh token
                        self?.refreshToken()
                    }
                },
                receiveValue: { [weak self] user in
                    DispatchQueue.main.async {
                        self?.currentUser = user
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleAuthSuccess(_ authResponse: AuthResponse) {
        // Save tokens
        tokenManager.saveTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
            expiresIn: authResponse.expiresIn
        )
        
        // Save user info
        tokenManager.saveUserInfo(
            userId: authResponse.user.id,
            email: authResponse.user.email,
            name: authResponse.user.name
        )
        
        // Update state
        isLoggedIn = true
        currentUser = authResponse.user
        errorMessage = nil
    }
    
    private func handleLogout() {
        tokenManager.clearTokens()
        isLoggedIn = false
        currentUser = nil
        errorMessage = nil
    }
    
    func clearError() {
        errorMessage = nil
    }
}