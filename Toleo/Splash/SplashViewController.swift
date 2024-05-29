import UIKit
import ProgressHUD

final class SplashViewController: UIViewController, UITabBarControllerDelegate {
    private let oauth2Service = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let authConfiguration = AuthConfiguration.standard
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    let splashLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Vector")
        return imageView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureSplashLogo()
        checkToken()
    }
    
    private func checkToken() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.tokenStorage.hasToken() {
                self.switchToTabBarController()
            } else {
                self.showAuthViewController()
            }
        }
    }
    
    private func configureSubviews() {
        view.addSubview(splashLogo)
        view.backgroundColor = .ypBlack
    }
    
    private func configureSplashLogo() {
        splashLogo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            splashLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension SplashViewController {
    private func switchToTabBarController() {
        let tabBarViewController = TabBarViewController()
        tabBarViewController.delegate = self
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = tabBarViewController
            window.makeKeyAndVisible()
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
        }
    }
    
    private func showAuthViewController() {
        let authViewController = OAuthViewController(delegate: self, authConfiguration: authConfiguration)
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
}

extension SplashViewController: OAuthViewControllerDelegate {
    func authViewController(_ vc: OAuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                AlertService.showAlert(on: self, title: "Что-то пошло не так :(", message: "Не удалось войти в систему")
                break
            }
        }
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(with: token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success(let profile):
                self.profileImageService.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                AlertService.showAlert(on: self, title: "Что-то пошло не так :(", message: "Не удалось загрузить профиль")
                break
            }
        }
    }
}
