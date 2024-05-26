import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    
    //MARK: - Properties
    
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private var animationLayers = Set<CALayer>()
    private var gradientLayer: CAGradientLayer?
    
    private let avatarImageView: UIImageView = {
        let avatarImage = UIImage(named: "EmpthyProfilePhoto")
        let avatarImageView = UIImageView(image: avatarImage)
        avatarImageView.tintColor = .ypGray
        return avatarImageView
    } ()
    
    private var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "..."
        nameLabel.font = UIFont(name: "SF Pro", size: 23)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .ypWhite
        return nameLabel
    } ()
    
    private var loginLabel: UILabel = {
        let loginLabel = UILabel()
        loginLabel.text = "..."
        loginLabel.font = UIFont(name: "SF Pro", size: 13)
        loginLabel.textColor = .ypGray
        return loginLabel
    } ()
    
    private var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "..."
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = UIFont(name: "SF Pro", size: 13)
        return descriptionLabel
    } ()
    
    private var logoutButton: UIButton = {
        let logoutButton = UIButton()
        logoutButton.setImage(UIImage(named: "Exit"), for: .normal)
        logoutButton.tintColor = .ypRed
        
        return logoutButton
    } ()
    
    //MARK: - Lifecicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypBlack
        setupAvatarImageView()
        setupNameLabel()
        setupLoginLabel()
        setupDescriptionLabel()
        setupLogoutButton()
        addGradientLayer()
        addGradientToLabels()
        fetchUserProfile()
        addProfileImageServiceObserver()
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
    //MARK: - Functions
    
    private func setupAvatarImageView() {
        view.addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 70 / 2
    }
    
    private func setupNameLabel() {
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupLoginLabel() {
        view.addSubview(loginLabel)
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    private func setupDescriptionLabel() {
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    private func setupLogoutButton() {
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    @objc
    private func didTapLogoutButton() {
        presentLogoutConfirmation()
    }
    
    private func presentLogoutConfirmation() {
        let alertController = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.logout()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        
        present(alertController, animated: true)
    }
    
    private func logout() {
        tokenStorage.removeToken()
        cleanCookiesAndData()
        navigateToInitialScreen()
    }
    
    private func cleanCookiesAndData() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func navigateToInitialScreen() {
        DispatchQueue.main.async {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.switchToInitialViewController()
            }
        }
    }
    
    private func updateUIWithProfile(_ profile: Profile) {
        nameLabel.text = profile.name
        loginLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func fetchUserProfile() {
        guard let token = tokenStorage.token else {
            print("Error: there is no token")
            return
        }
        
        profileService.fetchProfile(with: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.updateUIWithProfile(profile)
                    self?.fetchProfileImageURL(for: profile.username)
                case .failure(let error):
                    print("Error fetching profile: \(error)")
                }
            }
        }
    }
    
    private func fetchProfileImageURL(for username: String) {
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.updateAvatar()
                case .failure(let error):
                    print("Error while getting profile Image URL: \(error)")
                }
            }
        }
    }
    
    private func updateAvatar() {                                   
        guard
            let profileImageURL = profileImageService.profileImageURL,
            let url = URL(string: profileImageURL)
        else { return }
            avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "EmpthyProfilePhoto"))
    }
    
    private func addProfileImageServiceObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func addGradientLayer() {
        let gradient = createGradientLayer()
        gradientLayer = gradient
        avatarImageView.layer.insertSublayer(gradient, at: 0)
    }
    
    private func addGradientToLabels() {
        [nameLabel, loginLabel, descriptionLabel].forEach { label in
            let gradient = createGradientLayer()
            label.layer.insertSublayer(gradient, at: 0)
            animationLayers.insert(gradient)
        }
    }
    
    private func removeGradientLayer() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
    
    private func removeGradientsFromLabels() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
    
    private func createGradientLayer() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        
        gradient.locations = [0, 0.1, 0.3]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 9
        gradient.masksToBounds = true
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        return gradient
    }
    
    private func setGradientFrames() {
        gradientLayer?.frame = avatarImageView.bounds
        gradientLayer?.cornerRadius = avatarImageView.frame.height / 2
        
        for label in [nameLabel, loginLabel, descriptionLabel] {
            let gradientLayer = animationLayers.first(where: { $0.superlayer == label.layer })
            gradientLayer?.frame = label.bounds
        }
    }
}
