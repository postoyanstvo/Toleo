import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    //MARK: - Properties
    
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
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
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "Exit")!,
            target: ProfileViewController.self,
            action: #selector(Self.didTapLogoutButton)
        )
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
        fetchUserProfile()
        startLoadingAnimations()
        addProfileImageServiceObserver()
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
        print("Tapped Exit")
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
            avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "user_photo"))
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
    
    func loadingAnimation(loadingLabel: UILabel) {
        let loadingText = "Loading"
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
            loadingLabel.text = "\(loadingText)."
        }, completion: nil)
    }
    
    func startLoadingAnimations() {
        loadingAnimation(loadingLabel: nameLabel)
        loadingAnimation(loadingLabel: loginLabel)
        loadingAnimation(loadingLabel: descriptionLabel)
    }
}
