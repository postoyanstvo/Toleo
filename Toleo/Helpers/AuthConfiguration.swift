import Foundation

enum ApiConstants {
    static let accessKey: String = "5QWF5THq5Vq4vhdy0EONQ-UIBHDzbzY6r_fhXyyLdwY"
    static let secretKey: String = "hoHWy-alem7AcpaKYCQqvnO_YlSmIGL6r__tZs-AWI4"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope: String = "public+read_user+write_likes"
    static var defaultBaseURL: URL {
        guard let url = URL(string: "https://api.unsplash.com") else { fatalError("Failed to create Default Base URL") }
        return url
    }
    static var baseURL: URL {
        guard let url = URL(string: "https://unsplash.com") else { fatalError("Failed to create Base URL") }
        return url
    }
    static let unsplashAuthorizeURLString: String = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: ApiConstants.accessKey,
                                 secretKey: ApiConstants.secretKey,
                                 redirectURI: ApiConstants.redirectURI,
                                 accessScope: ApiConstants.accessScope,
                                 authURLString: ApiConstants.unsplashAuthorizeURLString,
                                 defaultBaseURL: ApiConstants.defaultBaseURL)
    }
}
