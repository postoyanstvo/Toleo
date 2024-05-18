import Foundation

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private var task: URLSessionTask?
    private let tokenStorage = OAuth2TokenStorage.shared
    static let shared = ProfileImageService()
    private init() {}
    private (set) var profileImageURL: String?
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = createRequest(forUsername: username) else {
            completion(.failure(URLError(.badURL)))
            print("Ошибка в [ProfileImageService].[fetchProfileImageURL]: \(URLError(.badURL).errorCode) - \(URLError(.badURL).errorUserInfo)")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let userResult):
                    self?.profileImageURL = userResult.profileImage.small
                    NotificationCenter.default.post(
                        name: Self.didChangeNotification,
                        object: self,
                        userInfo: ["URL": self?.profileImageURL as Any])
                    completion(.success(userResult.profileImage.small))
                case .failure(let error):
                    print("Ошибка в [ProfileImageService].[fetchProfileImageURL]: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    private func createRequest(forUsername username: String) -> URLRequest? {
        guard let token = tokenStorage.token else { return nil }
        var request = URLRequest.makeHTTPRequest(
            path: "/users/" + username,
            httpMethod: "GET"
        )
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
