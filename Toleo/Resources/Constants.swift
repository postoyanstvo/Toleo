import UIKit

let AccessKey = "5QWF5THq5Vq4vhdy0EONQ-UIBHDzbzY6r_fhXyyLdwY"
let SecretKey = "hoHWy-alem7AcpaKYCQqvnO_YlSmIGL6r__tZs-AWI4"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
var DefaultBaseURL: URL {
    guard let url = URL(string: "https://api.unsplash.com") else { fatalError("Failed to create Default Base URL") }
    return url
}
var BaseURL: URL {
    guard let url = URL(string: "https://unsplash.com") else { fatalError("Failed to create Base URL") }
    return url
}
let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
