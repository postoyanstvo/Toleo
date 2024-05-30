import Foundation
@testable import Toleo

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    // Variables to capture calls
    var fetchUserProfileCalled = false
    var updateAvatarCalled = false

    func fetchUserProfile() {
        fetchUserProfileCalled = true
    }

    func updateAvatar() {
        updateAvatarCalled = true
    }
}
