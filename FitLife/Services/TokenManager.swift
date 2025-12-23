import Foundation
import Security

class TokenManager {
    static let shared = TokenManager()
    
    private let accessTokenKey = "fitlife_access_token"
    private let refreshTokenKey = "fitlife_refresh_token"
    private let tokenExpiryKey = "fitlife_token_expiry"
    private let userIdKey = "fitlife_user_id"
    private let userEmailKey = "fitlife_user_email"
    private let userNameKey = "fitlife_user_name"
    
    private init() {}
    
    // MARK: - Token Management
    
    func saveTokens(accessToken: String, refreshToken: String, expiresIn: Int64) {
        let expiryTime = Date().timeIntervalSince1970 + Double(expiresIn)
        
        saveToKeychain(key: accessTokenKey, value: accessToken)
        saveToKeychain(key: refreshTokenKey, value: refreshToken)
        UserDefaults.standard.set(expiryTime, forKey: tokenExpiryKey)
    }
    
    func getAccessToken() -> String? {
        guard isTokenValid() else { return nil }
        return getFromKeychain(key: accessTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return getFromKeychain(key: refreshTokenKey)
    }
    
    func isTokenValid() -> Bool {
        let expiryTime = UserDefaults.standard.double(forKey: tokenExpiryKey)
        return Date().timeIntervalSince1970 < expiryTime
    }
    
    func saveUserInfo(userId: Int64, email: String, name: String) {
        UserDefaults.standard.set(userId, forKey: userIdKey)
        UserDefaults.standard.set(email, forKey: userEmailKey)
        UserDefaults.standard.set(name, forKey: userNameKey)
    }
    
    func getUserId() -> Int64 {
        return UserDefaults.standard.object(forKey: userIdKey) as? Int64 ?? -1
    }
    
    func getUserEmail() -> String? {
        return UserDefaults.standard.string(forKey: userEmailKey)
    }
    
    func getUserName() -> String? {
        return UserDefaults.standard.string(forKey: userNameKey)
    }
    
    func clearTokens() {
        deleteFromKeychain(key: accessTokenKey)
        deleteFromKeychain(key: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: tokenExpiryKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: userEmailKey)
        UserDefaults.standard.removeObject(forKey: userNameKey)
    }
    
    func isLoggedIn() -> Bool {
        return getAccessToken() != nil && isTokenValid()
    }
    
    // MARK: - Keychain Operations
    
    private func saveToKeychain(key: String, value: String) {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}