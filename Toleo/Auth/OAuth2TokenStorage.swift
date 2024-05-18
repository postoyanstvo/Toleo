import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    private let tokenKey = "OAuth2Token"
    private let keychain = KeychainWrapper.standard
    
    var token: String? {
        get {
            return keychain.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                keychain.set(newValue, forKey: tokenKey)
            } else {
                keychain.removeObject(forKey: tokenKey)
            }
        }
    }
    
    func hasToken() -> Bool {
        return KeychainWrapper.standard.hasValue(forKey: tokenKey)
    }
}
