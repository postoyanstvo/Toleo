import UIKit

final class OAuth2Service {
    private var task: URLSessionTask?
    private var lastCode: String?
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private (set) var authToken: String? {
        get { return tokenStorage.token }
        set { tokenStorage.token = newValue }
    }
    
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping(Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        guard code != lastCode else { return }
        task?.cancel()
        lastCode = code
        
        let request = authTokenRequest(code: code)
        let task = URLSession.shared.objectTask(for: request) { (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let tokenResponse):
                self.tokenStorage.token = tokenResponse.accessToken
                completion(.success(tokenResponse.accessToken))
            case .failure(let error):
                completion(.failure(error))
                print("Ошибка в [OAuth2Service].[fetchOAuthToken]: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(ApiConstants.accessKey)"
            + "&&client_secret=\(ApiConstants.secretKey)"
            + "&&redirect_uri=\(ApiConstants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: ApiConstants.baseURL
        )
    }
}
