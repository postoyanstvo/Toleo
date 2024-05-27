import Foundation

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode,
                      let data = data else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }

                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }
        return task
    }
}

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = ApiConstants.defaultBaseURL
    ) -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL) else { fatalError("Failed to create URL")}
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
}
