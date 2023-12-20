import UIKit

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
