import XCTest
@testable import Toleo

final class ImagesListTests: XCTestCase {
    // Test fetchPhotosNextPage() call
    func testViewControllerCallsFetchPhotosNextPage() {
        // Given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        presenter.fetchPhotosNextPage()
        
        // Then
        XCTAssertTrue(presenter.fetchPhotosNextPageCalled)
    }
    
    // Test addObserver() call
    func testViewControllerCallsAddObserver() {
        // Given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        presenter.addImageListObserver()
        
        // Then
        XCTAssertTrue(presenter.addImageListObserverCalled)
    }
    
    // Test updateTableViewAnimated()
    func testUpdateTableViewAnimated() {
        // Given
        let viewController = ImagesListViewControllerSpy()
        
        // When
        viewController.updateTableViewAnimated()
        
        // Then
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
    }
}

