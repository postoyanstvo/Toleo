import Foundation

final class WebViewViewControllerSpy: WebViewProtocol {
    var presenter: Toleo.WebViewPresenterProtocol?
    
    var loadRequestCalled: Bool = false
    var lastProgressValue: Float?
    
    func loadRequest(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func updateProgress(progress: Float) {
        lastProgressValue = progress
    }
}
