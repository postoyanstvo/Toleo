import UIKit
import WebKit

protocol WebViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

protocol WebViewProtocol: AnyObject {
    func loadRequest(request: URLRequest)
    func updateProgress(progress: Float)
}

final class WebViewViewController: UIViewController {
    var presenter: WebViewPresenter?
    weak var delegate: WebViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    private var webView = WKWebView()
    private var progressView = UIProgressView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        setupView()
        presenter?.loadWebView()
        observeValue()
    }
    
    private func loadWebView() {
        var urlComponents = URLComponents(string: ApiConstants.unsplashAuthorizeURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: Constants.clientId, value: ApiConstants.accessKey),
            URLQueryItem(name: Constants.redirectUri, value: ApiConstants.redirectURI),
            URLQueryItem(name: Constants.responseType, value: Constants.code),
            URLQueryItem(name: Constants.scope, value: ApiConstants.accessScope)
        ]
        let url = urlComponents.url!
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func observeValue() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [.new],
            changeHandler: { [weak self] _, change in
                guard let self = self, let newProgress = change.newValue else { return }
                self.presenter?.updateProgress(progress: Float(newProgress))
            })
    }
    
    internal func updateProgress(progress: Float) {
        DispatchQueue.main.async {
            self.progressView.progress = progress
            self.progressView.isHidden = progress == 0
        }
    }
    
    private func setupView() {
        view.addSubview(webView)
        view.addSubview(progressView)
        setupWebViewConstraints()
        setupProgressView()
        configureNavBar()
    }
    
    private func setupWebViewConstraints() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupProgressView() {
        progressView.progressTintColor = UIColor.ypBlack
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    private func configureNavBar() {
        if let backButtonImage = UIImage(named: "Back")?.withRenderingMode(.alwaysOriginal) {
            let backButton = UIBarButtonItem(image: backButtonImage,
                                             style: .plain,
                                             target: self,
                                             action: #selector(backwardButtonClicked))
            navigationItem.leftBarButtonItem = backButton
        }
    }
    
    @objc private func backwardButtonClicked() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let code = presenter?.fetchCode(from: navigationAction) {
                delegate?.webViewViewController(self, didAuthenticateWithCode: code)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
    }
}

extension WebViewViewController: WebViewProtocol {
    func loadRequest(request: URLRequest) {
        webView.load(request)
    }
}
