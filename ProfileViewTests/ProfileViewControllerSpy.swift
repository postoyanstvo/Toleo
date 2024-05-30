import UIKit
@testable import Toleo

class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?

    // Simulated UI components
    var userNameLabel = UILabel()
    var userLoginLabel = UILabel()
    var descriptionLabel = UILabel()
    var avatarImageView = UIImageView()

    // Variables to capture calls
    var updateAvatarCalled = false
    var updateUIWithProfileCalled = false
    var addGradientToLabelsCalled = false
    var removeGradientsFromLabelsCalled = false
    var showErrorCalled = false

    // Variables to capture data
    var profile: Profile?
    var avatarURL: URL?
    var alertTitle: String?
    var alertMessage: String?

    func updateAvatar(url: URL) {
        updateAvatarCalled = true
        avatarURL = url
    }

    func updateUIWithProfile(_ profile: Profile) {
        updateUIWithProfileCalled = true
        self.profile = profile
    }

    func addGradientToLabels() {
        addGradientToLabelsCalled = true
    }

    func removeGradientsFromLabels() {
        removeGradientsFromLabelsCalled = true
    }

    func showError(title: String, message: String) {
        showErrorCalled = true
        alertTitle = title
        alertMessage = message
    }
}
