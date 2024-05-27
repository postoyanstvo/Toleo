import UIKit

final class OAuthViewController: UIViewController {
    private enum Constants {
        static let sighInButtonHeight: CGFloat = 48
        static let insets: CGFloat = 16
        static let bottomInsets: CGFloat = 90
        static let logoSize: CGFloat = 60
        static let cornerRadius: CGFloat = 16
    }
    
    weak var delegate: OAuthViewControllerDelegate?
    
    private let unsplashLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Vector")
        
        return imageView
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypWhite
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.ypBlack, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.clipsToBounds = true
        button.layer.cornerRadius = Constants.cornerRadius
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
    }
    
    @objc private func signInButtonClicked() {
        let webViewController = WebViewViewController()
        webViewController.delegate = self
    
        let navigationController = UINavigationController(rootViewController: webViewController)
        navigationController.modalPresentationStyle = .fullScreen
        
        present(navigationController, animated: true)
    }
    
    private func configureConstraints() {
        configureUnsplashLogoImage()
        configureSignInButtonConstraints()
    }
    
    private func configureSubviews() {
        view.addSubview(signInButton)
        view.addSubview(unsplashLogoImage)
        view.backgroundColor = .ypBlack
        
        signInButton.addTarget(self, action: #selector(signInButtonClicked), for: .touchUpInside)
    }
    
    private func configureUnsplashLogoImage() {
        unsplashLogoImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            unsplashLogoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unsplashLogoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureSignInButtonConstraints() {
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInButton.heightAnchor.constraint(equalToConstant: Constants.sighInButtonHeight),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.insets),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.insets),
            signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomInsets)
        ])
    }
}

extension OAuthViewController: WebViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

protocol OAuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: OAuthViewController, didAuthenticateWithCode code: String)
}
