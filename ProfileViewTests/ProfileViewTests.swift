import XCTest
@testable import Toleo

class ProfileViewTests: XCTestCase {
    
    // Test fetchUserProfile() call
    func testViewControllerCallsFetchUserProfile() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        presenter.fetchUserProfile() // Simulate viewDidLoad calling fetchUserProfile
        
        // Then
        XCTAssertTrue(presenter.fetchUserProfileCalled)
    }
    
    // Test updateUIWithProfile()
    func testUpdateUIWithProfile() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let profileResult = ProfileResult(
            username: "testuser",
            firstName: "Test",
            lastName: "User",
            bio: "This is a test bio",
            profileImage: ProfileImage(small: "", medium: "", large: "")
        )
        
        let profile = Profile(from: profileResult)
        
        // When
        viewController.updateUIWithProfile(profile)
        
        // Then
        XCTAssertTrue(viewController.updateUIWithProfileCalled)
    }
    
    // Test updateAvatar()
    func testUpdateAvatar() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let url = URL(string: "https://example.com/avatar.jpg")!
        
        // When
        viewController.updateAvatar(url: url)
        
        // Then
        XCTAssertTrue(viewController.updateAvatarCalled)
        XCTAssertEqual(viewController.avatarURL, url)
    }
    
    // Test addGradientToLabels() and removeGradientsFromLabels()
    func testGradientHandling() {
        // Given
        let viewController = ProfileViewControllerSpy()
        
        // When
        viewController.addGradientToLabels()
        // Then
        XCTAssertTrue(viewController.addGradientToLabelsCalled)
        
        // When
        viewController.removeGradientsFromLabels()
        // Then
        XCTAssertTrue(viewController.removeGradientsFromLabelsCalled)
    }
    
    // Test showError()
    func testShowError() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let title = "Error"
        let message = "Something went wrong"
        
        // When
        viewController.showError(title: title, message: message)
        
        // Then
        XCTAssertTrue(viewController.showErrorCalled)
        XCTAssertEqual(viewController.alertTitle, title)
        XCTAssertEqual(viewController.alertMessage, message)
    }
}
