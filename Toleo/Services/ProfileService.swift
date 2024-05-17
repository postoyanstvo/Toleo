import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    private var task: URLSessionTask?
    
    private(set) var profile: Profile?
    
    func fetchProfile(with token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = profileRequest(withToken: token) else {
            completion(.failure(URLError(.badURL)))
            print("Ошибка в [ProfileService].[fetchProfile]: \(URLError(.badURL).errorCode) - \(URLError(.badURL).errorUserInfo)")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let profileResult):
                    let profile = Profile(from: profileResult)
                    self.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    completion(.failure(error))
                    print("Ошибка в [ProfileService].[fetchProfile]: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    private func profileRequest(withToken token: String) -> URLRequest? {
        var request = URLRequest.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            baseURL: ApiConstants.defaultBaseURL
        )
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
