import UIKit

final class ImagesListService {
    private (set) var photos: [Photo] = []
    private var currentPage: Int = 0
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var task: URLSessionTask?
    private let tokenStorage = OAuth2TokenStorage.shared
    private var isLoading = false
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage += 1
        guard let request = createRequest(page: currentPage) else {
            isLoading = false
            currentPage -= 1
            print("Ошибка в [ImagesListService].[fetchPhotosNextPage]: \(URLError(.badURL).errorCode) - \(URLError(.badURL).errorUserInfo)")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let photoResults):
                    let newPhotos = photoResults.map { Photo(from: $0) }
                    self?.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
                case .failure(let error):
                    self?.currentPage -= 1
                    print("Ошибка в [ImagesListService].[fetchPhotosNextPage]: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    private func createRequest(page: Int) -> URLRequest? {
        guard let token = tokenStorage.token else { return nil }
        var request = URLRequest.makeHTTPRequest(
            path: "/photos?page=\(page)",
            httpMethod: "GET",
            baseURL: ApiConstants.defaultBaseURL
        )
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = tokenStorage.token else {
            return
        }
        
        let url = URL(string: "https://api.unsplash.com/photos/" + "\(photoId)/like")!
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        struct EmptyResponse: Decodable {}
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<EmptyResponse, Error>) in
            switch result {
            case .success:
                if let index = self?.photos.firstIndex(where: { $0.id == photoId }) {
                    self?.photos[index].isLiked = isLike
                    NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
