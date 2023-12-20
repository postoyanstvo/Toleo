import Foundation

final class OAuth2TokenStorage {
    var token: String? {
        get { UserDefaults.standard.string(forKey: "OAuth2Token") }
        set { UserDefaults.standard.setValue(newValue, forKey: "OAuth2Token") }
    }
}
