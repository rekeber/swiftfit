import Foundation

// MARK: - Authentication Models

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
    let age: Int
    let height: Double
    let currentWeight: Double
    let targetWeight: Double
    let goal: String
    let activityLevel: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int64
    let user: User
}

// MARK: - User Model

struct User: Codable, Identifiable {
    let id: Int64
    let email: String
    let name: String
    let age: Int
    let height: Double
    let currentWeight: Double
    let targetWeight: Double
    let goal: String
    let activityLevel: String
    let profileImageUrl: String?
    let isActive: Bool
    let emailVerified: Bool
    let streakDays: Int
    let totalPoints: Int
    let totalWeightLost: Double
    let createdAt: String
    let lastLogin: String?
    let allergies: [String]
    let dietaryRestrictions: [String]
    
    var goalDisplayName: String {
        switch goal {
        case "PERDER_PESO": return "Perder peso"
        case "MANTENER": return "Mantener peso"
        case "GANAR_MUSCULO": return "Ganar músculo"
        default: return goal
        }
    }
    
    var activityLevelDisplayName: String {
        switch activityLevel {
        case "SEDENTARIO": return "Sedentario"
        case "LIGERO": return "Ligero"
        case "MODERADO": return "Moderado"
        case "ACTIVO": return "Activo"
        case "MUY_ACTIVO": return "Muy activo"
        default: return activityLevel
        }
    }
}

// MARK: - Food Models

struct Food: Codable, Identifiable {
    let id: Int64
    let name: String
    let brand: String?
    let barcode: String?
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let fiberPer100g: Double
    let servingSize: String?
    let imageUrl: String?
    let isHealthy: Bool
    let glycemicIndex: Double?
    let categories: [String]
    let allergens: [String]
    let vitamins: [String: Double]
    let minerals: [String: Double]
}

struct FoodSearchResponse: Codable {
    let content: [Food]
    let totalElements: Int64
    let totalPages: Int
    let size: Int
    let number: Int
}

struct FoodLogRequest: Codable {
    let foodId: Int64
    let quantity: Double
    let unit: String
    let mealType: String
    let date: String
}

struct FoodLog: Codable, Identifiable {
    let id: Int64
    let food: Food
    let quantity: Double
    let unit: String
    let mealType: String
    let date: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    
    var mealTypeDisplayName: String {
        switch mealType {
        case "BREAKFAST": return "Desayuno"
        case "LUNCH": return "Almuerzo"
        case "DINNER": return "Cena"
        case "SNACK": return "Snack"
        default: return mealType
        }
    }
}

struct DailyNutrition: Codable {
    let date: String
    let totalCalories: Double
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
    let totalFiber: Double
    let calorieGoal: Double
    let proteinGoal: Double
    let carbsGoal: Double
    let fatGoal: Double
    let meals: [String: [FoodLog]]
}

// MARK: - Exercise Models

struct Exercise: Codable, Identifiable {
    let id: Int64
    let name: String
    let category: String
    let muscleGroups: [String]
    let equipment: String?
    let instructions: String
    let imageUrl: String?
    let videoUrl: String?
    let difficulty: String
    let caloriesPerMinute: Double
    
    var difficultyDisplayName: String {
        switch difficulty {
        case "BEGINNER": return "Principiante"
        case "INTERMEDIATE": return "Intermedio"
        case "ADVANCED": return "Avanzado"
        default: return difficulty
        }
    }
}

struct ExerciseLogRequest: Codable {
    let exerciseId: Int64
    let duration: Int
    let sets: Int?
    let reps: Int?
    let weight: Double?
    let date: String
    let notes: String?
}

struct ExerciseLog: Codable, Identifiable {
    let id: Int64
    let exercise: Exercise
    let duration: Int
    let sets: Int?
    let reps: Int?
    let weight: Double?
    let date: String
    let caloriesBurned: Double
    let notes: String?
}

// MARK: - Social Models

struct Post: Codable, Identifiable {
    let id: Int64
    let user: User
    let content: String
    let imageUrl: String?
    let type: String
    let likes: Int
    let comments: Int
    let isLiked: Bool
    let createdAt: String
    let tags: [String]
    
    var typeDisplayName: String {
        switch type {
        case "WORKOUT": return "Entrenamiento"
        case "MEAL": return "Comida"
        case "ACHIEVEMENT": return "Logro"
        case "GENERAL": return "General"
        default: return type
        }
    }
}

struct CreatePostRequest: Codable {
    let content: String
    let imageUrl: String?
    let type: String
    let tags: [String]
}

// MARK: - Friends Models

struct FriendRequest: Codable, Identifiable {
    let id: Int64
    let sender: User
    let receiver: User
    let status: String
    let createdAt: String
    
    var statusDisplayName: String {
        switch status {
        case "PENDING": return "Pendiente"
        case "ACCEPTED": return "Aceptada"
        case "REJECTED": return "Rechazada"
        default: return status
        }
    }
}

struct FriendRequestRequest: Codable {
    let receiverEmail: String
}