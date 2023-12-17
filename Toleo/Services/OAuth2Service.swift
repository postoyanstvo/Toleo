import UIKit

final class OAuth2Service {
    
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    func fetchOAuthToken(
        _ code: String,
        copletion: @escaping(Result<String, Error>) -> Void
    ) {
        let request = authTokenRequest(code: code)
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                copletion(.success(authToken))
            case .failure(let error):
                copletion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(AccessKey)"
            + "&&client_secret=\(SecretKey)"
            + "&&redirect_uri=\(RedirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: BaseURL
        )
    }
}

extension OAuth2Service {
    private func object(
        for request: URLRequest,
        completion: @escaping(Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return URLSession.shared.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
            }
            completion(response)
        }
    }
    
    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createdAt = "created_at"
        }
    }
}

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping(Result<Data, Error>) -> Void
) -> URLSessionDataTask {
        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data,
               let reponse = response,
               let statusCode = (reponse as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletion(.success(data))
                } else {
                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
            }
        }
        task.resume()
        return task
    }
}

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = DefaultBaseURL
    ) -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL) else { fatalError("Failed to create URL")}
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
}
