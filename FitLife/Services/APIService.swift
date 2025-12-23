import Foundation
import Combine

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:8080/api/v1"
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Authentication
    
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        let request = LoginRequest(email: email, password: password)
        return post(endpoint: "/auth/login", body: request)
    }
    
    func register(request: RegisterRequest) -> AnyPublisher<AuthResponse, Error> {
        return post(endpoint: "/auth/register", body: request)
    }
    
    func refreshToken(refreshToken: String) -> AnyPublisher<AuthResponse, Error> {
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        return post(endpoint: "/auth/refresh", body: request)
    }
    
    func logout() -> AnyPublisher<Void, Error> {
        return post(endpoint: "/auth/logout", body: EmptyRequest())
            .map { (_: EmptyResponse) in () }
            .eraseToAnyPublisher()
    }
    
    // MARK: - User
    
    func getUserProfile() -> AnyPublisher<User, Error> {
        return get(endpoint: "/users/profile")
    }
    
    func updateUserProfile(user: User) -> AnyPublisher<User, Error> {
        return put(endpoint: "/users/profile", body: user)
    }
    
    // MARK: - Food
    
    func searchFoods(query: String, page: Int = 0, size: Int = 20) -> AnyPublisher<FoodSearchResponse, Error> {
        let queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)")
        ]
        return get(endpoint: "/foods/search", queryItems: queryItems)
    }
    
    func getDailyNutrition(date: String) -> AnyPublisher<DailyNutrition, Error> {
        let queryItems = [URLQueryItem(name: "date", value: date)]
        return get(endpoint: "/nutrition/daily", queryItems: queryItems)
    }
    
    func logFood(request: FoodLogRequest) -> AnyPublisher<FoodLog, Error> {
        return post(endpoint: "/nutrition/log", body: request)
    }
    
    // MARK: - Exercise
    
    func getExercises() -> AnyPublisher<[Exercise], Error> {
        return get(endpoint: "/exercises")
    }
    
    func logExercise(request: ExerciseLogRequest) -> AnyPublisher<ExerciseLog, Error> {
        return post(endpoint: "/exercises/log", body: request)
    }
    
    // MARK: - Social
    
    func getFeed(page: Int = 0) -> AnyPublisher<[Post], Error> {
        let queryItems = [URLQueryItem(name: "page", value: "\(page)")]
        return get(endpoint: "/social/feed", queryItems: queryItems)
    }
    
    func createPost(request: CreatePostRequest) -> AnyPublisher<Post, Error> {
        return post(endpoint: "/social/posts", body: request)
    }
    
    func likePost(postId: Int64) -> AnyPublisher<Void, Error> {
        return post(endpoint: "/social/posts/\(postId)/like", body: EmptyRequest())
            .map { (_: EmptyResponse) in () }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Friends
    
    func getFriends() -> AnyPublisher<[User], Error> {
        return get(endpoint: "/friends")
    }
    
    func sendFriendRequest(email: String) -> AnyPublisher<Void, Error> {
        let request = FriendRequestRequest(receiverEmail: email)
        return post(endpoint: "/friends/request", body: request)
            .map { (_: EmptyResponse) in () }
            .eraseToAnyPublisher()
    }
    
    func getFriendRequests() -> AnyPublisher<[FriendRequest], Error> {
        return get(endpoint: "/friends/requests")
    }
    
    func acceptFriendRequest(requestId: Int64) -> AnyPublisher<Void, Error> {
        return put(endpoint: "/friends/requests/\(requestId)/accept", body: EmptyRequest())
            .map { (_: EmptyResponse) in () }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Generic HTTP Methods
    
    private func get<T: Decodable>(endpoint: String, queryItems: [URLQueryItem]? = nil) -> AnyPublisher<T, Error> {
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addAuthHeader(to: &request)
        
        return session.dataTaskPublisher(for: request)
            .tryMap { try self.handleResponse($0.data, $0.response) }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func post<T: Encodable, U: Decodable>(endpoint: String, body: T) -> AnyPublisher<U, Error> {
        return request(method: "POST", endpoint: endpoint, body: body)
    }
    
    private func put<T: Encodable, U: Decodable>(endpoint: String, body: T) -> AnyPublisher<U, Error> {
        return request(method: "PUT", endpoint: endpoint, body: body)
    }
    
    private func request<T: Encodable, U: Decodable>(method: String, endpoint: String, body: T) -> AnyPublisher<U, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(to: &request)
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { try self.handleResponse($0.data, $0.response) }
            .decode(type: U.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func addAuthHeader(to request: inout URLRequest) {
        if let token = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    private func handleResponse(_ data: Data, _ response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 500...599:
            throw APIError.serverError
        default:
            throw APIError.unknown
        }
    }
}

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .unauthorized:
            return "No autorizado. Por favor inicia sesión nuevamente"
        case .forbidden:
            return "Acceso prohibido"
        case .notFound:
            return "Recurso no encontrado"
        case .serverError:
            return "Error del servidor. Intenta nuevamente"
        case .unknown:
            return "Error desconocido"
        }
    }
}

// MARK: - Empty Types

struct EmptyRequest: Encodable {}
struct EmptyResponse: Decodable {}