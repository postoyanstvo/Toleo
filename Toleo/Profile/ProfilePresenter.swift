import Foundation
import WebKit

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func updateAvatar()
    func fetchUserProfile()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileImageService = ProfileImageService.shared
    
    init(view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
    func updateAvatar() {
        guard let profileImageURL = profileImageService.profileImageURL,
              let url = URL(string: profileImageURL) else {
            self.view?.showError(title: "Error", message: "Invalid URL for avatar")
            return
        }
        self.view?.updateAvatar(url: url)
    }
    
    func fetchUserProfile() {
        view?.addGradientToLabels()
        guard let token = tokenStorage.token else {
            view?.showError(title: "Error", message: "Token not found")
            return
        }
        
        profileService.fetchProfile(with: token) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.removeGradientsFromLabels()
                switch result {
                case .success(let profile):
                    self?.view?.updateUIWithProfile(profile)
                    self?.fetchProfileImageURL(for: profile.username)
                case .failure(let error):
                    self?.view?.showError(title: "Error", message: "Failed to fetch profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchProfileImageURL(for username: String) {
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    self?.view?.updateAvatar(url: URL(string: url)!)
                case .failure(let error):
                    self?.view?.showError(title: "Error", message: "Failed to load profile image: \(error.localizedDescription) ")
                }
            }
        }
    }
}

