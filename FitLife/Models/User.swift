import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let profileImage: String?
    let age: Int
    let height: Double
    let currentWeight: Double
    let targetWeight: Double
    let activityLevel: ActivityLevel
    let goal: FitnessGoal
    let dietaryRestrictions: [String]
    let allergies: [String]
    let createdAt: String
    let lastLogin: String?
    let streakDays: Int
    let totalWeightLost: Double
    let friendIds: [String]
    let preferences: [String: String]
    
    var bmi: Double {
        let heightInMeters = height / 100
        return currentWeight / (heightInMeters * heightInMeters)
    }
    
    var dailyCalories: Double {
        // Mifflin-St Jeor Equation (simplified for male)
        let bmr = (10 * currentWeight) + (6.25 * height) - (5 * Double(age)) + 5
        
        let activityMultiplier: Double = switch activityLevel {
        case .sedentario: 1.2
        case .ligero: 1.375
        case .moderado: 1.55
        case .activo: 1.725
        case .muyActivo: 1.9
        }
        
        let maintenanceCalories = bmr * activityMultiplier
        
        return switch goal {
        case .perderPeso: maintenanceCalories - 500
        case .ganarMusculo: maintenanceCalories + 300
        case .mantener: maintenanceCalories
        }
    }
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentario = "sedentario"
    case ligero = "ligero"
    case moderado = "moderado"
    case activo = "activo"
    case muyActivo = "muy_activo"
    
    var displayName: String {
        switch self {
        case .sedentario: return "Sedentario"
        case .ligero: return "Ligero"
        case .moderado: return "Moderado"
        case .activo: return "Activo"
        case .muyActivo: return "Muy Activo"
        }
    }
}

enum FitnessGoal: String, Codable, CaseIterable {
    case perderPeso = "perder_peso"
    case mantener = "mantener"
    case ganarMusculo = "ganar_musculo"
    
    var displayName: String {
        switch self {
        case .perderPeso: return "Perder Peso"
        case .mantener: return "Mantener Peso"
        case .ganarMusculo: return "Ganar Músculo"
        }
    }
}

struct UserStats: Codable {
    let bmi: Double
    let dailyCalories: Double
    let weeklyWorkouts: Int
    let weeklyCaloriesBurned: Double
    let currentStreak: Int
}