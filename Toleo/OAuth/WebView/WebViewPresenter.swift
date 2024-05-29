import UIKit
import WebKit

protocol WebViewPresenterProtocol: AnyObject {
    func loadWebView()
    func fetchCode(from navigationAction: WKNavigationAction) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    weak var view: WebViewProtocol?
    private var authHelper: AuthHelperProtocol
    
    init(view: WebViewProtocol? = nil, authHelper: AuthHelperProtocol) {
        self.view = view
        self.authHelper = authHelper
    }
    
    func loadWebView() {
        guard let request = authHelper.authRequest() else {
            return
        }
        view?.loadRequest(request: request)
    }
    
    func fetchCode(from navigationAction: WKNavigationAction) -> String? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        return authHelper.code(from: url)
    }
    
    func updateProgress(progress: Float) {
        let isProgressComplete = progress >= 1.0
        view?.updateProgress(progress: isProgressComplete ? 0: progress)
    }
}
