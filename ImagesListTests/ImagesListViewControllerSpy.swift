import XCTest
@testable import Toleo

class ImagesListViewControllerSpy: ImagesListViewProtocol {
    var presenter: ImagesListPresenterProtocol?
    var updateTableViewAnimatedCalled = false

    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
}
